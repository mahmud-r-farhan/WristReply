package com.wristreply.core.model

/**
 * Local operational metrics maintained in memory (zero PII, zero leakage).
 */
data class EngineMetrics(
    val repliesDispatched: Long = 0,
    val avgLatencyMs: Long = 0,
    val cacheHits: Long = 0,
    val isActive: Boolean = true
)
