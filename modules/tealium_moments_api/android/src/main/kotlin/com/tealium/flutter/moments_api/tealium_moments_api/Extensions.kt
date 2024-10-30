package com.tealium.flutter.moments_api.tealium_moments_api

import com.tealium.momentsapi.EngineResponse
import com.tealium.momentsapi.MomentsApiRegion
import org.json.JSONObject

// Extension function to convert EngineResponse to a Map that Flutter can understand.
fun EngineResponse.toMap(): Map<String, Any> {
    return EngineResponse.toFriendlyJson(this).toMap()
}

// Function to convert a region string to MomentsApiRegion enum.
fun regionFromString(region: String): MomentsApiRegion {
    return when (region.lowercase()) {
        "germany" -> MomentsApiRegion.Germany
        "us_east" -> MomentsApiRegion.UsEast
        "sydney" -> MomentsApiRegion.Sydney
        "oregon" -> MomentsApiRegion.Oregon
        "tokyo" -> MomentsApiRegion.Tokyo
        "hong_kong" -> MomentsApiRegion.HongKong
        else -> MomentsApiRegion.Custom(region)
    }
}

// Mapping of internal response names to more user-friendly names.
private val engineResponseFriendlyNames = mapOf<String, String>(
    "flags" to "booleans",
    "metrics" to "numbers",
    "properties" to "strings"
)

// Function to convert EngineResponse to a more user-friendly JSON format.
internal fun EngineResponse.Companion.toFriendlyJson(engineResponse: EngineResponse): JSONObject {
    return toJson(engineResponse).let { engineJson ->
        engineJson.apply {
            // Rename the top-level keys for readability.
            this.renameAll(engineResponseFriendlyNames)
        }
    }
}

// Helper function to rename multiple keys in a JSONObject.
internal fun JSONObject.renameAll(names: Map<String, String>) {
    names.entries.forEach { entry ->
        this.rename(entry.key, entry.value)
    }
}

// Helper function to rename a specific key in a JSONObject.
internal fun JSONObject.rename(oldKey: String, newKey: String) {
    this.opt(oldKey)?.let {
        this.put(newKey, it)
        this.remove(oldKey)
    }
}

// Convert a JSONObject to a Map<String, Any> for use in Flutter.
fun JSONObject.toMap(): Map<String, Any> {
    val map = mutableMapOf<String, Any>()
    val keys = keys()

    while (keys.hasNext()) {
        val key = keys.next()
        val value = this.get(key)
        map[key] = when (value) {
            is JSONObject -> value.toMap()
            is org.json.JSONArray -> {
                val list = mutableListOf<Any>()
                for (i in 0 until value.length()) {
                    list.add(value.get(i))
                }
                list
            }
            else -> value
        }
    }
    return map
}