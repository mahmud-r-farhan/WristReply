package com.wristreply.core.guard

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap

data class BufferedSegment(
    val text: String,
    val timestamp: Long
)

/**
 * Debounced burst ingestion buffer (Anti-Spam Batching).
 * Collates rapid message bursts into a single contextual prompt.
 */
object MessageDebounceBuffer {

    private const val DEBOUNCE_DELAY_MS = 2500L
    private val debounceJobs = ConcurrentHashMap<String, Job>()
    private val conversationWindows = ConcurrentHashMap<String, MutableList<BufferedSegment>>()

    fun enqueueMessage(
        scope: CoroutineScope,
        senderId: String,
        messageText: String,
        onBatchReady: (combinedContext: String) -> Unit
    ) {
        val currentBuffer = conversationWindows.getOrPut(senderId) { mutableListOf() }
        synchronized(currentBuffer) {
            currentBuffer.add(BufferedSegment(messageText, System.currentTimeMillis()))
            if (currentBuffer.size > 5) currentBuffer.removeAt(0)
        }

        debounceJobs[senderId]?.cancel()

        debounceJobs[senderId] = scope.launch(Dispatchers.Default) {
            delay(DEBOUNCE_DELAY_MS)
            val aggregatedText = synchronized(currentBuffer) {
                currentBuffer.joinToString(" ") { it.text }
            }
            onBatchReady(aggregatedText)
            debounceJobs.remove(senderId)
        }
    }

    fun clearBuffer(senderId: String) {
        debounceJobs[senderId]?.cancel()
        debounceJobs.remove(senderId)
        conversationWindows.remove(senderId)
    }
}
