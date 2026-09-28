---

### 1. `android/settings.gradle`

Ensure Gradle fetches dependencies from Google's Maven repository and resolves the Flutter loader plugin properly:

```groovy
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null : "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.3.2" apply false
    id "org.jetbrains.kotlin.android" version "1.9.23" apply false
}

include ":app"

```

---

### 2. `android/app/build.gradle`

This file configures **Java 17/Java 8 compatibility**, sets `minSdkVersion` to `26` (required for seamless background notification channels and modern `NotificationListenerService` rebinding), and brings in **Google ML Kit Smart Reply**, **Kotlin Coroutines**, and **AndroidX Core KTX**.

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty("flutter.versionCode")
if (flutterVersionCode == null) {
    flutterVersionCode = "1"
}

def flutterVersionName = localProperties.getProperty("flutter.versionName")
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

android {
    namespace "com.wristreply.app"
    compileSdk 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId "com.wristreply.app"
        // Min SDK 26 ensures native NotificationChannel and modern RemoteInput support
        minSdk 26
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName

        // Optimize APK packaging
        ndk {
            abiFilters "armeabi-v7a", "arm64-v8a", "x86_64"
        }
    }

    buildTypes {
        release {
            // Signing with debug keys for now; replace with upload keystore for production
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    // Kotlin Coroutines for off-main-thread processing
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.8.0"

    // AndroidX Core KTX & NotificationCompat
    implementation "androidx.core:core-ktx:1.13.1"
    implementation "androidx.appcompat:appcompat:1.6.1"

    // Google ML Kit Smart Reply (100% on-device model)
    implementation "com.google.mlkit:smart-reply:17.0.4"
}

```

---

### 3. `android/app/proguard-rules.pro` (Recommended)

To prevent code shrinking (`minifyEnabled true`) from stripping Google ML Kit's native inference libraries or reflection-based models in release builds:

```proguard
# Google ML Kit Smart Reply keep rules
-keep class com.google.mlkit.nl.smartreply.** { *; }
-keep interface com.google.mlkit.nl.smartreply.** { *; }

# Keep Android Notification and RemoteInput reflection targets
-keepclassmembers class * extends android.service.notification.NotificationListenerService {
    <methods>;
}

-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.RemoteInput** { *; }

```