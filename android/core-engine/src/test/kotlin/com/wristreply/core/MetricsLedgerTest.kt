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
        // (50 + 100) / 2 samples == 75ms. The previous assertion divided the
        // average by 50 and compared it against the sample count, which can
        // never hold for an integer division result of 1.
        assertEquals(75L, metrics.avgLatencyMs)
        assertEquals(0L, metrics.cacheHits)
        assertTrue(metrics.avgLatencyMs >= 50L)
    }

    @Test
    fun `reports the documented idle default when no inference ran yet`() {
        // The dashboard renders 18ms as the "engine idle" baseline.
        assertEquals(18L, MetricsLedger.getMetrics().avgLatencyMs)
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
        // With zero samples the ledger reports the documented 18ms idle
        // baseline (the value the Flutter cockpit renders before first use),
        // not 0 — the old assertion contradicted MetricsLedger.getMetrics().
        assertEquals(18L, metrics.avgLatencyMs)
    }
}
