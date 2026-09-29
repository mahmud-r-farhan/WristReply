package com.wristreply.core

import com.wristreply.core.filters.SmartTokenExtractor
import com.wristreply.core.model.TokenType
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

class SmartTokenExtractorTest {

    @Test
    fun testGlobalPaymentSystems() {
        val paypal = "You sent $50.00 to Alex. Transaction ID: 9XX8372648."
        assertEquals("9XX8372648", SmartTokenExtractor.scanAndExtract(paypal)?.value)

        val stripe = "Payment succeeded. Charge ID: ch_3MtwL2LkdIwHu7ix28a3tqPa."
        assertEquals("ch_3MtwL2LkdIwHu7ix28a3tqPa", SmartTokenExtractor.scanAndExtract(stripe)?.value)

        val applePay = "Payment to Store via Apple Pay. Ref: AP-88392019."
        assertEquals("AP-88392019", SmartTokenExtractor.scanAndExtract(applePay)?.value)

        val bankSms = "Alert: USD 120.50 debited from A/C 4029. Ref No: REF89372109."
        assertEquals("REF89372109", SmartTokenExtractor.scanAndExtract(bankSms)?.value)

        val binance = "[Binance] Withdrawal of 0.5 ETH successful. TxID: 0x4f8a92b3c4d5."
        assertEquals("0x4f8a92b3c4d5", SmartTokenExtractor.scanAndExtract(binance)?.value)
    }

    @Test
    fun testRegionalPaymentSystems() {
        val pix = "Pix enviado com sucesso. ID da transação: E00038166202609291234."
        assertEquals("E00038166202609291234", SmartTokenExtractor.scanAndExtract(pix)?.value)

        val ideal = "iDEAL betaling geslaagd. Kenmerk: NL93INGB0001234567."
        assertEquals("NL93INGB0001234567", SmartTokenExtractor.scanAndExtract(ideal)?.value)

        val upi = "Paid Rs. 1500 to Merchant. UPI Ref: 329482718293."
        assertEquals("329482718293", SmartTokenExtractor.scanAndExtract(upi)?.value)

        val grab = "GrabPay transfer completed. Transaction ID: GP-98327492."
        assertEquals("GP-98327492", SmartTokenExtractor.scanAndExtract(grab)?.value)

        val bkash = "You have received Tk 500.00. TrxID 9K34DAX891 at 29/09/2026."
        assertEquals("9K34DAX891", SmartTokenExtractor.scanAndExtract(bkash)?.value)
    }

    @Test
    fun testMultiLingualOtpCodes() {
        val otpEn = "Your WristReply verification code: 849201. Valid for 5 min."
        assertEquals("849201", SmartTokenExtractor.scanAndExtract(otpEn)?.value)

        val otpEs = "Tu código de verificación es 492018 para confirmar tu compra."
        assertEquals("492018", SmartTokenExtractor.scanAndExtract(otpEs)?.value)

        val otpDe = "Ihr Bestätigungscode lautet 839201."
        assertEquals("839201", SmartTokenExtractor.scanAndExtract(otpDe)?.value)

        val otpFr = "Votre code de confirmation est 294819."
        assertEquals("294819", SmartTokenExtractor.scanAndExtract(otpFr)?.value)
    }
}

