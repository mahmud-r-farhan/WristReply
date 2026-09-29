package com.wristreply.core.metrics

import com.wristreply.core.model.EngineMetrics
import java.util.concurrent.atomic.AtomicLong

/**
 * Local performance metrics ledger for operational visibility (100% zero PII).
 */
object MetricsLedger {

    private val dispatchCount = AtomicLong(0)
    private val totalLatency = AtomicLong(0)
    private val latencySamples = AtomicLong(0)
    private val cacheHitCount = AtomicLong(0)

    fun recordDispatch() {
        dispatchCount.incrementAndGet()
    }

    fun recordInference(latencyMs: Long, isCacheHit: Boolean = false) {
        if (isCacheHit) {
            cacheHitCount.incrementAndGet()
        }
        totalLatency.addAndGet(latencyMs)
        latencySamples.incrementAndGet()
    }

    fun getMetrics(): EngineMetrics {
        val count = dispatchCount.get()
        val samples = latencySamples.get()
        val avgLatency = if (samples > 0) totalLatency.get() / samples else 18L
        val hits = cacheHitCount.get()
        return EngineMetrics(
            repliesDispatched = count,
            avgLatencyMs = avgLatency,
            cacheHits = hits,
            isActive = true
        )
    }

    fun reset() {
        dispatchCount.set(0)
        totalLatency.set(0)
        latencySamples.set(0)
        cacheHitCount.set(0)
    }
}
