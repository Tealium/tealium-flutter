package com.tealium

import android.app.Application
import android.util.Log
import com.tealium.collectdispatcher.*
import com.tealium.core.*
import com.tealium.core.collection.AppCollector
import com.tealium.core.collection.ConnectivityCollector
import com.tealium.core.collection.DeviceCollector
import com.tealium.core.collection.TimeCollector
import com.tealium.core.consent.*
import com.tealium.core.persistence.Expiry
import com.tealium.dispatcher.Dispatch
import com.tealium.dispatcher.TealiumEvent
import com.tealium.dispatcher.TealiumView
import com.tealium.lifecycle.Lifecycle
import com.tealium.lifecycle.isAutoTrackingEnabled
import com.tealium.remotecommanddispatcher.RemoteCommandDispatcher
import com.tealium.remotecommands.RemoteCommand
import com.tealium.tagmanagementdispatcher.TagManagementDispatcher
import com.tealium.tagmanagementdispatcher.sessionCountingEnabled
import com.tealium.tagmanagementdispatcher.overrideTagManagementUrl
import com.tealium.visitorservice.VisitorProfile
import com.tealium.visitorservice.VisitorService
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import java.util.concurrent.TimeUnit

private fun missingRequiredProperty(name: String) {
    Log.d(BuildConfig.TAG, "Missing required property: $name")
}

fun toTealiumConfig(app: Application, configMap: Map<*, *>): TealiumConfig? {
    val account = configMap[KEY_CONFIG_ACCOUNT] as? String
    val profile = configMap[KEY_CONFIG_PROFILE] as? String
    val environmentString = configMap[KEY_CONFIG_ENV] as? String

    if (account.isNullOrBlank()) {
        missingRequiredProperty(KEY_CONFIG_ACCOUNT)
        return null
    }

    if (profile.isNullOrBlank()) {
        missingRequiredProperty(KEY_CONFIG_PROFILE)
        return null
    }

    val environment = try {
        Environment.valueOf(environmentString?.toUpperCase(Locale.ROOT) ?: "PROD")
    } catch (iax: IllegalArgumentException) {
        missingRequiredProperty(KEY_CONFIG_ENV)
        Environment.PROD
    }

    val collectors = (configMap[KEY_CONFIG_COLLECTORS] as? List<*>)?.toCollectorFactories()
    // Swift has this enabled by default
    collectors?.add(TimeCollector)

    val modules = mutableListOf<Any>().apply {
        (configMap[KEY_VISITOR_SERVICE_ENABLED] as? Boolean)?.let {
            if (it)  add(MODULES_VISITOR_SERVICE)
        }
        (configMap[KEY_CONFIG_COLLECTORS] as? List<*>)?.contains(MODULES_LIFECYCLE)?.let {
            if (it) add(MODULES_LIFECYCLE)
        }
        (configMap[KEY_CONFIG_MODULES] as? List<*>)?.let { modules ->
            val mods = modules.map { it.toString() }.toList()
            addAll(mods)
        }
    }.toModuleFactories()
    val dispatchers = (configMap[KEY_CONFIG_DISPATCHERS] as? List<*>)?.toDispatcherFactories()

    val config = TealiumConfig(app, account, profile, environment,
            collectors = collectors ?: Collectors.core.toMutableSet(),
            modules = modules ?: mutableSetOf(),
            dispatchers = dispatchers ?: mutableSetOf()
    )

    // config overrides
    config.apply {
        // Data Source Id
        configMap[KEY_CONFIG_DATA_SOURCE]?.let {
            dataSourceId = it.toString()
        }

        // Collect Settings
        configMap[KEY_COLLECT_OVERRIDE_URL]?.let {
            overrideCollectUrl = it.toString()
        }
        configMap[KEY_COLLECT_OVERRIDE_BATCH_URL]?.let {
            overrideCollectBatchUrl = it.toString()
        }
        configMap[KEY_COLLECT_OVERRIDE_DOMAIN]?.let {
            overrideCollectDomain = it.toString()
        }
        configMap[KEY_COLLECT_OVERRIDE_PROFILE]?.let {
            overrideCollectProfile = it.toString()
        }

        configMap[KEY_CUSTOM_VISITOR_ID]?.let {
            existingVisitorId = it.toString()
        }

        // Library Settings
        if (configMap.containsKey(KEY_SETTINGS_USE_REMOTE)) {
            useRemoteLibrarySettings = configMap[KEY_SETTINGS_USE_REMOTE].toString().toBoolean()
        }
        configMap[KEY_SETTINGS_OVERRIDE_URL]?.let {
            overrideLibrarySettingsUrl = it as String
        }

        configMap[KEY_SESSION_COUNTING_ENABLED]?.let {
            sessionCountingEnabled = it.toString().toBoolean()
        }

        // Tag Management
        configMap[KEY_TAG_MANAGEMENT_OVERRIDE_URL]?.let {
            overrideTagManagementUrl = it.toString()
        }

        // Deep Links
        if (configMap.containsKey(KEY_QR_TRACE_ENABLED)) {
            qrTraceEnabled = configMap[KEY_QR_TRACE_ENABLED].toString().toBoolean()
        }
        if (configMap.containsKey(KEY_DEEPLINK_TRACKING_ENABLED)) {
            deepLinkTrackingEnabled = configMap[KEY_DEEPLINK_TRACKING_ENABLED].toString().toBoolean()
        }

        // Log Level
        configMap[KEY_LOG_LEVEL]?.let { logLevel ->
            (logLevel as? String)?.let {
                Logger.logLevel = LogLevel.fromString(it)
            }
        }

        // Consent
        if (configMap.containsKey(KEY_CONSENT_LOGGING_ENABLED)) {
            consentManagerLoggingEnabled = configMap[KEY_CONSENT_LOGGING_ENABLED].toString().toBoolean()
        }
        configMap[KEY_CONSENT_LOGGING_URL]?.let {
            consentManagerLoggingUrl = it as String
        }

        configMap[KEY_CONSENT_EXPIRY]?.let {
            (it as? Map<*, *>)?.let { map ->
                map[KEY_CONSENT_EXPIRY_TIME]?.let { time ->
                    map[KEY_CONSENT_EXPIRY_UNIT]?.let { unit ->
                        consentExpiry = consentExpiryFromValues(time.toString().toLong(), unit.toString())
                    }
                }
            }
        }

        configMap[KEY_CONSENT_POLICY]?.let {
            consentManagerEnabled = true
            consentManagerPolicy = consentPolicyFromString(it.toString())
        }

        // Lifecycle
        configMap[KEY_LIFECYCLE_AUTO_TRACKING_ENABLED]?.let { value ->
            isAutoTrackingEnabled = value.toString().toBoolean()
        }

        configMap[KEY_VISITOR_IDENTITY_KEY]?.let { key ->
            config.visitorIdentityKey = key.toString()
        }
    }

    return config
}

