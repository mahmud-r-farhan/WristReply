# ==============================================================================
#  WristReply AI Core Engine — Consumer ProGuard rules
# ==============================================================================
# Rules emitted to every host app that depends on this AAR. They are merged
# into the host's proguard-rules.pro at build time.
# ==============================================================================

# Google ML Kit Smart Reply (used internally by the engine).
-keep class com.google.mlkit.nl.smartreply.** { *; }
-keep interface com.google.mlkit.nl.smartreply.** { *; }
-keep class com.google.mlkit.common.** { *; }

# All public API in the engine module — keep names so reflection from the
# Flutter MethodChannel keeps working even after shrinking.
-keep class com.wristreply.core.** { *; }
-keep interface com.wristreply.core.** { *; }
-keep enum com.wristreply.core.** { *; }
-keepclassmembers class com.wristreply.core.** { *; }

# Suppress noisy warnings from transitive Kotlin coroutines internals.
-dontwarn kotlinx.coroutines.**
-dontwarn org.jetbrains.annotations.**