package com.tealium

import android.app.Application
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.tealium.core.LogLevel
import com.tealium.core.Logger
import com.tealium.core.Tealium
import com.tealium.core.consent.ConsentCategory
import com.tealium.core.consent.ConsentStatus
import com.tealium.remotecommanddispatcher.remoteCommands

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import org.json.JSONArray
import java.util.*
import kotlin.collections.ArrayList

/** TealiumPlugin */
class TealiumPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var tealium: Tealium? = null
    private var context: Context? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tealium")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "terminateInstance" -> terminate()
            "track" -> track(call)
            "addToDataLayer" -> addToDataLayer(call, result)
            "getFromDataLayer" -> getFromDataLayer(call, result)
            "removeFromDataLayer" -> removeFromDataLayer(call)
            "setConsentStatus" -> setConsentStatus(call)
            "getConsentStatus" -> getConsentStatus(result)
            "setConsentCategories" -> setConsentCategories(call)
            "getConsentCategories" -> getConsentCategories(result)
            "addRemoteCommand" -> addRemoteCommand(call)
            "removeRemoteCommand" -> removeRemoteCommand(call)
            "joinTrace" -> joinTrace(call)
            "leaveTrace" -> leaveTrace()
            "getVisitorId" -> getVisitorId(result)
            "resetVisitorId" -> resetVisitorId()
            "clearStoredVisitorIds" -> clearStoredVisitorIds()
            "setConsentExpiryListener" -> {
                /** do nothing **/
            }
            "gatherTrackData" -> gatherTrackData(result)
            else -> result.onMain().notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initialize(call: MethodCall, result: Result) {
        val args = call.arguments as Map<*, *>
        toTealiumConfig(context as Application, args)?.let { config ->

            tealium = Tealium.create(INSTANCE_NAME, config) {
                // Log Level
                args[KEY_LOG_LEVEL]?.let { logLevel ->
                    (logLevel as? String)?.let {
                        Logger.logLevel = LogLevel.fromString(it)
                    }
                }

                args[KEY_REMOTE_COMMANDS]?.let { remoteCommands ->
                    (remoteCommands as? List<Map<*, *>>)?.forEach {
                        (it["id"] as? String)?.let { id ->
                            val path = it["path"] as? String?
                            val url = it["url"] as? String?

                            addRemoteCommand(id, path, url)
                        }
                    }
                }

                Log.d(BuildConfig.TAG, "Instance Initialized")
                events.subscribe(EmitterListeners(channel))
                result.onMain().success(true)
            }
        } ?: run {
            Log.w(BuildConfig.TAG, "Failed to initialize instance.")
            Handler(Looper.getMainLooper()).post {
                result.onMain().success(false) // todo: should this use .error() instead?
            }
        }
    }

    private fun terminate() {
        Tealium.destroy(INSTANCE_NAME)
    }

    private fun track(call: MethodCall) {
        call.arguments<Map<*, *>>()?.let { map ->
            dispatchFromArguments(map).let {
                tealium?.track(it)
            }
        }
    }

    private fun addToDataLayer(call: MethodCall, result: Result) {
        val data = call.argument<Map<String, Any>>("data")
        val expiry = call.argument<String>("expiry")

        tealium?.apply {
            data?.forEach { (key, value) ->
                val exp = expiryFromString(expiry)
                when (value) {
                    is String -> dataLayer.putString(key, value, exp)
                    is Int -> dataLayer.putInt(key, value, exp)
                    is Long -> dataLayer.putLong(key, value, exp)
                    is Double -> dataLayer.putDouble(key, value, exp)
                    is Boolean -> dataLayer.putBoolean(key, value, exp)
                    is JSONObject -> tealium?.dataLayer?.putJsonObject(key, value, exp)
                    is ArrayList<*> -> {
                        when (value.toList().first()) {
                            is Int -> {
                                val formatted = value.toList()
                                    .map { i -> i.toString().toInt() }
                                    .toTypedArray()
                                tealium?.dataLayer?.putIntArray(key, formatted, exp)
                            }
                            is Boolean -> {
                                val formatted = value.toList()
                                    .map { i -> i.toString().toBoolean() }
                                    .toTypedArray()
                                tealium?.dataLayer?.putBooleanArray(key, formatted, exp)
                            }
                            is Long -> {
                                val formatted = value.toList()
                                    .map { i -> i.toString().toLong() }
                                    .toTypedArray()
                                tealium?.dataLayer?.putLongArray(key, formatted, exp)
                            }
                            is Double -> {
                                val formatted = value.toList()
                                    .map { i -> i.toString().toDouble() }
                                    .toTypedArray()
                                tealium?.dataLayer?.putDoubleArray(key, formatted, exp)
                            }
                            else -> {
                                val formatted = value.toList()
                                    .map { i -> i.toString() }
                                    .toTypedArray()
                                tealium?.dataLayer?.putStringArray(key, formatted, exp)
                            }
                        }
                    }
                }
            }
        }
    }

    private fun getFromDataLayer(call: MethodCall, result: Result) {
        val key = call.argument<String>("key")
        key?.let {
            tealium?.dataLayer?.all()?.get(it)?.let { data ->
                val payload = when (data) {
                    is Array<*> -> data.toList()
                    is JSONObject -> data.toFriendlyMap()
                    else -> data
                }
                result.onMain().success(payload)
            }
        }
    }

    private fun removeFromDataLayer(call: MethodCall) {
        val keys = call.argument<List<String>>("keys")

        keys?.forEach {
            tealium?.apply {
                dataLayer.remove(it)
            }
        }
    }

    private fun setConsentStatus(call: MethodCall) {
        val status = call.argument<String>("status")

        status?.let {
            tealium?.apply {
                consentManager.userConsentStatus = ConsentStatus.consentStatus(it)
            }
        }
    }

    private fun getConsentStatus(result: Result) {
        result.onMain().success(tealium?.consentManager?.userConsentStatus?.value)
    }

    private fun setConsentCategories(call: MethodCall) {
        val categories = call.argument<List<String>>("categories")
        categories?.let {
            tealium?.apply {
                val categoryStrings = it.toTypedArray()
                consentManager.userConsentCategories =
                    ConsentCategory.consentCategories(categoryStrings.toSet())
            }
        }
    }

    private fun getConsentCategories(result: Result) {
        val categories =
            tealium?.consentManager?.userConsentCategories?.map { it -> it.toString() }?.toList()
        result.onMain().success(categories)
    }

    private fun addRemoteCommand(call: MethodCall) {
        call.argument<String>("id")?.let { id ->
            val path = call.argument<String?>("path")
            val url = call.argument<String?>("url")
            addRemoteCommand(id, path, url)
        }
    }

    private fun addRemoteCommand(id: String, path: String? = null, url: String? = null) {
        tealium?.apply {
            val factory = getRemoteCommandFactory(id)
            val remoteCommand = factory?.create() ?: RemoteCommandListener(channel, id)
            tealium?.remoteCommands?.add(remoteCommand, filename = path, remoteUrl = url)
        }
    }

    private fun removeRemoteCommand(call: MethodCall) {
        val id = call.argument<String>("id")

        id?.let {
            tealium?.remoteCommands?.remove(it)
        }
    }

    private fun joinTrace(call: MethodCall) {
        val traceId = call.argument<String>("id")

        traceId?.let {
            tealium?.apply {
                joinTrace(it)
            }
        }
    }

    private fun leaveTrace() {
        tealium?.apply {
            leaveTrace()
        }
    }

    private fun getVisitorId(result: Result) {
        result.onMain().success(tealium?.visitorId ?: "")
    }

    private fun resetVisitorId() {
        tealium?.apply {
            resetVisitorId()
        }
    }

    private fun clearStoredVisitorIds() {
        tealium?.clearStoredVisitorIds()
    }

    private fun gatherTrackData(result: Result) {
        tealium?.apply {
            val data = gatherTrackData()
            result.success(data.mapValues {
                val value = it.value
                when (value) {
                    is JSONObject -> value.toFriendlyMap()
                    is JSONArray -> value.toFriendlyList().toList()
                    else -> value
                }
            })
        }
    }

    companion object {
        fun invokeOnMain(methodChannel: MethodChannel, listener: String, data: Any?) {
            Handler(Looper.getMainLooper()).post {
                methodChannel.invokeMethod(listener, data)
            }
        }

        private val remoteCommandFactories: MutableMap<String, RemoteCommandFactory> =
            Collections.synchronizedMap(
                mutableMapOf()
            )

        fun registerRemoteCommandFactory(factory: RemoteCommandFactory) {
            remoteCommandFactories[factory.name] = factory
        }

        fun getRemoteCommandFactory(name: String) : RemoteCommandFactory? {
            return remoteCommandFactories[name]
        }
    }
}
