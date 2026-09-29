package com.wristreply.core

import com.wristreply.core.filters.SmartTokenExtractor
import com.wristreply.core.model.TokenType
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

class SmartTokenExtractorTest {

    @Test
    fun testExtractBkashTrxId() {
        val message = "You have received Tk 500.00 from 01700000000. TrxID 9K34DAX891 at 29/09/2026."
        val extracted = SmartTokenExtractor.scanAndExtract(message)
        assertNotNull(extracted)
        assertEquals(TokenType.TRANSACTION_ID, extracted?.type)
        assertEquals("9K34DAX891", extracted?.value)
    }

    @Test
    fun testExtractOtpCode() {
        val message = "Your WristReply verification code: 849201. Valid for 5 minutes."
        val extracted = SmartTokenExtractor.scanAndExtract(message)
        assertNotNull(extracted)
        assertEquals(TokenType.OTP, extracted?.type)
        assertEquals("849201", extracted?.value)
    }
}
