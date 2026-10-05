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
 * [StatusBarNotification] and [Bundle] are fabricated with Mockito. The bundle
 * in particular *must* be a mock: JVM unit tests run against the stubbed
 * `android.jar`, where a real `Bundle` silently swallows every
 * `putCharSequence`/`putBoolean` call and returns `null` on read, which would
 * make the gate reject every fixture.
 *
 * [Notification] is a real instance instead, because `flags` and `extras` are
 * public *fields* rather than methods — Mockito cannot stub a field access and
 * fails with `MissingMethodInvocationException`.
 */
class NotificationGateTest {

    private fun makeSbn(
        flags: Int = 0,
        text: String? = "hello world",
        extraIsWristReply: Boolean = false,
    ): StatusBarNotification {
        val extras = mock(Bundle::class.java)
        `when`(extras.getCharSequence(Notification.EXTRA_TEXT)).thenReturn(text)
        `when`(extras.getCharSequence(Notification.EXTRA_BIG_TEXT)).thenReturn(null)
        `when`(extras.getBoolean(NotificationGate.EXTRA_IS_WRIST_REPLY, false))
            .thenReturn(extraIsWristReply)

        // `this.` is required inside `apply`: a bare `flags`/`extras` on the left
        // resolves to the parameter (locals shadow implicit receiver members).
        val notification = Notification().apply {
            this.flags = flags
            this.extras = extras
        }

        val sbn = mock(StatusBarNotification::class.java)
        `when`(sbn.notification).thenReturn(notification)
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
    fun `rejects messages without any text payload`() {
        val sbn = makeSbn(text = null)
        assertFalse(NotificationGate.shouldProcess(sbn))
    }

    @Test
    fun `accepts plain message with text`() {
        val sbn = makeSbn()
        assertTrue(NotificationGate.shouldProcess(sbn))
    }

    @Test
    fun `accepts a message regardless of its category tag`() {
        // The gate deliberately never inspects Notification.category — only the
        // flags, the self-injection extra and the text payload.
        val sbn = makeSbn(text = "hi")
        assertTrue(NotificationGate.shouldProcess(sbn))
    }
}
