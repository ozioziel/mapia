import java.io.FileInputStream
import java.nio.charset.StandardCharsets
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use { stream ->
        localProperties.load(stream)
    }
}
val googleMapsApiKey = System.getenv("GOOGLE_MAPS_API_KEY")
    ?: localProperties.getProperty("GOOGLE_MAPS_API_KEY")
    ?: (project.findProperty("dart-defines") as? String)
        ?.split(",")
        ?.mapNotNull { encoded ->
            val decoded = String(Base64.getDecoder().decode(encoded), StandardCharsets.UTF_8)
            val separator = decoded.indexOf("=")
            if (separator <= 0) null else decoded.substring(0, separator) to decoded.substring(separator + 1)
        }
        ?.firstOrNull { it.first == "GOOGLE_MAPS_API_KEY" }
        ?.second
    ?: ""

android {
    namespace = "com.example.mapiafrontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.mapiafrontend"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
