package com.wristreply.core.guard

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap

/** Single message-segment bundled in a debounce window. */
data class BufferedSegment(
    val text: String,
    val timestamp: Long
)

/**
 * Debounced burst ingestion buffer (Anti-Spam Batching).
 *
 * Collates rapid message bursts from the same sender into a single
 * contextual prompt. Each new message resets the debounce timer to
 * [DEBOUNCE_DELAY_MS]; once the window closes, the aggregated text is
 * passed to [onBatchReady].
 */
object MessageDebounceBuffer {

    /** Window after the last message before emitting the aggregated text. */
    private const val DEBOUNCE_DELAY_MS = 1500L

    /** Maximum number of segments retained per sender. */
    private const val MAX_BUFFER_SIZE = 5

    private val debounceJobs = ConcurrentHashMap<String, Job>()
    private val conversationWindows = ConcurrentHashMap<String, MutableList<BufferedSegment>>()

    /**
     * Appends [messageText] to the sender's buffer and (re)schedules the
     * debounce timer. When the timer fires, [onBatchReady] is invoked with
     * the joined, space-separated context string.
     */
    fun enqueueMessage(
        scope: CoroutineScope,
        senderId: String,
        messageText: String,
        onBatchReady: (combinedContext: String) -> Unit
    ) {
        val currentBuffer = conversationWindows.getOrPut(senderId) { mutableListOf() }
        synchronized(currentBuffer) {
            currentBuffer.add(BufferedSegment(messageText, System.currentTimeMillis()))
            // Cap the buffer so a runaway sender can't blow up memory.
            while (currentBuffer.size > MAX_BUFFER_SIZE) {
                currentBuffer.removeAt(0)
            }
        }

        debounceJobs[senderId]?.cancel()

        debounceJobs[senderId] = scope.launch(Dispatchers.Default) {
            try {
                delay(DEBOUNCE_DELAY_MS)
                val aggregatedText = synchronized(currentBuffer) {
                    if (currentBuffer.isEmpty()) return@synchronized ""
                    currentBuffer.joinToString(" ") { it.text }
                }
                if (aggregatedText.isNotEmpty()) {
                    onBatchReady(aggregatedText)
                }
            } finally {
                debounceJobs.remove(senderId)
            }
        }
    }

    /** Drops any pending timer and buffered segments for [senderId]. */
    fun clearBuffer(senderId: String) {
        debounceJobs[senderId]?.cancel()
        debounceJobs.remove(senderId)
        conversationWindows.remove(senderId)
    }

    /** Number of senders currently being debounced. Useful for diagnostics. */
    fun activeSenderCount(): Int = debounceJobs.size
}
