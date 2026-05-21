package cc.narumi.chaldea

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.util.Log
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import java.util.concurrent.TimeUnit

class FakerStatusWidgetReceiver : HomeWidgetGlanceWidgetReceiver<FakerStatusWidget>() {
    override val glanceAppWidget = FakerStatusWidget()
    
    companion object {
        private const val TAG = "FakerWidgetReceiver"
        private const val REQUEST_CODE = 12345
        
        fun scheduleUpdates(context: Context) {
            Log.d(TAG, "Scheduling widget updates")
            
            // 方法1: 使用WorkManager进行可靠的后台更新
            scheduleWorkManagerUpdate(context)
            
            // 方法2: 使用AlarmManager作为备用方案
            scheduleAlarmManagerUpdate(context)
        }
        
        fun cancelUpdates(context: Context) {
            Log.d(TAG, "Cancelling widget updates")
            
            // 取消WorkManager任务
            WorkManager.getInstance(context).cancelUniqueWork(FakerStatusWidget.WORK_NAME)
            
            // 取消AlarmManager定时任务
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, FakerStatusWidgetReceiver::class.java).apply {
                action = FakerStatusWidget.ACTION_AUTO_UPDATE
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }
        
        private fun scheduleWorkManagerUpdate(context: Context) {
            Log.d(TAG, "Scheduling WorkManager update")
            
            val updateInterval = FakerStatusWidget.UPDATE_INTERVAL_MS / 1000 // 转换为秒
            val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
                updateInterval,
                TimeUnit.SECONDS
            )
                .setInitialDelay(10, TimeUnit.SECONDS) // 初始延迟10秒
                .addTag(FakerStatusWidget.WORK_NAME)
                .build()
            
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                FakerStatusWidget.WORK_NAME,
                ExistingPeriodicWorkPolicy.REPLACE,
                workRequest
            )
            
            Log.d(TAG, "WorkManager scheduled with interval: ${updateInterval}s")
        }
        
        private fun scheduleAlarmManagerUpdate(context: Context) {
            Log.d(TAG, "Scheduling AlarmManager update")
            
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, FakerStatusWidgetReceiver::class.java).apply {
                action = FakerStatusWidget.ACTION_AUTO_UPDATE
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val triggerAtMillis = SystemClock.elapsedRealtime() + FakerStatusWidget.UPDATE_INTERVAL_MS
            
            // 根据Android版本选择合适的闹钟类型
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // Android 6.0+ 使用setExactAndAllowWhileIdle确保在Doze模式下也能触发
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            } else {
                // 旧版本使用setRepeating
                alarmManager.setRepeating(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAtMillis,
                    FakerStatusWidget.UPDATE_INTERVAL_MS,
                    pendingIntent
                )
            }
            
            Log.d(TAG, "AlarmManager scheduled")
        }
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "Widget enabled, scheduling updates")
        scheduleUpdates(context)
    }
    
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "Widget disabled, cancelling updates")
        cancelUpdates(context)
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        Log.d(TAG, "Widget onUpdate called, ids: ${appWidgetIds.joinToString()}")
        
        // 记录更新时间
        val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putLong(FakerStatusWidget.PREF_LAST_UPDATE, System.currentTimeMillis())
            val count = prefs.getLong(FakerStatusWidget.PREF_UPDATE_COUNT, 0)
            putLong(FakerStatusWidget.PREF_UPDATE_COUNT, count + 1)
            apply()
        }
        
        // 确保更新任务正在运行
        scheduleUpdates(context)
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        Log.d(TAG, "onReceive: action=${intent.action}")
        
        when (intent.action) {
            FakerStatusWidget.ACTION_AUTO_UPDATE -> {
                Log.d(TAG, "Auto update triggered")
                // 自动更新会由父类处理，这里只记录日志
            }
            android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE -> {
                Log.d(TAG, "AppWidget update action received")
            }
        }
    }
}

/**
 * WorkManager Worker用于后台更新Widget
 */
class WidgetUpdateWorker(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {
    
    companion object {
        private const val TAG = "WidgetUpdateWorker"
    }
    
    override fun doWork(): Result {
        Log.d(TAG, "WidgetUpdateWorker doWork started at ${System.currentTimeMillis()}")
        
        return try {
            // 触发Widget更新
            val intent = Intent(applicationContext, FakerStatusWidgetReceiver::class.java).apply {
                action = FakerStatusWidget.ACTION_AUTO_UPDATE
            }
            applicationContext.sendBroadcast(intent)
            
            Log.d(TAG, "Widget update broadcast sent successfully")
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Widget update failed", e)
            Result.retry()
        }
    }
}
