package com.tfg.socialmoda

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class OutfyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "outfy_notifications",
                "OUTFY Notificaciones",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Likes, comentarios, seguidores y mensajes"
                enableLights(true)
                enableVibration(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
