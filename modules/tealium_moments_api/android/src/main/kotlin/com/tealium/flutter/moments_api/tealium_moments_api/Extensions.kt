package com.tealium.flutter.moments_api.tealium_moments_api

import com.tealium.momentsapi.EngineResponse
import com.tealium.momentsapi.MomentsApiRegion

/**
 * Conversion function returning all sets of values that aren't null to the user.
 **/
fun EngineResponse.toMap(): Map<String, Any> {
    val responseMutableMap = mutableMapOf<String, Any>()

    audiences?.let { responseMutableMap.put("audiences", it) }
    badges?.let { responseMutableMap.put("badges", it) }
    booleans?.let { responseMutableMap.put("booleans", it) }
    dates?.let { responseMutableMap.put("dates", it) }
    numbers?.let { responseMutableMap.put("numbers", it) }
    strings?.let { responseMutableMap.put("strings", it) }

    return responseMutableMap
}

/**
 * Function to convert a region string to MomentsApiRegion enum.
 **/
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