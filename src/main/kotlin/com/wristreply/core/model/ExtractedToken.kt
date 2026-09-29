package com.wristreply.core.model

/**
 * Token extracted from an incoming message (Financial Transaction ID or OTP).
 */
data class ExtractedToken(
    val type: TokenType,
    val value: String
)

enum class TokenType {
    TRANSACTION_ID,
    OTP
}
