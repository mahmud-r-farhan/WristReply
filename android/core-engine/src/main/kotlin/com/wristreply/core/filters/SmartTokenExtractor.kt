package com.wristreply.core.filters

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import com.wristreply.core.model.ExtractedToken
import com.wristreply.core.model.TokenType

/**
 * Scans message text for multi-regional financial transaction IDs and OTP codes,
 * supporting Apple Pay, Google Pay, PayPal, Stripe, UPI, Pix, iDEAL, Bank SMS,
 * and global messaging with zero-cloud processing.
 */
object SmartTokenExtractor {

    private val TRX_PATTERNS = listOf(
        Regex("(?i)\\b((?:ch_|pi_|py_|in_)[a-zA-Z0-9]{20,30})\\b"),
        Regex("(?i)\\b(?:txid|transaction\\s*hash)[:\\s#]+(0x[a-fA-F0-9]{10,64})\\b"),
        Regex("(?i)\\b(?:upi\\s*(?:ref|rrn)?\\s*(?:no|id)?|utr\\s*(?:no)?|txn\\s*(?:id|ref))[:\\s#]+([A-Za-z0-9]{10,22})\\b"),
        Regex("(?i)\\b(?:id\\s*da\\s*transa[cç][aã]o|autentica[cç][aã]o)[:\\s#]+([A-Za-z0-9]{9,35})\\b"),
        Regex("(?i)\\b(?:kenmerk|betalingskenmerk|referentie)[:\\s#]+([A-Za-z0-9]{8,25})\\b"),
        Regex("(?i)\\b(?:trxid|txid|tran(?:saction)?\\s*id|ref(?:erence)?(?:\\s*no)?|order\\s*id|session\\s*id|folio|operação)[:\\s#]+([A-Za-z0-9_\\-]{6,32})\\b")
    )

    private val OTP_PATTERNS = listOf(
        Regex("(?i)\\b(?:otp|verification(?:\\s*code)?|security\\s*code|auth\\s*code|código(?:\\s*de\\s*verificación)?|bestätigungscode|sicherheitscode|code(?:\\s*de\\s*confirmation)?|clave|pin|passcode|رمز(?:\\s*التحقق)?|كود|কোড|ওটিপি|कोड)(?:\\s*(?:is|es|ist|est|lautet|:|#|=|-|\\.))*\\s*[:#=\\s-]*(\\d{4,8})\\b"),
        Regex("(?i)\\b(\\d{4,8})\\s+(?:is\\s+your|es\\s+tu|ist\\s+(?:ihr|dein)|est\\s+votre|c'est\\s+votre)\\b")
    )

    fun scanAndExtract(
        text: String,
        autoCopyTrx: Boolean = true,
        autoCopyOtp: Boolean = true
    ): ExtractedToken? {
        if (autoCopyTrx) {
            for (pattern in TRX_PATTERNS) {
                val match = pattern.find(text)
                if (match != null && match.groupValues.size > 1) {
                    val token = cleanToken(match.groupValues[1])
                    if (token.isNotEmpty()) return ExtractedToken(TokenType.TRANSACTION_ID, token)
                }
            }
        }

        if (autoCopyOtp) {
            for (pattern in OTP_PATTERNS) {
                val match = pattern.find(text)
                if (match != null && match.groupValues.size > 1) {
                    val token = cleanToken(match.groupValues[1])
                    if (token.isNotEmpty()) return ExtractedToken(TokenType.OTP, token)
                }
            }
        }

        return null
    }

    private fun cleanToken(raw: String): String = raw.trim().trimEnd('.', ',', ';', ':', '!', '?', ')')

    fun copyToClipboard(context: Context, token: ExtractedToken) {
        try {
            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
            val label = if (token.type == TokenType.TRANSACTION_ID) "Transaction ID" else "OTP Code"
            val clip = ClipData.newPlainText(label, token.value)
            clipboard?.setPrimaryClip(clip)
        } catch (_: Exception) {}
    }
}

