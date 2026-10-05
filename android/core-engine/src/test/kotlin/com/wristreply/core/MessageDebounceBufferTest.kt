package com.wristreply.core

import com.wristreply.core.guard.MessageDebounceBuffer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeoutOrNull
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference

/** Unit tests for the anti-spam burst buffer. */
class MessageDebounceBufferTest {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    @Before
    fun setUp() {
        // Make sure no leakage from a previous test run.
        MessageDebounceBuffer.clearBuffer("Alice")
        MessageDebounceBuffer.clearBuffer("Bob")
        MessageDebounceBuffer.clearBuffer("Charlie")
        MessageDebounceBuffer.clearBuffer("Dan")
    }

    @After
    fun tearDown() {
        scope.coroutineContext[Job]?.cancel()
    }

    @Test
    fun `single message emits after debounce window`() = runBlocking {
        val emitted = AtomicReference<String?>(null)
        MessageDebounceBuffer.enqueueMessage(scope, "Alice", "hello") {
            emitted.set(it)
        }
        val result = withTimeoutOrNull(3000) {
            while (emitted.get() == null) delay(50)
            emitted.get()
        }
        assertEquals("hello", result)
    }

    @Test
    fun `burst messages collapse to one aggregated prompt`() = runBlocking {
        val emitted = AtomicReference<String?>(null)
        MessageDebounceBuffer.enqueueMessage(scope, "Bob", "first") {}
        delay(200)
        MessageDebounceBuffer.enqueueMessage(scope, "Bob", "second") {}
        delay(200)
        MessageDebounceBuffer.enqueueMessage(scope, "Bob", "third") {
            emitted.set(it)
        }
        val result = withTimeoutOrNull(3000) {
            while (emitted.get() == null) delay(50)
            emitted.get()
        }
        assertEquals("first second third", result)
    }

    @Test
    fun `clearBuffer cancels pending emission`() = runBlocking {
        val fired = AtomicInteger(0)
        MessageDebounceBuffer.enqueueMessage(scope, "Charlie", "hi") {
            fired.incrementAndGet()
        }
        delay(200)
        MessageDebounceBuffer.clearBuffer("Charlie")
        delay(2000)
        assertEquals(0, fired.get())
    }

    @Test
    fun `activeSenderCount reflects pending jobs`() = runBlocking {
        MessageDebounceBuffer.enqueueMessage(scope, "Dan", "x") {}
        assertTrue(MessageDebounceBuffer.activeSenderCount() >= 1)
        delay(2500)
        assertEquals(0, MessageDebounceBuffer.activeSenderCount())
    }
}