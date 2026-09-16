plugins {
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
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
// buildscript classpath (e.g. alarm 5.13.1 pins Kotlin 2.2.20,
// which conflicts with the root project's Kotlin 2.4.0).
subprojects {
    buildscript {
        configurations.configureEach {
            resolutionStrategy {
                force("org.jetbrains.kotlin:kotlin-serialization:2.4.0")
                force("org.jetbrains.kotlin:kotlin-gradle-plugin:2.4.0")
            }
        }
    }
}

// flutter_js still requests Kotlin JVM 1.8 while AGP 9 compiles its Java code for JVM 11.
subprojects {
    if (name == "flutter_js") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
