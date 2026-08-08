import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val appId = (project.findProperty("APP_ID") as String?) ?: "com.example.travel_super_app"

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

val storeFilePath = keyProperties.getProperty("storeFile")
val storePasswordValue = keyProperties.getProperty("storePassword")
val keyAliasValue = keyProperties.getProperty("keyAlias")
val keyPasswordValue = keyProperties.getProperty("keyPassword")
val storeFileResolved = if (storeFilePath.isNullOrBlank()) null else file(storeFilePath)

val hasConfiguredReleaseSigning = keyPropertiesFile.exists() &&
    !storeFilePath.isNullOrBlank() &&
    !storePasswordValue.isNullOrBlank() &&
    !keyAliasValue.isNullOrBlank() &&
    !keyPasswordValue.isNullOrBlank() &&
    storePasswordValue != "CHANGE_ME" &&
    keyPasswordValue != "CHANGE_ME" &&
    keyAliasValue != "CHANGE_ME" &&
    storeFileResolved?.exists() == true

android {
    namespace = appId
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = appId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasConfiguredReleaseSigning) {
                storeFile = file(storeFilePath!!)
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    buildTypes {
        release {
            if (hasConfiguredReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                throw GradleException(
                    "Invalid Android release signing configuration. Create android/key.properties from android/key.properties.example, replace placeholder values, and ensure the keystore file exists."
                )
            }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
