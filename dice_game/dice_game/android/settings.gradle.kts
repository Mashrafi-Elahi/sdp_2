pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val propertiesFile = file("local.properties")
            if (propertiesFile.exists()) {
                propertiesFile.inputStream().use { properties.load(it) }
            }
            // Fallback to environment variable if local.properties is missing or path is null
            val path = properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
            if (path == null) {
                throw GradleException("Flutter SDK not found. Define 'flutter.sdk' in local.properties or set the FLUTTER_ROOT environment variable.")
            }
            path
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    id("com.google.gms.google-services") version "4.4.4" apply false
}

include(":app")
