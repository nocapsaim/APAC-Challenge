import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// Buildscript for adding dependencies
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Google services plugin for Firebase
        classpath("com.google.gms:google-services:4.3.15")
        // Kotlin plugin for Android
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.20")
    }
}

// All projects: Repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory (optional, only if required)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Clean task to delete build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
