package com.tealium

import android.app.Activity
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
import com.tealium.lifecycle.lifecycle
import com.tealium.remotecommanddispatcher.remoteCommands

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import org.json.JSONArray
import java.util.*
import kotlin.collections.List

/** TealiumPlugin */
class TealiumPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var tealium: Tealium? = null
    private var context: Context? = null

    private var sentLaunchActivity = false
    private var launchActivity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tealium")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }
    
    /**
     * Helper to get Tealium instance or send error if not initialized.
     * Returns null if Tealium is not initialized (error is sent to result).
     */
    private fun requireTealium(result: Result): Tealium? {
        return tealium ?: run {
            result.onMain().error(TealiumError.NOT_INITIALIZED, TealiumError.NOT_INITIALIZED_MSG, null)
            null
        }
    }

    /**
     * Helper to get a required parameter or send error if null.
     * Returns the value if non-null, otherwise sends error to result and returns null.
     */
    private fun <T> requireParam(
        value: T?,
        result: Result,
        paramName: String,
        message: String = "$paramName parameter is required"
    ): T? {
        return value ?: run {
            result.onMain().error(TealiumError.MISSING_PARAMETER, message, null)
            null
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "terminateInstance" -> terminate(result)
            "track" -> track(call, result)
            "addToDataLayer" -> addToDataLayer(call, result)
            "getFromDataLayer" -> getFromDataLayer(call, result)
            "removeFromDataLayer" -> removeFromDataLayer(call, result)
            "setConsentStatus" -> setConsentStatus(call, result)
            "getConsentStatus" -> getConsentStatus(result)
            "setConsentCategories" -> setConsentCategories(call, result)
            "getConsentCategories" -> getConsentCategories(result)
            "addRemoteCommand" -> addRemoteCommand(call, result)
            "removeRemoteCommand" -> removeRemoteCommand(call, result)
            "joinTrace" -> joinTrace(call, result)
            "leaveTrace" -> leaveTrace(result)
            "getVisitorId" -> getVisitorId(result)
            "resetVisitorId" -> resetVisitorId(result)
            "clearStoredVisitorIds" -> clearStoredVisitorIds(result)
            "setConsentExpiryListener" -> setConsentExpiryListener(result)
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

            getOptionalModules().forEach { module ->
                module.configure(config)
            }

            tealium = Tealium.create(INSTANCE_NAME, config) {
                if (!sentLaunchActivity) {
                    // Some cases miss the first Activity
                    lifecycle?.apply {
                        onActivityResumed(launchActivity)
                    }

                    sentLaunchActivity = true
                    launchActivity = null
                }

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

                            addRemoteCommand(this, id, path, url)
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
                result.onMain().error(TealiumError.MISSING_PARAMETER, "Invalid or missing configuration", null)
            }
        }
    }

    private fun terminate(result: Result) {
        Tealium.destroy(INSTANCE_NAME)
        tealium = null
        result.onMain().success(null)
    }

    private fun track(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val map = requireParam(
            call.arguments<Map<*, *>>(),
            result,
            "Track dispatch data",
            "Track dispatch data is required"
        ) ?: return

        dispatchFromArguments(map).let {
            tealium.track(it)
        }
        result.onMain().success(null)
    }

    private fun addToDataLayer(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val data = requireParam(call.argument<Map<String, Any>>("data"), result, "Data") ?: return
        val expiry = call.argument<String>("expiry")

        data.forEach { (key, value) ->
            val exp = expiryFromString(expiry)
            when (value) {
                is String -> tealium.dataLayer.putString(key, value, exp)
                is Int -> tealium.dataLayer.putInt(key, value, exp)
                is Long -> tealium.dataLayer.putLong(key, value, exp)
                is Double -> tealium.dataLayer.putDouble(key, value, exp)
                is Boolean -> tealium.dataLayer.putBoolean(key, value, exp)
                is JSONObject -> tealium.dataLayer.putJsonObject(key, value, exp)
                is List<*> -> {
                    when (value.toList().first()) {
                        is Int -> {
                            val formatted = value.toList()
                                .map { i -> i.toString().toInt() }
                                .toTypedArray()
                            tealium.dataLayer.putIntArray(key, formatted, exp)
                        }
                        is Boolean -> {
                            val formatted = value.toList()
                                .map { i -> i.toString().toBoolean() }
                                .toTypedArray()
                            tealium.dataLayer.putBooleanArray(key, formatted, exp)
                        }
                        is Long -> {
                            val formatted = value.toList()
                                .map { i -> i.toString().toLong() }
                                .toTypedArray()
                            tealium.dataLayer.putLongArray(key, formatted, exp)
                        }
                        is Double -> {
                            val formatted = value.toList()
                                .map { i -> i.toString().toDouble() }
                                .toTypedArray()
                            tealium.dataLayer.putDoubleArray(key, formatted, exp)
                        }
                        else -> {
                            val formatted = value.toList()
                                .map { i -> i.toString() }
                                .toTypedArray()
                            tealium.dataLayer.putStringArray(key, formatted, exp)
                        }
                    }
                }
            }
        }
        result.onMain().success(null)
    }

    private fun getFromDataLayer(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val key = requireParam(call.argument<String>("key"), result, "Key") ?: return

        val data = tealium.dataLayer.get(key)
        val payload = when (data) {
            is Array<*> -> data.toList()
            is JSONObject -> data.toFriendlyMap()
            else -> data
        }
        result.onMain().success(payload)
    }

    private fun removeFromDataLayer(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val keys = requireParam(call.argument<List<String>>("keys"), result, "Keys") ?: return

        keys.forEach { tealium.dataLayer.remove(it) }
        result.onMain().success(null)
    }

    private fun setConsentStatus(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val status = requireParam(call.argument<String>("status"), result, "Status") ?: return

        tealium.consentManager.userConsentStatus = ConsentStatus.consentStatus(status)
        result.onMain().success(null)
    }

    private fun getConsentStatus(result: Result) {
        val tealium = requireTealium(result) ?: return
        result.onMain().success(tealium.consentManager.userConsentStatus.value)
    }

    private fun setConsentCategories(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val categories = requireParam(call.argument<List<String>>("categories"), result, "Categories") ?: return

        val categoryStrings = categories.toTypedArray()
        tealium.consentManager.userConsentCategories =
            ConsentCategory.consentCategories(categoryStrings.toSet())
        result.onMain().success(null)
    }

    private fun getConsentCategories(result: Result) {
        val tealium = requireTealium(result) ?: return
        val categories = tealium.consentManager.userConsentCategories?.map { it.toString() }?.toList()
        result.onMain().success(categories)
    }

    private fun addRemoteCommand(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val id = requireParam(call.argument<String>("id"), result, "ID") ?: return
        val path = call.argument<String?>("path")
        val url = call.argument<String?>("url")
        addRemoteCommand(tealium, id, path, url)
        result.onMain().success(null)
    }

    private fun addRemoteCommand(tealium: Tealium, id: String, path: String? = null, url: String? = null) {
        val factory = getRemoteCommandFactory(id)
        val remoteCommand = factory?.create() ?: RemoteCommandListener(channel, id)
        tealium.remoteCommands?.add(remoteCommand, filename = path, remoteUrl = url)
    }

    private fun removeRemoteCommand(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val id = requireParam(call.argument<String>("id"), result, "ID") ?: return

        tealium.remoteCommands?.remove(id)
        result.onMain().success(null)
    }

    private fun joinTrace(call: MethodCall, result: Result) {
        val tealium = requireTealium(result) ?: return
        val traceId = requireParam(call.argument<String>("id"), result, "Trace ID") ?: return

        tealium.joinTrace(traceId)
        result.onMain().success(null)
    }

    private fun leaveTrace(result: Result) {
        val tealium = requireTealium(result) ?: return
        tealium.leaveTrace()
        result.onMain().success(null)
    }

    private fun getVisitorId(result: Result) {
        val tealium = requireTealium(result) ?: return
        result.onMain().success(tealium.visitorId)
    }

    private fun resetVisitorId(result: Result) {
        val tealium = requireTealium(result) ?: return
        tealium.resetVisitorId()
        result.onMain().success(null)
    }

    private fun clearStoredVisitorIds(result: Result) {
        val tealium = requireTealium(result) ?: return
        tealium.clearStoredVisitorIds()
        result.onMain().success(null)
    }

    private fun setConsentExpiryListener(result: Result) {
        val tealium = requireTealium(result) ?: return
        // Consent expiry is handled via the EmitterListeners (UserConsentPreferencesUpdatedListener)
        // which is set up during initialization
        result.onMain().success(null)
    }

    private fun gatherTrackData(result: Result) {
        val tealium = requireTealium(result) ?: return
        val data = tealium.gatherTrackData()
        result.success(data.mapValues { it.value.toFlutterCompatibleValue() })
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (launchActivity == null && !sentLaunchActivity) {
            launchActivity = binding.activity
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
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

        private val optionalModules: MutableList<OptionalModule> =
            Collections.synchronizedList(
                mutableListOf()
            )

        fun registerOptionalModule(module: OptionalModule) {
            optionalModules.add(module)
        }

        fun getOptionalModules() : List<OptionalModule> {
            return optionalModules.toList()
        }
    }
}
