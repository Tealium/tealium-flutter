package com.tealium

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel

fun MethodChannel.Result.onMain(): ResultOnMain {
    return if (this is ResultOnMain) {
        this
    } else {
        ResultOnMain(this)
    }
}

class ResultOnMain internal constructor(private val result: MethodChannel.Result) : MethodChannel.Result {
    private val handler: Handler by lazy {
        Handler(Looper.getMainLooper())
    }

    override fun success(res: Any?) {
        handler.post { result.success(res) }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        handler.post { result.error(errorCode, errorMessage, errorDetails) }
    }

    override fun notImplemented() {
        handler.post { result.notImplemented() }
    }
}