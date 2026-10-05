# ==============================================================================
#  WristReply AI — ProGuard / R8 shrinker rules
# ==============================================================================
# These rules are applied to BOTH the :app and :core-engine library consumers.
# They are intentionally permissive about our own classes (we want zero
# surprise runtime crashes from a missing class) and strict about third-party
# ML Kit classes (we cannot mirror those semantics).
# ==============================================================================

# --- Google ML Kit Smart Reply ---------------------------------------------
-keep class com.google.mlkit.nl.smartreply.** { *; }
-keep interface com.google.mlkit.nl.smartreply.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep interface com.google.mlkit.common.** { *; }
-dontwarn com.google.mlkit.**

# --- WristReply core engine -------------------------------------------------
# The Flutter MethodChannel uses reflection to discover Kotlin class names.
# Keep the entire engine module so cross-module references survive shrinking.
-keep class com.wristreply.core.** { *; }
-keep interface com.wristreply.core.** { *; }
-keep enum com.wristreply.core.** { *; }
-keepclassmembers class com.wristreply.core.** { *; }

# --- NotificationListenerService subclasses ------------------------------------
-keepclassmembers class * extends android.service.notification.NotificationListenerService {
    <methods>;
}

# --- Broadcast receivers (must keep manifest-referenced names) --------------
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.app.Service

# --- AndroidX notification helpers ------------------------------------------
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.RemoteInput** { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }

# --- Kotlin coroutines internals --------------------------------------------
-dontwarn kotlinx.coroutines.**
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# --- General safety ---------------------------------------------------------
# Keep R8 from removing our dynamic kotlin metadata.
-keepattributes *Annotation*, InnerClasses, Signature, EnclosingMethod
-keepattributes SourceFile, LineNumberTable
-renamesourcefileattribute SourceFile

# Strip the verbose log statements from release builds.
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
