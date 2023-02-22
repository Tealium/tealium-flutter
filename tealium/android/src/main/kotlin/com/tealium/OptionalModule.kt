package com.tealium

import com.tealium.core.TealiumConfig

interface OptionalModule {
    fun configure(config: TealiumConfig)
}