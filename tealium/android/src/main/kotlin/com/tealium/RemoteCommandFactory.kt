package com.tealium

import com.tealium.remotecommands.RemoteCommand

interface RemoteCommandFactory {
    val name: String
    fun create() : RemoteCommand
}