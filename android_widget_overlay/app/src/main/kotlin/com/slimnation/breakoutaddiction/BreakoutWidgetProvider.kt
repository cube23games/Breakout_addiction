package com.slimnation.breakoutaddiction

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class BreakoutWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        updateWidgets(context, manager, ids)
    }
    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, BreakoutWidgetProvider::class.java)
            updateWidgets(context, manager, manager.getAppWidgetIds(component))
        }
        private fun updateWidgets(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val title = prefs.getString("flutter.breakout_widget_title", "Your next step is ready")
                ?: "Your next step is ready"
            val subtitle = prefs.getString("flutter.breakout_widget_subtitle", "Open when you are ready")
                ?: "Open when you are ready"
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            for (id in ids) {
                val views = RemoteViews(context.packageName, R.layout.breakout_widget_compact)
                views.setTextViewText(R.id.widget_focus, title)
                views.setTextViewText(R.id.widget_subfocus, subtitle)
                views.setOnClickPendingIntent(R.id.breakout_widget_root, pending)
                manager.updateAppWidget(id, views)
            }
        }
    }
}
