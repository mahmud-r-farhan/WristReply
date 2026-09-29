# Google ML Kit Smart Reply keep rules
-keep class com.google.mlkit.nl.smartreply.** { *; }
-keep interface com.google.mlkit.nl.smartreply.** { *; }

# Keep Android Notification and RemoteInput reflection targets
-keepclassmembers class * extends android.service.notification.NotificationListenerService {
    <methods>;
}

-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.RemoteInput** { *; }
-keep class com.wristreply.core.** { *; }
