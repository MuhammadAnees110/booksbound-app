# Flutter
-dontwarn io.flutter.embedding.**
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Cloud Firestore
-keep class com.google.firebase.firestore.** { *; }

# Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable CREATOR;
}

# Keep model classes (reflection)
-keep class com.booksbound_app.** { *; }
-keepclassmembers class * {
    public <init>(...);
}
