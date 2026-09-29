package com.wristreply.core.filters

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import com.wristreply.core.model.ExtractedToken
import com.wristreply.core.model.TokenType

/**
 * Scans message text for financial transaction IDs and OTP codes,
 * providing clipboard automation with zero-cloud processing.
 */
object SmartTokenExtractor {

    private val TRX_ID_REGEX = Regex("(?i)(?:trxid|txid|tran id|transaction id|ref|utr)[:\\s#]+([A-Z0-9]{6,18})")
    private val OTP_REGEX = Regex("(?i)(?:otp|code|pin|verification)[:\\s]+(\\d{4,8})")

    fun scanAndExtract(
        text: String,
        autoCopyTrx: Boolean = true,
        autoCopyOtp: Boolean = true
    ): ExtractedToken? {
        if (autoCopyTrx) {
            val trxMatch = TRX_ID_REGEX.find(text)
            if (trxMatch != null && trxMatch.groupValues.size > 1) {
                return ExtractedToken(TokenType.TRANSACTION_ID, trxMatch.groupValues[1].trim())
            }
        }

        if (autoCopyOtp) {
            val otpMatch = OTP_REGEX.find(text)
            if (otpMatch != null && otpMatch.groupValues.size > 1) {
                return ExtractedToken(TokenType.OTP, otpMatch.groupValues[1].trim())
            }
        }

        return null
    }

    fun copyToClipboard(context: Context, token: ExtractedToken) {
        try {
            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
            val label = if (token.type == TokenType.TRANSACTION_ID) "Transaction ID" else "OTP Code"
            val clip = ClipData.newPlainText(label, token.value)
            clipboard?.setPrimaryClip(clip)
        } catch (_: Exception) {}
    }
}
