// DİKKAT: Aşağıdaki package satırını kendi uygulama paket adınla değiştir
// (MainActivity.kt dosyasının en üstündeki ile aynı olmalı).
package com.selcukari.todochecklist

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class GorevWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.gorev_widget).apply {
                val satirlar = intArrayOf(R.id.gorev_1, R.id.gorev_2, R.id.gorev_3)
                var dolu = 0

                for (i in satirlar.indices) {
                    val baslik = widgetData.getString("gorev_${i + 1}", null)
                    if (!baslik.isNullOrBlank()) {
                        setTextViewText(satirlar[i], baslik)
                        setViewVisibility(satirlar[i], View.VISIBLE)
                        dolu++
                    } else {
                        setViewVisibility(satirlar[i], View.GONE)
                    }
                }

                setViewVisibility(
                    R.id.bos_mesaj,
                    if (dolu == 0) View.VISIBLE else View.GONE
                )

                // Widget'a dokununca uygulamayı aç
                val acIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_kok, acIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}