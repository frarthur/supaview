# Supabase SDK
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }
-keep class gotrue.** { *; }
-keep class realtime.** { *; }
-keep class postgrest.** { *; }
-keep class storage.** { *; }
-keep class functions.** { *; }

# OkHttp (used by Supabase)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Kotlin serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}
-keep,includedescriptorclasses class io.supabase.**$$serializer { *; }
-keepclassmembers class io.supabase.** {
    *** Companion;
}
-keepclasseswithmembers class io.supabase.** {
    kotlinx.serialization.KSerializer serializer(...);
}
