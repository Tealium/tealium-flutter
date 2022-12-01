package com.tealium

import com.tealium.core.Logger
import com.tealium.core.consent.ConsentManagementPolicy
import com.tealium.core.consent.ConsentStatus
import com.tealium.core.consent.UserConsentPreferences
import com.tealium.core.messaging.UserConsentPreferencesUpdatedListener
import com.tealium.remotecommands.RemoteCommand
import com.tealium.visitorservice.VisitorProfile
import com.tealium.visitorservice.VisitorUpdatedListener
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException

class EmitterListeners(private val methodChannel: MethodChannel) : VisitorUpdatedListener, UserConsentPreferencesUpdatedListener {
    override fun onVisitorUpdated(visitorProfile: VisitorProfile) {
        try {
            VisitorProfile.toFriendlyMutableMap(visitorProfile).let {
                it["emitterName"] = "TealiumFlutter.VisitorServiceEvent"
                TealiumPlugin.invokeOnMain(methodChannel, "callListener", it.toMap())
            }
        } catch (jex: JSONException) {
            Logger.qa(BuildConfig.TAG, "${jex.message}")
        }
    }

    override fun onUserConsentPreferencesUpdated(userConsentPreferences: UserConsentPreferences, policy: ConsentManagementPolicy) {
        if (userConsentPreferences.consentStatus != ConsentStatus.UNKNOWN) return

        TealiumPlugin.invokeOnMain(methodChannel, "callListener", mapOf("emitterName" to "TealiumFlutter.ConsentExpiredEvent"))
    }
}

class RemoteCommandListener(private val methodChannel: MethodChannel, id: String, description: String = id) : RemoteCommand(id, description) {
    public override fun onInvoke(response: Response) {
        response.requestPayload.put("emitterName", "TealiumFlutter.RemoteCommandEvent")
        response.requestPayload.put("command_id", commandName)
        try {
            val map = response.requestPayload.toFriendlyMap()
            TealiumPlugin.invokeOnMain(methodChannel, "callListener", map.toMap())
        } catch (jex: JSONException) {
            Logger.qa(BuildConfig.TAG, "${jex.message}")
        }
        response.send()
    }
}