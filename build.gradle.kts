import org.gradle.api.tasks.bundling.Jar
import java.util.Properties
import org.gradle.api.JavaVersion

plugins {
    id("java") // Simplified plugin declaration
}

java {
    sourceCompatibility = JavaVersion.VERSION_17 // Or your preferred Java version
    targetCompatibility = JavaVersion.VERSION_17
}

// Define mod properties loading
val modProps: Properties by lazy {
    Properties().also { props ->
        val configFile = file("src/main/resources/PZModMenu/mod.properties")
        if (configFile.exists()) {
            configFile.inputStream().use { props.load(it) }
        } else {
            println("Warning: Missing mod configuration file. Using defaults.")
            props["mod.group"] = "com.example.pzmodmenu"  // Provide a default group
            props["mod.artifact"] = "pzmodmenu"
            props["mod.version"] = "1.0.0"
            // You might also create the file automatically here for convenience

        }
    }
}

group = modProps["mod.group"] as String // Default group
version = (modProps["mod.version"] as String).replace("'", "")
val modArtifact = modProps["mod.artifact"] as String // For artifact naming

repositories {
    mavenCentral()  // Rely on Maven Central primarily
}

dependencies {
    // External dependencies (Lombok, ASM) using a different syntax
    compileOnly("org.projectlombok:lombok:1.18.36") // Use compileOnly for Lombok
    annotationProcessor("org.projectlombok:lombok:1.18.36")

    implementation("org.ow2.asm:asm:9.7.1")
    implementation("org.ow2.asm:asm-tree:9.7.1")

    // Project Zomboid API (adjust as needed)
    implementation(files("lib/fmod.jar"))
    implementation(files("lib/zombie.jar"))
    implementation(files("lib/Kahlua.jar"))
    implementation(files("lib/org.jar"))
}

// Customized JAR task
tasks {
    val packageMod: Jar = create("packageMod") {  // Create task explicitly
        description = "Packages the PZModMenu into a JAR file."
        group = "build"
        destinationDirectory.set(layout.buildDirectory.dir("distributions").get().asFile)  // More specific output directory
        archiveFileName.set("${modArtifact}-${version}.jar")  // Name based on artifact property

        manifest {
            attributes(
                "Main-Class" to "pzmodmenu.core.ModEntrypoint", // More specific main class name
                "Implementation-Title" to "Project Zomboid Mod Menu",  // Informative attributes
                "Implementation-Version" to version
            )
        }
        duplicatesStrategy = DuplicatesStrategy.EXCLUDE // Handle duplicates intentionally

       //  Directly use files() for classpath handling.
        from(sourceSets["main"].runtimeClasspath)  //More concise classpath inclusion

        doLast {
            println("Successfully created ${archiveFileName.get()} in ${destinationDirectory.get()}")
        }
    }

    build {
        dependsOn(packageMod) // Ensure the custom task is executed as part of the build
    }
}
