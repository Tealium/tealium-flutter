package com.tealium.flutter.modules.adobevisitor

import com.tealium.adobe.api.AdobeVisitor


fun AdobeVisitor.asMap() : Map<String, Any> {
    return mapOf(
        "experienceCloudId" to this.experienceCloudId,
        "idSyncTtl" to this.idSyncTTL,
        "region" to this.region,
        "blob" to this.blob,
        "nextRefresh" to this.nextRefresh.time,
    )
}