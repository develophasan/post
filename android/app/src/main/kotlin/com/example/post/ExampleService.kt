package com.example.post

import androidx.annotation.RequiresApi
import android.app.Notification
import android.app.NotificationManager
import android.app.NotificationChannel
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.util.Timer
import java.util.TimerTask

class ExampleService : Service() {
    private val notificationId = 1
    private var serviceRunning = false
    private lateinit var builder: NotificationCompat.Builder
    private lateinit var channel: NotificationChannel
    private lateinit var manager: NotificationManager

    override fun onCreate() {
        super.onCreate()
        serviceRunning = true
        startForeground()
        startTask()
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceRunning = false
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(channelId: String, channelName: String): String {
        channel = NotificationChannel(channelId,
                channelName, NotificationManager.IMPORTANCE_NONE)
        channel.lightColor = Color.BLUE
        channel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
        return channelId
    }

    private fun startForeground() {
        val channelId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel("example_service", "Example Service")
        } else {
            ""
        }
        builder = NotificationCompat.Builder(this, channelId)
        builder
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Example Service")
            .setContentText("Example Service is running")
            .setCategory(Notification.CATEGORY_SERVICE)
        startForeground(1, builder.build())
    }

    private fun startTask() {
        Timer().schedule(object : TimerTask() {
            override fun run() {
                if (serviceRunning) {
                    updateNotification("I got updated!")
                }
            }
        }, 5000)
    }

    private fun updateNotification(text: String) {
        builder.setContentText(text)
        manager.notify(notificationId, builder.build())
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }
}