fun consentPolicyFromString(name: String): ConsentPolicy? {
    return try {
        ConsentPolicy.valueOf(name.toUpperCase(Locale.ROOT))
    } catch (iax: IllegalArgumentException) {
        null
    }
}

fun consentExpiryFromValues(time: Long, unit: String): ConsentExpiry? {
    if (time <= 0) return null

    val count: Long = if (unit == "months") {
        // No TimeUnit.MONTHS, so needs conversion to days.
        val cal = Calendar.getInstance()
        val today = cal.timeInMillis
        cal.add(Calendar.MONTH, time.toInt())
        (cal.timeInMillis - today) / (1000 * 60 * 60 * 24)
    } else {
        time
    }
    return timeUnitFromString(unit)?.let { ConsentExpiry(count, it) }
}

fun timeUnitFromString(unit: String): TimeUnit? {
    return when (unit) {
        "minutes" -> TimeUnit.MINUTES
        "hours" -> TimeUnit.HOURS
        "days" -> TimeUnit.DAYS
        "months" -> TimeUnit.DAYS
        else -> null
    }
}

fun expiryFromString(name: String?) =
        if (!name.isNullOrBlank()) {
            when (name.toLowerCase(Locale.ROOT)) {
                "forever" -> Expiry.FOREVER
                "untilrestart" -> Expiry.UNTIL_RESTART
                else -> Expiry.SESSION
            }
        } else Expiry.SESSION

fun dispatchFromArguments(data: Map<*, *>): Dispatch {
    val eventType = data[KEY_TRACK_EVENT_TYPE] as String

    return when (eventType.toLowerCase(Locale.ROOT)) {
        DispatchType.VIEW -> TealiumView((data[KEY_TRACK_VIEW_NAME] as String)
                ?: DispatchType.VIEW,
                data[KEY_TRACK_DATALAYER] as Map<String, Any>
        )
        else -> TealiumEvent((data[KEY_TRACK_EVENT_NAME] as String)
                ?: DispatchType.EVENT,
                data[KEY_TRACK_DATALAYER] as Map<String, Any>
        )
    }
}

fun List<*>.toCollectorFactories(): MutableSet<CollectorFactory>? {
    return toTypedArray().mapNotNull { collectorFactoryFromString(it.toString()) }.toMutableSet()
}

