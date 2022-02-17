package com.puzzl.chromecast

import android.content.Context
import android.view.ContextThemeWrapper
import androidx.mediarouter.app.MediaRouteButton
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.MediaLoadOptions
import com.google.android.gms.cast.framework.*
import com.google.android.gms.common.api.PendingResult
import com.google.android.gms.common.api.Status
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class ChromeCastController(
    messenger: BinaryMessenger,
    viewId: Int,
    context: Context?
) : PlatformView, MethodChannel.MethodCallHandler, SessionManagerListener<Session>, PendingResult.StatusListener {
    private val channel = MethodChannel(messenger, "flutter_video_cast/chromeCast_$viewId")
    private val chromeCastButton = MediaRouteButton(ContextThemeWrapper(context, R.style.CastExpandedController))
    private val sessionManager:SessionManager? = CastContext.getSharedInstance()?.sessionManager

    init {

        CastButtonFactory.setUpMediaRouteButton(context!!, chromeCastButton)

        channel.setMethodCallHandler(this)
    }

    private fun loadMedia(args: Any?) {
        if (args is Map<*, *>) {
            val url = args["url"] as String
            val autoPlay = (args["autoPlay"] as? Boolean)?:false
            val startPosition =(args["startPosition"] as? Int)?:0
            val media = MediaInfo.Builder(url).build()
            val options = MediaLoadOptions.Builder().setAutoplay(autoPlay).setPlayPosition(startPosition.toLong()).build()
            val request = sessionManager?.currentCastSession?.remoteMediaClient?.load(media, options)
            request?.addStatusListener(this)

        }
    }

    private fun play() {
        val request = sessionManager?.currentCastSession?.remoteMediaClient?.play()
        request?.addStatusListener(this)
    }

    private fun pause() {
        val request = sessionManager?.currentCastSession?.remoteMediaClient?.pause()
        request?.addStatusListener(this)
    }

    private fun seek(args: Any?) {
        if (args is Map<*, *>) {
            val relative = (args["relative"] as? Boolean) ?: false
            var interval = args["interval"] as? Int?:0
            interval = interval?.times(1000)
            if (relative) {
                interval = interval?.plus(sessionManager?.currentCastSession?.remoteMediaClient?.mediaStatus?.streamPosition ?: 0)
                    .toInt()
            }
            val request = sessionManager?.currentCastSession?.remoteMediaClient?.seek(interval.toLong())
            request?.addStatusListener(this)
        }
    }

    private fun setVolume(args: Any?) {
        if (args is Map<*, *>) {
            val volume = args["volume"] as? Double
            val request = sessionManager?.currentCastSession?.remoteMediaClient?.setStreamVolume(volume ?: 0.0)
            request?.addStatusListener(this)
        }
    }

    private fun getVolume() = sessionManager?.currentCastSession?.volume ?: 0.0

    private fun stop() {
        val request = sessionManager?.currentCastSession?.remoteMediaClient?.stop()
        request?.addStatusListener(this)
    }

    private fun isPlaying() = sessionManager?.currentCastSession?.remoteMediaClient?.isPlaying?:false

    private fun isConnected() = sessionManager?.currentCastSession?.isConnected ?: false

    private fun endSession() = sessionManager?.endCurrentSession(true)

    private fun position() = sessionManager?.currentCastSession?.remoteMediaClient?.approximateStreamPosition ?: 0

    private fun duration() = sessionManager?.currentCastSession?.remoteMediaClient?.mediaInfo?.streamDuration ?: 0
    private fun isFinished()= sessionManager?.currentCastSession?.remoteMediaClient?.currentItem==null

    private fun addSessionListener() {
        sessionManager?.addSessionManagerListener(this)
    }

    private fun removeSessionListener() {
        sessionManager?.removeSessionManagerListener(this)
    }

    override fun getView() = chromeCastButton

    override fun dispose() {

    }

    // Flutter methods handling

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "chromeCast#wait" -> result.success(null)
            "chromeCast#loadMedia" -> {
                loadMedia(call.arguments)
                result.success(null)
            }
            "chromeCast#play" -> {
                if(!isFinished()) {
                    play()
                }
                result.success(null)
            }
            "chromeCast#pause" -> {
                pause()
                result.success(null)
            }

            "chromeCast#seek" -> {
                seek(call.arguments)
                result.success(null)
            }
            "chromeCast#setVolume" -> {
                setVolume(call.arguments)
                result.success(null)
            }
            "chromeCast#getVolume" -> result.success(getVolume())
            "chromeCast#stop" -> {
                stop()
                result.success(null)
            }
            "chromeCast#isPlaying" -> result.success(isPlaying())
            "chromeCast#isConnected" -> result.success(isConnected())
            "chromeCast#endSession" -> {
                endSession()
                result.success(null)
            }

            "chromeCast#position" -> result.success(position())
            "chromeCast#duration" -> result.success(duration())
            "chromeCast#addSessionListener" -> {
                addSessionListener()
                result.success(null)
            }
            "chromeCast#removeSessionListener" -> {
                removeSessionListener()
                result.success(null)
            }
            "chromeCast#isFinished"->{
                result.success(isFinished())
            }
        }
    }

    // SessionManagerListener

    override fun onSessionStarted(p0: Session, p1: String) {
        channel.invokeMethod("chromeCast#didStartSession", null)
    }

    override fun onSessionEnded(p0: Session, p1: Int) {

        channel.invokeMethod("chromeCast#didEndSession", null)
    }

    override fun onSessionResuming(p0: Session, p1: String) {

    }

    override fun onSessionResumed(p0: Session, p1: Boolean) {
        print("resumindo");
    }

    override fun onSessionResumeFailed(p0: Session, p1: Int) {

    }

    override fun onSessionSuspended(p0: Session, p1: Int) {
    print("stoped")

    }

    override fun onSessionStarting(p0: Session) {

    }

    override fun onSessionEnding(p0: Session) {
        print("finalizando");
    }

    override fun onSessionStartFailed(p0: Session, p1: Int) {

    }

    // PendingResult.StatusListener

    override fun onComplete(status: Status) {
        if (status?.isSuccess == true) {
            channel.invokeMethod("chromeCast#requestDidComplete", null)
        }
    }
}