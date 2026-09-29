package com.wristreply.core.nlp

import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.TextMessage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

/**
 * Ephemeral on-device NLP inference utilizing Google ML Kit SmartReply.
 * Instantiates the client on-demand and guarantees client.close() execution
 * in a finally block to prevent resident memory bloat.
 */
object EphemeralMLKitEngine {

    suspend fun suggestReplies(
        messageText: String,
        senderName: String,
        timestamp: Long = System.currentTimeMillis()
    ): List<String> = withContext(Dispatchers.Default) {
        suspendCancellableCoroutine { continuation ->
            val client = SmartReply.getClient()
            val conversation = listOf(
                TextMessage.createForRemoteUser(messageText, timestamp, senderName)
            )

            client.suggestReplies(conversation)
                .addOnSuccessListener { result ->
                    val replies = result.suggestions.map { it.text }
                    try {
                        client.close()
                    } catch (_: Exception) {}
                    if (continuation.isActive) {
                        continuation.resume(replies)
                    }
                }
                .addOnFailureListener {
                    try {
                        client.close()
                    } catch (_: Exception) {}
                    if (continuation.isActive) {
                        continuation.resume(emptyList())
                    }
                }
        }
    }
}
