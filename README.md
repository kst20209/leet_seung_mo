# leet_seung_mo

A new Flutter project.

Android
- minSdkVersion 23
- SHA-1 sign
- build.gradle & app/build.gradle 수정 필요
  
MainActivity.kt
```kotlin
package com.example.leet_seung_mo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager.LayoutParams

class MainActivity: FlutterActivity(){
    private val CHANNEL = "flutter_secure_screen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "preventScreenshot" -> {
                    window.addFlags(LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "allowScreenshot" -> {
                    window.clearFlags(LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
