package com.tealium.flutter.remotecommands.firebase

import android.app.Application
import androidx.annotation.NonNull
import com.tealium.RemoteCommandFactory
import com.tealium.TealiumPlugin
import com.tealium.remotecommands.RemoteCommand
import com.tealium.remotecommands.firebase.FirebaseRemoteCommand
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** TealiumFirebasePlugin */
class TealiumFirebasePlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var remoteCommandFactory: FirebaseRemoteCommandFactory

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    remoteCommandFactory = FirebaseRemoteCommandFactory(flutterPluginBinding.applicationContext as Application)
      TealiumPlugin.registerRemoteCommandFactory(remoteCommandFactory)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    result.notImplemented()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  class FirebaseRemoteCommandFactory(private val app: Application) : RemoteCommandFactory {
    override val name: String = "FirebaseRemoteCommand"

    override fun create(): RemoteCommand {
      return FirebaseRemoteCommand(app)
    }
  }
}