package com.beyinfotech.jospar

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class JosparWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    widgetData: SharedPreferences,
  ) {
    val payload = parsePayload(widgetData.getString(DATA_KEY, null))
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.jospar_tasks_widget)
      bindWidget(context, views, payload)
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  private fun bindWidget(context: Context, views: RemoteViews, data: JSONObject) {
    val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
    val isCurrentDay = data.optString("date") == today
    val title = data.optString("title", "СЕГОДНЯ")
    val empty = data.optString("empty", "Ничего не запланировано")
    val add = data.optString("add", "ДОБАВИТЬ")
    val completed = if (isCurrentDay) data.optInt("completed", 0) else 0
    val total = if (isCurrentDay) data.optInt("total", 0) else 0
    val primary = parseColor(data.optString("primary"), DEFAULT_BLUE)

    views.setTextViewText(R.id.widget_title, title)
    views.setTextViewText(R.id.widget_progress_text, "$completed / $total")
    views.setTextViewText(R.id.widget_empty, empty)
    views.setTextViewText(R.id.widget_add_text, add)
    views.setTextColor(R.id.widget_title, primary)
    views.setTextColor(R.id.widget_progress_text, primary)
    views.setProgressBar(R.id.widget_progress, total.coerceAtLeast(1), completed, false)

    val openToday = launchIntent(context, Uri.parse("jospar://widget/add?date=$today"))
    views.setOnClickPendingIntent(R.id.widget_root, openToday)
    views.setOnClickPendingIntent(R.id.widget_add, openToday)

    val tasks = if (isCurrentDay) data.optJSONArray("tasks") else JSONArray()
    val rowIds = intArrayOf(R.id.widget_task_1, R.id.widget_task_2, R.id.widget_task_3)
    val titleIds = intArrayOf(R.id.widget_task_title_1, R.id.widget_task_title_2, R.id.widget_task_title_3)
    val checkIds = intArrayOf(R.id.widget_task_check_1, R.id.widget_task_check_2, R.id.widget_task_check_3)
    val count = minOf(tasks?.length() ?: 0, rowIds.size)
    views.setViewVisibility(R.id.widget_empty, if (count == 0) View.VISIBLE else View.GONE)

    rowIds.indices.forEach { index ->
      if (index >= count) {
        views.setViewVisibility(rowIds[index], View.GONE)
        return@forEach
      }
      val task = tasks!!.optJSONObject(index) ?: JSONObject()
      val taskId = task.optString("id")
      views.setViewVisibility(rowIds[index], View.VISIBLE)
      views.setTextViewText(titleIds[index], task.optString("title"))
      views.setInt(
        checkIds[index],
        "setColorFilter",
        parseColor(task.optString("color"), primary),
      )
      views.setOnClickPendingIntent(
        rowIds[index],
        launchIntent(
          context,
          Uri.Builder()
            .scheme("jospar")
            .authority("widget")
            .appendPath("task")
            .appendQueryParameter("id", taskId)
            .build(),
        ),
      )
      views.setOnClickPendingIntent(
        checkIds[index],
        launchIntent(
          context,
          Uri.Builder()
            .scheme("jospar")
            .authority("widget")
            .appendPath("complete")
            .appendQueryParameter("id", taskId)
            .build(),
        ),
      )
    }
  }

  private fun launchIntent(context: Context, uri: Uri) =
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)

  private fun parsePayload(raw: String?): JSONObject = try {
    JSONObject(raw ?: "{}")
  } catch (_: Exception) {
    JSONObject()
  }

  private fun parseColor(value: String?, fallback: Int): Int = try {
    Color.parseColor(value)
  } catch (_: Exception) {
    fallback
  }

  companion object {
    private const val DATA_KEY = "jospar_widget_data"
    private val DEFAULT_BLUE = Color.rgb(2, 103, 170)
  }
}
