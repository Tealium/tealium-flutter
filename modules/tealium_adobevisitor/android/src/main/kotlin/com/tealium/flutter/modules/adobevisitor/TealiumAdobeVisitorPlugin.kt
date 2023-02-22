package com.tealium.flutter.modules.adobevisitor

import androidx.annotation.NonNull
import com.tealium.INSTANCE_NAME
import com.tealium.OptionalModule
import com.tealium.TealiumPlugin
import com.tealium.adobe.api.AdobeVisitor
import com.tealium.adobe.api.ResponseListener
import com.tealium.adobe.api.UrlDecoratorHandler
import com.tealium.adobe.kotlin.AdobeVisitor
import com.tealium.adobe.kotlin.AdobeVisitorModule
import com.tealium.adobe.kotlin.adobeVisitorApi
import com.tealium.adobe.kotlin.adobeVisitorAuthState
import com.tealium.adobe.kotlin.adobeVisitorCustomVisitorId
import com.tealium.adobe.kotlin.adobeVisitorDataProviderId
import com.tealium.adobe.kotlin.adobeVisitorExistingEcid
import com.tealium.adobe.kotlin.adobeVisitorOrgId
import com.tealium.adobe.kotlin.adobeVisitorRetries
import com.tealium.core.Collectors
import com.tealium.core.Tealium
import com.tealium.core.TealiumConfig
import com.tealium.onMain
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.MalformedURLException
import java.net.URL

/** TealiumAdobeVisitorPlugin */
class TealiumAdobeVisitorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, OptionalModule {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private val adobeVisitorApi: AdobeVisitorModule?
        get() = Tealium[INSTANCE_NAME]?.adobeVisitorApi

    private var adobeVisitorOrgId: String? = null
    private var adobeVisitorExistingEcid: String? = null
    private var adobeVisitorRetries: Int? = null
    private var adobeVisitorAuthState: Int? = null
    private var adobeVisitorDataProviderId: String? = null
    private var adobeVisitorCustomVisitorId: String? = null

    override fun configure(config: TealiumConfig) {
        config.collectors.add(Collectors.AdobeVisitor)

        adobeVisitorOrgId?.let {
            config.adobeVisitorOrgId = it
        }

        adobeVisitorExistingEcid?.let {
            config.adobeVisitorExistingEcid = it
        }

        adobeVisitorRetries?.let {
            config.adobeVisitorRetries = it
        }

        adobeVisitorAuthState?.let {
            config.adobeVisitorAuthState = it
        }

        adobeVisitorDataProviderId?.let {
            config.adobeVisitorDataProviderId = it
        }

        adobeVisitorCustomVisitorId?.let {
            config.adobeVisitorCustomVisitorId = it
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tealium_adobevisitor")
        channel.setMethodCallHandler(this)

        TealiumPlugin.registerOptionalModule(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "configure" -> configure(call)
            "linkEcidToKnownIdentifier" -> linkEcidToKnownIdentifier(call, result)
            "getAdobeVisitor" -> getAdobeVisitor(result)
            "resetVisitor" -> resetVisitor(result)
            "decorateUrl" -> decorateUrl(call, result)
            else -> result.onMain().notImplemented()
        }
    }

    fun configure(call: MethodCall) {
        call.argument<String>("adobeVisitorOrgId")?.let {
            adobeVisitorOrgId = it
        }
        call.argument<String>("adobeVisitorExistingEcid")?.let {
            adobeVisitorExistingEcid = it
        }
        call.argument<Int>("adobeVisitorRetries")?.let {
            adobeVisitorRetries = it
        }
        call.argument<Int>("adobeVisitorAuthState")?.let {
            adobeVisitorAuthState = it
        }
        call.argument<String>("adobeVisitorDataProviderId")?.let {
            adobeVisitorDataProviderId = it
        }
        call.argument<String>("adobeVisitorCustomVisitorId")?.let {
            adobeVisitorCustomVisitorId = it
        }
    }

    fun linkEcidToKnownIdentifier(call: MethodCall, result: MethodChannel.Result) {
        val knownId = call.argument<String>("knownId")
        val adobeDataProviderId = call.argument<String>("adobeDataProviderId")
        val authState = call.argument<Int>("authState")

        if (knownId == null || adobeDataProviderId == null) {
            result.error("InvalidArgument", "knownId and adobeDataProviderId cannot be null.", null)
            return
        }

        adobeVisitorApi?.linkEcidToKnownIdentifier(
            knownId,
            adobeDataProviderId,
            authState,
            object : ResponseListener<AdobeVisitor> {
                override fun failure(errorCode: Int, ex: Exception?) {
                    result.error(
                        errorCode.toString(),
                        "Exception linking known Ecid: ${ex?.message}",
                        null
                    )
                }

                override fun success(data: AdobeVisitor) {
                    result.success(data.asMap())
                }
            }
        )
    }

    fun getAdobeVisitor(result: MethodChannel.Result) {
        adobeVisitorApi?.visitor?.let { adobeVisitor ->
            result.success(adobeVisitor.asMap())
        } ?: result.success(null)
    }

    fun resetVisitor(result: MethodChannel.Result) {
        adobeVisitorApi?.resetVisitor()
        result.success(null)
    }

    fun decorateUrl(call: MethodCall, result: MethodChannel.Result) {
        val urlArg = call.argument<String>("url")
        if (urlArg == null) {
            result.error(
                "InvalidArgument",
                "url parameter is required, and should not be null",
                null
            )
            return
        }

        try {
            val url = URL(urlArg)
            adobeVisitorApi?.decorateUrl(
                url, object : UrlDecoratorHandler {
                    override fun onDecorateUrl(url: URL) {
                        result.success(url.toString())
                    }
                }
            )
        } catch (ex: MalformedURLException) {
            result.error(
                "InvalidArgument",
                "url was malformed: ${ex.message}",
                null
            )
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}