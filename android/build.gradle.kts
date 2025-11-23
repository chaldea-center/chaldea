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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
