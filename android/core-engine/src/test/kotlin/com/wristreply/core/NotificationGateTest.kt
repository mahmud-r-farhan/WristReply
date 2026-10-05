package com.wristreply.core

import android.app.Notification
import android.os.Bundle
import android.service.notification.StatusBarNotification
import com.wristreply.core.inspector.NotificationGate
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`

/**
 * Unit tests for the [NotificationGate] filter — the first line of defense
 * before any NLP compute is allocated.
 *
 * We use Mockito to fabricate [StatusBarNotification] instances without
 * needing a real Android runtime.
 */
class NotificationGateTest {

    private fun makeSbn(
        flags: Int = 0,
        category: String? = Notification.CATEGORY_MESSAGE,
        text: String? = "hello world",
        extraIsWristReply: Boolean = false,
    ): StatusBarNotification {
        val sbn = mock(StatusBarNotification::class.java)
        val notification = mock(Notification::class.java)

        `when`(sbn.notification).thenReturn(notification)
        `when`(notification.flags).thenReturn(flags)
        `when`(notification.category).thenReturn(category)

        val extras = Bundle()
        if (text != null) extras.putCharSequence(Notification.EXTRA_TEXT, text)
        if (extraIsWristReply) extras.putBoolean(NotificationGate.EXTRA_IS_WRIST_REPLY, true)
        `when`(notification.extras).thenReturn(extras)

        return sbn
    }

    @Test
    fun `rejects null sbn`() {
        assertFalse(NotificationGate.shouldProcess(null))
    }

    @Test
    fun `rejects our own companion notifications`() {
        val sbn = makeSbn(extraIsWristReply = true)
        assertFalse(NotificationGate.shouldProcess(sbn))
    }

    @Test
    fun `rejects ongoing events`() {
        val sbn = makeSbn(flags = Notification.FLAG_ONGOING_EVENT)
        assertFalse(NotificationGate.shouldProcess(sbn))
    }

    @Test
    fun `rejects group summary notifications`() {
        val sbn = makeSbn(flags = Notification.FLAG_GROUP_SUMMARY)
        assertFalse(NotificationGate.shouldProcess(sbn))
    }

    @Test
    fun `rejects blank messages`() {
        val sbn = makeSbn(text = "   ")
        assertFalse(NotificationGate.shouldProcess(sbn))
    }

    @Test
    fun `accepts plain message with category MESSAGE`() {
        val sbn = makeSbn()
        assertTrue(NotificationGate.shouldProcess(sbn))
    }

    @Test
    fun `accepts message without category but with text`() {
        val sbn = makeSbn(category = null, text = "hi")
        assertTrue(NotificationGate.shouldProcess(sbn))
    }
}