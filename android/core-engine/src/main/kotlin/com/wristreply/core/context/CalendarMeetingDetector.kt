package com.wristreply.core.context

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.provider.CalendarContract
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Checks for active calendar events marked as Busy to surface contextual meeting reply pills.
 */
object CalendarMeetingDetector {

    data class ActiveMeeting(
        val isBusy: Boolean,
        val formattedEndTime: String
    )

    fun getActiveBusyMeeting(context: Context): ActiveMeeting? {
        return try {
            val now = System.currentTimeMillis()
            val builder: Uri.Builder = CalendarContract.Instances.CONTENT_URI.buildUpon()
            ContentUris.appendId(builder, now)
            ContentUris.appendId(builder, now + (60 * 1000L))

            val projection = arrayOf(
                CalendarContract.Instances.TITLE,
                CalendarContract.Instances.END,
                CalendarContract.Instances.AVAILABILITY
            )

            val cursor = context.contentResolver.query(
                builder.build(),
                projection,
                null,
                null,
                "${CalendarContract.Instances.END} ASC"
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val availability = it.getInt(it.getColumnIndexOrThrow(CalendarContract.Instances.AVAILABILITY))
                    val endTime = it.getLong(it.getColumnIndexOrThrow(CalendarContract.Instances.END))

                    if (availability != CalendarContract.Instances.AVAILABILITY_FREE && endTime > now) {
                        val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
                        val formattedTime = timeFormat.format(Date(endTime))
                        return ActiveMeeting(isBusy = true, formattedEndTime = formattedTime)
                    }
                }
            }
            null
        } catch (_: SecurityException) {
            null
        } catch (_: Exception) {
            null
        }
    }
}
