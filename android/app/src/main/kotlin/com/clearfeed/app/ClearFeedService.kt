package com.clearfeed.app

import android.accessibilityservice.AccessibilityService
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Rect
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import androidx.core.app.NotificationCompat

class ClearFeedService : AccessibilityService() {

    private var lastBlockTime = 0L
    private val cooldown = 1000L
    private lateinit var prefs: SharedPreferences

    private val targetPackages = setOf(
        "com.google.android.youtube",
        "com.instagram.android",
        "com.facebook.katana",
        "com.zhiliaoapp.musically",
        "com.snapchat.android",
        "com.twitter.android",
        "com.x.android",
        "com.reddit.frontpage"
    )

    // YouTube Shorts IDs
    private val youtubeShorts = listOf(
        "com.google.android.youtube:id/reel_recycler",
        "com.google.android.youtube:id/shorts_container",
        "com.google.android.youtube:id/reel_player_page_container",
        "com.google.android.youtube:id/shorts_pivot_item",
        "com.google.android.youtube:id/reel_player_underlay"
    )

    // Instagram Reels IDs
    private val instagramReels = listOf(
        "com.instagram.android:id/clips_viewer_view_pager",
        "com.instagram.android:id/reels_viewer_container",
        "com.instagram.android:id/clips_tab",
        "com.instagram.android:id/clips_viewer",
        "com.instagram.android:id/unified_clips_module"
    )

    // Facebook Reels IDs
    private val facebookReels = listOf(
        "com.facebook.katana:id/reels_viewer_pager",
        "com.facebook.katana:id/reels_container",
        "com.facebook.katana:id/video_timeline_component",
        "com.facebook.katana:id/reel_viewer_page_container"
    )

    // Snapchat Spotlight IDs
    private val snapchatSpotlight = listOf(
        "com.snapchat.android:id/spotlight_feed_recycler_view",
        "com.snapchat.android:id/spotlight_container",
        "com.snapchat.android:id/discover_feed_item_spotlight"
    )

    // X/Twitter video IDs
    private val xVideoFeed = listOf(
        "com.twitter.android:id/reel_player_container",
        "com.twitter.android:id/channels_view_pager",
        "com.x.android:id/reel_player_container",
        "com.x.android:id/channels_view_pager"
    )

    // Reddit video IDs
    private val redditVideoFeed = listOf(
        "com.reddit.frontpage:id/reel_player",
        "com.reddit.frontpage:id/video_feed_container",
        "com.reddit.frontpage:id/reels_view_pager",
        "com.reddit.frontpage:id/scroll_container"
    )

    override fun onServiceConnected() {
        super.onServiceConnected()
        prefs = getSharedPreferences("clearfeed_prefs", Context.MODE_PRIVATE)
        startForegroundSilent()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        val pkg = event.packageName?.toString() ?: return
        if (pkg !in targetPackages) return

        // Check if this app is toggled on
        val appName = packageToAppName(pkg)
        val isEnabled = prefs.getBoolean("toggle_$appName", true)
        if (!isEnabled) return

        val now = System.currentTimeMillis()
        if (now - lastBlockTime < cooldown) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                if (shouldBlock(pkg, event)) {
                    lastBlockTime = now
                    performGlobalAction(GLOBAL_ACTION_BACK)
                    incrementBlockCount(appName)
                }
            }
            AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
                if (pkg == "com.zhiliaoapp.musically" && isTikTokVideoFeed(event)) {
                    lastBlockTime = now
                    performGlobalAction(GLOBAL_ACTION_BACK)
                    incrementBlockCount(appName)
                }
            }
        }
    }

    private fun shouldBlock(pkg: String, event: AccessibilityEvent): Boolean {
        val root = rootInActiveWindow ?: return false
        val result = when (pkg) {
            "com.google.android.youtube" -> checkIds(root, youtubeShorts, event)
            "com.instagram.android" -> checkIds(root, instagramReels, event)
            "com.facebook.katana" -> checkIds(root, facebookReels, event)
            "com.snapchat.android" -> checkIds(root, snapchatSpotlight, event)
            "com.twitter.android", "com.x.android" -> checkIds(root, xVideoFeed, event)
            "com.reddit.frontpage" -> checkIds(root, redditVideoFeed, event)
            else -> false
        }
        try { root.recycle() } catch (_: Exception) {}
        return result
    }

    private fun checkIds(
        root: AccessibilityNodeInfo,
        ids: List<String>,
        event: AccessibilityEvent
    ): Boolean {
        // Check event source ID first (fastest)
        val sourceId = try { event.source?.viewIdResourceName } catch (_: Exception) { null }
        if (sourceId != null && ids.any { sourceId.contains(it) }) return true

        // Check root window nodes
        for (id in ids) {
            try {
                val nodes = root.findAccessibilityNodeInfosByViewId(id)
                if (nodes.isNotEmpty()) {
                    nodes.forEach { try { it.recycle() } catch (_: Exception) {} }
                    return true
                }
            } catch (_: Exception) {}
        }
        return false
    }

    private fun isTikTokVideoFeed(event: AccessibilityEvent): Boolean {
        return try {
            val node = event.source ?: return false
            val bounds = Rect()
            node.getBoundsInScreen(bounds)
            val display = resources.displayMetrics
            val isFullscreen = bounds.height() > display.heightPixels * 0.7f
            try { node.recycle() } catch (_: Exception) {}
            isFullscreen
        } catch (_: Exception) { false }
    }

    private fun packageToAppName(pkg: String): String = when (pkg) {
        "com.google.android.youtube" -> "YouTube"
        "com.instagram.android" -> "Instagram"
        "com.facebook.katana" -> "Facebook"
        "com.zhiliaoapp.musically" -> "TikTok"
        "com.snapchat.android" -> "Snapchat"
        "com.twitter.android", "com.x.android" -> "X"
        "com.reddit.frontpage" -> "Reddit"
        else -> "Unknown"
    }

    private fun incrementBlockCount(app: String) {
        val now = java.util.Calendar.getInstance()
        val key = "blocks_${app}_${now.get(java.util.Calendar.YEAR)}_${now.get(java.util.Calendar.MONTH)+1}_${now.get(java.util.Calendar.DAY_OF_MONTH)}"
        val totalKey = "blocks_${now.get(java.util.Calendar.YEAR)}_${now.get(java.util.Calendar.MONTH)+1}_${now.get(java.util.Calendar.DAY_OF_MONTH)}"
        val current = prefs.getInt(key, 0)
        val total = prefs.getInt(totalKey, 0)
        prefs.edit()
            .putInt(key, current + 1)
            .putInt(totalKey, total + 1)
            .apply()
    }

    private fun startForegroundSilent() {
        val channelId = "clearfeed_service"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "ClearFeed", NotificationManager.IMPORTANCE_MIN
            ).apply {
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
                setSound(null, null)
            }
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("ClearFeed")
            .setContentText("Blocking Shorts & Reels")
            .setSmallIcon(android.R.drawable.ic_menu_close_clear_cancel)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSilent(true)
            .setOngoing(true)
            .build()

        startForeground(1, notification)
    }

    override fun onInterrupt() {}
}
