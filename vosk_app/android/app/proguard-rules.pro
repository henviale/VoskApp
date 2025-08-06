# VOSK - JNA rules
-keep class com.sun.jna.* { *; }
-keepclassmembers class * extends com.sun.jna.* { public *; }

# VOSK - AWT classes (anche se non usate su Android)
-dontwarn java.awt.**
-dontwarn javax.swing.**

# VOSK - Altre classi necessarie  
-keep class org.vosk.** { *; }
-keep class com.alphacep.** { *; }

# JNA Native library
-keep class * extends com.sun.jna.Structure { *; }
-keep class * extends com.sun.jna.Callback { *; }
-keepattributes *Annotation*