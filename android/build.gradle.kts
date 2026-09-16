allprojects {
    repositories {
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
    afterEvaluate {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val setCompileSdk = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdk.invoke(android, 36)
            } catch (_: Exception) {
                try {
                    val setCompileSdkStr = android.javaClass.getMethod("compileSdkVersion", String::class.java)
                    setCompileSdkStr.invoke(android, "android-36")
                } catch (_: Exception) {}
            }
            try {
                val setNdk = android.javaClass.getMethod("setNdkVersion", String::class.java)
                setNdk.invoke(android, "30.0.16248370")
            } catch (_: Exception) {}
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
