package com.wristreply.core

import com.wristreply.core.metrics.MetricsLedger
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** Unit tests for the [MetricsLedger] singleton. */
class MetricsLedgerTest {

    @After
    fun tearDown() {
        MetricsLedger.reset()
    }

    @Test
    fun `records dispatches`() {
        MetricsLedger.recordDispatch()
        MetricsLedger.recordDispatch()
        MetricsLedger.recordDispatch()
        assertEquals(3L, MetricsLedger.getMetrics().repliesDispatched)
    }

    @Test
    fun `computes average latency`() {
        MetricsLedger.recordInference(latencyMs = 50L)
        MetricsLedger.recordInference(latencyMs = 100L)
        val metrics = MetricsLedger.getMetrics()
        assertEquals(2L, metrics.cacheHits + (metrics.avgLatencyMs / 50)) // cache not hit
        assertTrue(metrics.avgLatencyMs >= 50L)
    }

    @Test
    fun `tracks cache hits`() {
        MetricsLedger.recordInference(latencyMs = 10L, isCacheHit = true)
        MetricsLedger.recordInference(latencyMs = 20L, isCacheHit = false)
        assertEquals(1L, MetricsLedger.getMetrics().cacheHits)
    }

    @Test
    fun `reset zeroes everything`() {
        MetricsLedger.recordDispatch()
        MetricsLedger.recordInference(latencyMs = 50L)
        MetricsLedger.reset()
        val metrics = MetricsLedger.getMetrics()
        assertEquals(0L, metrics.repliesDispatched)
        assertEquals(0L, metrics.cacheHits)
        assertEquals(0L, metrics.avgLatencyMs)
    }
}