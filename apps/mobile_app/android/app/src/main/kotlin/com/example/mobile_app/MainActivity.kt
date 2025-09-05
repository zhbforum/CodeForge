package com.example.mobile_app

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "app_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "switchIcon" -> {
                        val alias = call.argument<String>("alias")
                        if (alias.isNullOrBlank()) {
                            result.error("BAD_ARGS", "alias is required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            switchIcon(alias)
                            result.success(true)
                        } catch (t: Throwable) {
                            result.error("SWITCH_FAILED", t.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun switchIcon(aliasSimpleName: String) {
        val pm = applicationContext.packageManager
        val pkg = applicationContext.packageName

        val classic  = ComponentName(pkg, "$pkg.MainActivityAliasClassic")
        val outline  = ComponentName(pkg, "$pkg.MainActivityAliasOutline")
        val gradient = ComponentName(pkg, "$pkg.MainActivityAliasGradient")

        val all = listOf(classic, outline, gradient)
        val toEnable = ComponentName(pkg, "$pkg.$aliasSimpleName")

        all.forEach { cmp ->
            val state = if (cmp == toEnable)
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED

            pm.setComponentEnabledSetting(
                cmp,
                state,
                PackageManager.DONT_KILL_APP
            )
        }
    }
}
