package com.example.quoteApp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class DailyLineWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs: SharedPreferences =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val quote  = prefs.getString("flutter.widget_quote",  "Open DailyLine to load your quote") ?: ""
        val author = prefs.getString("flutter.widget_author", "") ?: ""
        val book   = prefs.getString("flutter.widget_book",   "") ?: ""

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.quote_widget)
            views.setTextViewText(R.id.widget_quote,  "\u201C$quote\u201D")
            views.setTextViewText(R.id.widget_author, author)
            views.setTextViewText(R.id.widget_book,   if (book.isNotEmpty()) "  ·  $book" else "")
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}