fun collectorFactoryFromString(name: String): CollectorFactory? {
    return when (name) {
        COLLECTORS_APP -> AppCollector
        COLLECTORS_CONNECTIVITY -> ConnectivityCollector
        COLLECTORS_DEVICE -> DeviceCollector
        COLLECTORS_TIME -> TimeCollector
        else -> null
    }
}

fun List<*>.toModuleFactories(): MutableSet<ModuleFactory>? {
    return toTypedArray().mapNotNull { moduleFactoryFromString(it.toString()) }.toMutableSet()
}

fun moduleFactoryFromString(name: String): ModuleFactory? {
    return when (name) {
        MODULES_LIFECYCLE -> Lifecycle
        MODULES_VISITOR_SERVICE -> VisitorService
        else -> null
    }
}

fun List<*>.toDispatcherFactories(): MutableSet<DispatcherFactory>? {
    return toTypedArray().mapNotNull { dispatcherFactoryFromString(it.toString()) }.toMutableSet()
}

fun dispatcherFactoryFromString(name: String): DispatcherFactory? {
    return when (name) {
        DISPATCHERS_COLLECT -> CollectDispatcher
        DISPATCHERS_TAG_MANAGEMENT -> TagManagementDispatcher
        DISPATCHERS_REMOTE_COMMANDS -> RemoteCommandDispatcher
        else -> null
    }
}

@Throws(JSONException::class)
fun JSONObject.toFriendlyMap(): MutableMap<String, Any?> {
    val map = mutableMapOf<String, Any?>()
    val iterator = keys()
    while (iterator.hasNext()) {
        val key = iterator.next()
        when (val value = this[key]) {
            is JSONObject -> {
                map[key] = value.toFriendlyMap()
            }
            is JSONArray -> {
                map[key] = value.toFriendlyList().toList()
            }
            else -> {
                map[key] = value
            }
        }
    }
    return map
}

@Throws(JSONException::class)
fun JSONArray.toFriendlyList(): MutableList<Any?> {
    val list = mutableListOf<Any?>()
    for (i in 0 until length()) {
        when (val value = this[i]) {
            is JSONObject -> {
                list.add(value.toFriendlyMap())
            }
            is JSONArray -> {
                list.add(value.toFriendlyList())
            }
            is Boolean, is Int, is Double, is String -> {
                list.add(value)
            }
            else -> {
                list.add(value.toString())
            }
        }
    }
    return list
}

internal fun VisitorProfile.Companion.toFriendlyMutableMap(visitorProfile: VisitorProfile): MutableMap<String, Any> {
    val visit = mutableMapOf<String, Any>()

    visitorProfile.currentVisit?.let { current ->
        current.dates?.let {
            visit["dates"] = it
        }
        current.booleans?.let {
            visit["booleans"] = it
        }
        current.arraysOfBooleans?.let {
            visit["arraysOfBooleans"] = it
        }
        current.numbers?.let {
            visit["numbers"] = it
        }
        current.arraysOfNumbers?.let {
            visit["arraysOfNumbers"] = it
        }
        current.tallies?.let {
            visit["tallies"] = it
        }
        current.strings?.let {
            visit["strings"] = it
        }
        current.arraysOfStrings?.let {
            visit["arraysOfStrings"] = it
        }
        current.setsOfStrings?.let {
            visit["setsOfStrings"] = it.map { (key, value) -> value.toList() }
        }
    }

    val visitor = mutableMapOf<String, Any>()
    visitorProfile.audiences?.let {
        visitor["audiences"] = it
    }
    visitorProfile.badges?.let {
        visitor["badges"] = it
    }
    visitorProfile.dates?.let {
        visitor["dates"] = it
    }
    visitorProfile.booleans?.let {
        visitor["booleans"] = it
    }
    visitorProfile.arraysOfBooleans?.let {
        visitor["arraysOfBooleans"] = it
    }
    visitorProfile.numbers?.let {
        visitor["numbers"] = it
    }
    visitorProfile.arraysOfNumbers?.let {
        visitor["arraysOfNumbers"] = it
    }
    visitorProfile.tallies?.let {
        visitor["tallies"] = it
    }
    visitorProfile.strings?.let {
        visitor["strings"] = it
    }
    visitorProfile.arraysOfStrings?.let {
        visitor["arraysOfStrings"] = it
    }
    visitorProfile.setsOfStrings?.let {
        visitor["setsOfStrings"] = it.map { (key, value) -> value.toList() }
    }
    visitor["currentVisit"] = visit

    return visitor
}