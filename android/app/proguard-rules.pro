# Règles de base pour Flutter
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Ne pas obfusquer les noms de classes/méthodes Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Règles pour les plugins Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Ne pas obfusquer les modèles de données
-keep class com.greensapp.greens_app.models.** { *; }

# Règles pour les bibliothèques qui utilisent des annotations
-dontwarn androidx.annotation.**
-dontwarn org.jetbrains.annotations.**

# Ignorer les avertissements généraux
-dontwarn kotlin.**
-dontwarn okio.**
-dontwarn retrofit2.**
-dontwarn javax.annotation.**

# Supprimer les logs pour la release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
}

# Règles pour les bibliothèques JSON
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Conserver les noms de champs pour la sérialisation Kotlin
-keepclassmembers class kotlin.Metadata {
    public <fields>;
    public <methods>;
} 