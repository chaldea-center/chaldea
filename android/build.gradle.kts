plugins {
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

allprojects {
    repositories {
        //  maven {
        //      setUrl("https://maven.aliyun.com/repository/central")
        //  }
        //  maven {
        //      setUrl("https://maven.aliyun.com/repository/public")
        //  }
        //  maven {
        //      setUrl("https://maven.aliyun.com/repository/gradle-plugin")
        //  }
        // GroMore SDK Maven
        maven {
            setUrl("https://artifact.bytedance.com/repository/pangle")
        }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
// Force Kotlin version alignment for plugin subprojects that declare their own
// buildscript classpath (e.g. alarm 5.5.0 pins kotlin-serialization:2.1.0,
// which conflicts with the root project's Kotlin 2.2.20).
subprojects {
    buildscript {
        configurations.configureEach {
            resolutionStrategy {
                force("org.jetbrains.kotlin:kotlin-serialization:2.2.20")
                force("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
