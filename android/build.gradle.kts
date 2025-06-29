import java.util.Properties
import java.io.FileInputStream

// Load local.properties file
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

// Set MapBox Downloads Token from local.properties or environment variable
val mapboxDownloadsToken = localProperties.getProperty("MAPBOX_DOWNLOADS_TOKEN") 
    ?: System.getenv("MAPBOX_DOWNLOADS_TOKEN")

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Make the token available to all projects
    if (mapboxDownloadsToken != null) {
        project.ext.set("MAPBOX_DOWNLOADS_TOKEN", mapboxDownloadsToken)
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
