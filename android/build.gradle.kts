plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Optional: Set custom build directory (ONLY IF NEEDED)
// Comment this out if you're using Flutter defaults
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // ✅ Required for Firebase to set NDK version safely
    plugins.whenPluginAdded {
        if (this is com.android.build.gradle.AppPlugin || this is com.android.build.gradle.LibraryPlugin) {
            extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                ndkVersion = "27.0.12077973"
            }
        }
    }
}

// ✅ Keep the clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
