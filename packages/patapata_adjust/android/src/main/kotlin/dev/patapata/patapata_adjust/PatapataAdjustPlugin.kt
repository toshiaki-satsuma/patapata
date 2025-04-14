package dev.patapata.patapata_adjust

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import com.adjust.sdk.Adjust
import com.adjust.sdk.AdjustDeeplink
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PatapataAdjustPlugin */
class PatapataAdjustPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var binding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "patapata_adjust")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    result.notImplemented()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    this.binding = binding
    binding.addOnNewIntentListener { intent ->
      handleDeepLinkIntent(intent)
      false
    }
    handleDeepLinkIntent(binding.activity.intent)
  }

  override fun onDetachedFromActivity() {
    binding?.removeOnNewIntentListener { intent -> false }
    activity = null
    binding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun handleDeepLinkIntent(intent: Intent) {
    val data: Uri = intent.data
    val deeplink = AdjustDeeplink(data)
    Adjust.processAndResolveDeeplink(deeplink, activity) { resolved ->
      Log.d("PatapataAdjustPlugin", "Resolved Deeplink: $resolved")
      channel.invokeMethod("processDeepLink", resolved)
    }
  }
}