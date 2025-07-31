
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val codeSignKeystoreFile = file(System.getenv("PLAY_CONSOLE_UPLOAD_KEYSTORE") ?: ".")
val codeSignKeystorePassFile = file(System.getenv("PLAY_CONSOLE_UPLOAD_KEYSTORE_PASS") ?: ".")
val sign = codeSignKeystoreFile.isFile && codeSignKeystorePassFile.isFile
val keystorePass = if (sign) codeSignKeystorePassFile.readText().trim() else ""

android {
    namespace = "com.example.sneaky_bird_apps_template"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.sneaky_bird_apps_template"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 // firebase_core plugin min SDK version
        targetSdk = 35 // https://developer.android.com/google/play/requirements/target-sdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // custom
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    flavorDimensions += "default"

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
        }
        create("stg") {
            dimension = "default"
            applicationIdSuffix = ".stg"
        }
        create("prod") {
            dimension = "default"
            applicationIdSuffix = ".prod"
        }
    }

    if (sign) {
        signingConfigs {
            create("release") {
                keyAlias = "upload"
                keyPassword = keystorePass
                storeFile = codeSignKeystoreFile
                storePassword = keystorePass
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = if (sign) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    testImplementation("junit:junit:4.12")

    // https://developer.android.com/jetpack/androidx/releases/test/#1.2.0
    //noinspection GradleDependency
    androidTestImplementation("androidx.test:runner:1.2.0")
    //noinspection GradleDependency
    androidTestImplementation("androidx.test.espresso:espresso-core:3.2.0")
}

flutter {
    source = "../.."
}
