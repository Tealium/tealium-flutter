package com.tealium.flutter.remotecommands.tealium_braze

import android.app.Application
import androidx.annotation.NonNull
import com.tealium.RemoteCommandFactory
import com.tealium.TealiumPlugin
import com.tealium.remotecommands.RemoteCommand
import com.tealium.remotecommands.braze.BrazeRemoteCommand
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** TealiumBrazePlugin */
class TealiumBrazePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var remoteCommandFactory: BrazeRemoteCommandFactory

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        remoteCommandFactory =
            BrazeRemoteCommandFactory(flutterPluginBinding.applicationContext as Application)
        TealiumPlugin.registerRemoteCommandFactory(remoteCommandFactory)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        result.notImplemented()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // not implemented
    }

    class BrazeRemoteCommandFactory(private val app: Application) : RemoteCommandFactory {
        override val name: String = "BrazeRemoteCommand"

        override fun create(): RemoteCommand {
            return BrazeRemoteCommand(app)
        }
    }
}
