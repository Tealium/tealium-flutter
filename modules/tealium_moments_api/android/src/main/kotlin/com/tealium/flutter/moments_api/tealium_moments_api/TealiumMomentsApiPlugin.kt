package com.tealium.flutter.moments_api.tealium_moments_api

import com.tealium.INSTANCE_NAME
import com.tealium.OptionalModule
import com.tealium.TealiumPlugin
import com.tealium.core.Modules
import com.tealium.core.Tealium
import com.tealium.core.TealiumConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.tealium.momentsapi.EngineResponse
import com.tealium.momentsapi.ErrorCode
import com.tealium.momentsapi.MomentsApi
import com.tealium.momentsapi.ResponseListener
import com.tealium.momentsapi.momentsApi
import com.tealium.momentsapi.momentsApiReferrer
import com.tealium.momentsapi.momentsApiRegion


/** TealiumMomentsApiPlugin */
class TealiumMomentsApiPlugin : FlutterPlugin, MethodCallHandler, OptionalModule {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var momentsApiRegion: String? = null
    private var momentsApiReferrer: String? = null

    override fun configure(config: TealiumConfig) {
        config.modules.add(Modules.MomentsApi)

        momentsApiRegion?.let {
            config.momentsApiRegion = regionFromString(it)
        }

        config.momentsApiReferrer = momentsApiReferrer
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tealium_moments_api")
        channel.setMethodCallHandler(this)

        TealiumPlugin.registerOptionalModule(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "configure" -> configure(call, result)
            "fetchEngineResponse" -> fetchEngineResponse(call, result)
            else -> result.notImplemented()
        }
    }

    private fun configure(call: MethodCall, result: Result) {
        try {
            (call.arguments as? Map<*, *>)?.let { args ->
                args[KEY_MOMENTS_API_REGION]?.toString()?.let { region ->
                    momentsApiRegion = region
                }

                momentsApiReferrer = args[KEY_MOMENTS_API_REFERRER]?.toString()
            }
            result.success(null)
        } catch (e: Exception) {
            result.error(
                "ConfigurationError",
                "Failed to configure MomentsApi: ${e.message}",
                null
            )
        }
    }

    private fun fetchEngineResponse(call: MethodCall, result: Result) {
        val engineId = call.argument<String>(KEY_MOMENTS_API_ENGINE_ID)
        if (engineId == null) {
            result.error("InvalidArgument", "engineId cannot be null.", null)
            return
        }

        val tealium = Tealium[INSTANCE_NAME]
        if (tealium == null) {
            result.error(
                "ConfigurationError",
                "Unable to retrieve Tealium instance. Please check your configuration.",
                null
            )
            return
        }

        val momentsApi = tealium.momentsApi
        if (momentsApi == null) {
            result.error(
                "ConfigurationError",
                "Unable to retrieve MomentsAPI module. Please check your configuration.",
                null
            )
            return
        }

        momentsApi.fetchEngineResponse(engineId,
            object : ResponseListener<EngineResponse> {
                override fun success(data: EngineResponse) {
                    result.success(data.toMap())
                }

                override fun failure(errorCode: ErrorCode, message: String) {
                    result.error(
                        "ErrorFetchingEngineResponse",
                        "Failed to fetch engine response: $message",
                        null
                    )
                }
            }
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val KEY_MOMENTS_API_REGION = "momentsApiRegion"
        private const val KEY_MOMENTS_API_REFERRER = "momentsApiReferrer"
        private const val KEY_MOMENTS_API_ENGINE_ID = "engineId"
    }
}
