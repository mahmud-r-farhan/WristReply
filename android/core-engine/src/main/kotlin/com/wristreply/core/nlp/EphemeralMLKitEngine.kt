package com.wristreply.core.nlp

import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.TextMessage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

/**
 * Ephemeral on-device NLP inference utilizing Google ML Kit SmartReply.
 *
 * Instantiates the [SmartReply] client on-demand and guarantees
 * [SmartReply.close] runs in a `finally` block to prevent resident memory
 * bloat. A 2.5-second safety timeout ensures we never block the notification
 * pipeline if ML Kit stalls.
 */
object EphemeralMLKitEngine {

    private const val INFERENCE_TIMEOUT_MS = 2500L

    suspend fun suggestReplies(
        messageText: String,
        senderName: String,
        timestamp: Long = System.currentTimeMillis()
    ): List<String> = withContext(Dispatchers.Default) {
        // Quick reject: empty / whitespace messages shouldn't allocate the
        // ML Kit client at all.
        if (messageText.isBlank()) return@withContext emptyList()

        val result = withTimeoutOrNull(INFERENCE_TIMEOUT_MS) {
            suspendCancellableCoroutine<List<String>> { continuation ->
                val client = SmartReply.getClient()
                val conversation = listOf(
                    TextMessage.createForRemoteUser(messageText, timestamp, senderName)
                )

                client.suggestReplies(conversation)
                    .addOnSuccessListener { reply ->
                        val suggestions = reply.suggestions.map { it.text }
                        try {
                            client.close()
                        } catch (_: Exception) {}
                        if (continuation.isActive) continuation.resume(suggestions)
                    }
                    .addOnFailureListener {
                        try {
                            client.close()
                        } catch (_: Exception) {}
                        if (continuation.isActive) continuation.resume(emptyList())
                    }

                continuation.invokeOnCancellation {
                    try { client.close() } catch (_: Exception) {}
                }
            }
        }
        result ?: emptyList()
    }
}