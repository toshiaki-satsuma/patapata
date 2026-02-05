package dev.patapata.patapata_adjust_deeplink

import android.content.Intent
import android.util.Log
import com.adjust.sdk.Adjust
import com.adjust.sdk.AdjustDeeplink
import dev.patapata.patapata_core.PatapataPlugin
import dev.patapata.patapata_core.registerPatapataPlugin
import dev.patapata.patapata_core.unregisterPatapataPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

private const val CHANNEL_NAME = "dev.patapata.patapata_adjust_deeplink"
private const val LOG_TAG = "PatapataAdjustDeeplink"

class PatapataAdjustDeeplinkPlugin :
  FlutterPlugin,
  MethodCallHandler,
  ActivityAware,
  PluginRegistry.NewIntentListener,
  PatapataPlugin {

  private var channel: MethodChannel? = null
  private var flutterBinding: FlutterPluginBinding? = null
  private var activityBinding: ActivityPluginBinding? = null
  private var isEnabled = true

  override val patapataName: String
    get() = CHANNEL_NAME

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    flutterBinding = binding
    channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
      it.setMethodCallHandler(this)
    }
    binding.registerPatapataPlugin(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    binding.unregisterPatapataPlugin(this)
    channel?.setMethodCallHandler(null)
    channel = null
    flutterBinding = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    result.notImplemented()
  }

  override fun patapataEnable() {
    isEnabled = true
  }

  override fun patapataDisable() {
    isEnabled = false
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    binding.addOnNewIntentListener(this)
    handleDeeplinkIntent(binding.activity.intent)
  }

  override fun onDetachedFromActivity() {
    activityBinding?.removeOnNewIntentListener(this)
    activityBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onNewIntent(intent: Intent): Boolean {
    handleDeeplinkIntent(intent)
    return false
  }

  private fun handleDeeplinkIntent(intent: Intent?) {
    if (!isEnabled) {
      Log.d(LOG_TAG, "Plugin disabled, ignore intent: $intent")
      return
    }

    val dataString = intent?.dataString ?: run {
      Log.d(LOG_TAG, "Intent has no data: $intent")
      return
    }

    val context = activityBinding?.activity ?: flutterBinding?.applicationContext ?: run {
      Log.w(LOG_TAG, "No context available to process deeplink")
      return
    }

    val uri = try {
      android.net.Uri.parse(dataString)
    } catch (e: IllegalArgumentException) {
      Log.w(LOG_TAG, "Failed to parse deeplink: $dataString", e)
      return
    }

    val deeplink = AdjustDeeplink(uri)
    Adjust.processAndResolveDeeplink(deeplink, context) { resolved ->
      Log.d(LOG_TAG, "Resolved Adjust deeplink: $resolved")
      channel?.invokeMethod("processAdjustDeepLink", resolved)
    }
  }
}
