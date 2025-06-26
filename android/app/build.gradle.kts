import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")

  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
  
  // Adicionar dependência para desugaring (necessário para flutter_local_notifications)
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.1.5")
}

android {
    namespace = "br.com.brodt.projeto_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Usando a versão do NDK compatível com todos os plugins

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Habilitar desugaring para suportar recursos Java 8 em versões anteriores do Android
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        // Ignorar incompatibilidade da versão do Kotlin
        freeCompilerArgs = listOf("-Xskip-metadata-version-check")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "br.com.brodt.projeto_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 // Atualizado para 23 para compatibilidade com o Firebase Auth
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storePassword = keystoreProperties["storePassword"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it)}
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
