package cc.narumi.chaldea

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.util.Log
import android.widget.RemoteViews
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.edit
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.background
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.AndroidRemoteViews
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.color.ColorProvider
import androidx.glance.layout.Alignment
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.wrapContentHeight
import androidx.glance.layout.wrapContentWidth
import androidx.glance.text.FontFamily
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class FakerStatusWidget : GlanceAppWidget() {

    override val stateDefinition = HomeWidgetGlanceStateDefinition()
    override val sizeMode: SizeMode = SizeMode.Single

    companion object {
        const val TAG = "FakerStatusWidget"
        const val ACTION_AUTO_UPDATE = "cc.narumi.chaldea.WIDGET_AUTO_UPDATE"
        const val PREF_LAST_UPDATE = "widget_last_update_time"
        const val PREF_UPDATE_COUNT = "widget_update_count"
        
        // 更新间隔：15分钟（900000毫秒）
        // Android推荐的最小间隔，平衡电量消耗和更新频率
        const val UPDATE_INTERVAL_MS = 15 * 60 * 1000L
        
        // WorkManager任务名称
        const val WORK_NAME = "faker_widget_update_work"
    }

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        Log.d(TAG, "provideGlance called for widget: $id")
        provideContent {
            GlanceContent(context, currentState<HomeWidgetGlanceState>())
        }
    }

    data class AccountData(
        val id: String,
        val name: String,
        val gameServer: String,
        val biliServer: String = "",
        val actMax: Int = 144,
        val actRecoverAt: Long,
        val carryOverActPoint: Int = 0
    ) {
        fun currentAP(nowSec: Long): Int {
            val timeLeft = (actRecoverAt - nowSec).coerceAtLeast(0)
            val ap = (actMax.toDouble() - (timeLeft.toDouble() / 300.0)).toInt()
            return (ap.coerceIn(0, actMax)) + carryOverActPoint
        }

        fun timeToFullRecover(nowSec: Long): Long {
            return actRecoverAt - nowSec
        }
    }

    private fun parseAccounts(json: String?): List<AccountData> {
        return try {
            if (json == null) {
                return emptyList()
            }
            val arr = JSONArray(json)
            (0 until arr.length()).mapNotNull { i ->
                val o = arr.optJSONObject(i) ?: return@mapNotNull null
                AccountData(
                    id = o.optString("id"),
                    name = o.optString("name"),
                    gameServer = o.optString("gameServer"),
                    biliServer = o.optString("biliServer"),
                    actMax = o.optInt("actMax", 144),
                    actRecoverAt = o.optLong("actRecoverAt"),
                    carryOverActPoint = o.optInt("carryOverActPoint", 0)
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun serverFlag(server: String): String {
        return when (server.lowercase(Locale.ROOT)) {
            "jp" -> "🇯🇵"
            "cn" -> "🇨🇳"
            "na" -> "🇺🇸"
            "kr" -> "🇰🇷"
            else -> server
        }
    }

    private fun parseSelectedIds(raw: String?): Set<String> {
        if (raw.isNullOrBlank()) return emptySet()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { arr.optString(it, null) }.toSet()
        } catch (_: Exception) {
            raw.split(",").map { it.trim() }.filter { it.isNotEmpty() }.toSet()
        }
    }

    private fun countdownRemoteViews(context: Context, secondsLeft: Long): RemoteViews {
        if (secondsLeft < -3600 * 99) {
            return RemoteViews(context.packageName, R.layout.widget_countdown).apply {
                setTextViewText(R.id.countdown_chronometer, "-99+h")
            }
        } else {
            val base = SystemClock.elapsedRealtime() + secondsLeft * 1000
            return RemoteViews(context.packageName, R.layout.widget_countdown).apply {
                setChronometer(R.id.countdown_chronometer, base, null, true)
                setChronometerCountDown(R.id.countdown_chronometer, true)
            }
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val prefs = currentState.preferences

        val accountsJson = prefs.getString("accountsData", "[]")
        val selectedIdsRaw = prefs.getString("accountIds", "")

        val primaryColor = Color(110, 177, 243, 255)
        val accounts = parseAccounts(accountsJson)
        val selectedIds = parseSelectedIds(selectedIdsRaw)

        var displayAccounts = if (selectedIds.isNotEmpty()) {
            val filtered = accounts.filter { selectedIds.contains(it.id) }
            filtered.ifEmpty { accounts }
        } else {
            accounts
        }
        if (displayAccounts.size > 3) {
            displayAccounts = displayAccounts.take(3)
        }

        val nowSec = System.currentTimeMillis() / 1000

        val whiteColorProvider = ColorProvider(Color(255, 255, 255), Color(255, 255, 255))
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)

        Box(
            modifier = GlanceModifier.fillMaxHeight().padding(0.dp, 16.dp),
            contentAlignment = Alignment.Center
        ) {
            Column(
                modifier = GlanceModifier.fillMaxWidth().padding(16.dp, 16.dp, 16.dp, 4.dp)
                    .background(primaryColor).let { m ->
                        if (launchIntent != null) m.clickable(
                            actionStartActivity(
                                launchIntent
                            )
                        ) else m
                    },
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                displayAccounts.forEach { account ->
                    Row(
                        modifier = GlanceModifier.fillMaxWidth().padding(bottom = 12.dp)
                            .wrapContentHeight()
                    ) {
                        Text(
                            text = serverFlag(account.gameServer),
                            style = TextStyle(fontSize = 16.sp)
                        )
                        Spacer(GlanceModifier.width(6.dp))
                        Text(
                            modifier = GlanceModifier.defaultWeight(),
                            text = account.name + account.name,
                            style = TextStyle(
                                fontSize = 14.sp, color = whiteColorProvider
                            ),
                            maxLines = 1
                        )
                        Spacer(GlanceModifier.width(2.dp))
                        Column(
                            modifier = GlanceModifier.wrapContentWidth(),
                            horizontalAlignment = Alignment.Horizontal.End,
                        ) {
                            val apText = "${account.currentAP(nowSec)}/${account.actMax}"
                            Text(
                                text = apText, style = TextStyle(
                                    fontSize = 12.sp,
                                    fontFamily = FontFamily.Monospace,
                                    color = whiteColorProvider
                                )
                            )
                            AndroidRemoteViews(
                                modifier = GlanceModifier.wrapContentWidth(),
                                remoteViews = countdownRemoteViews(
                                    context, account.timeToFullRecover(nowSec)
                                )
                            )
                        }
                    }
                }

                if (displayAccounts.isEmpty()) {
                    Text(text = "No Account Selected", style = TextStyle(fontSize = 12.sp))
                }

                Row(
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                    verticalAlignment = Alignment.Vertical.Bottom,
                    modifier = GlanceModifier.fillMaxWidth().padding(vertical = 4.dp)
                        .clickable(actionRunCallback<RefreshAction>())
                ) {
                    Text(
                        text = "↻ ", style = TextStyle(
                            fontSize = 16.sp, color = whiteColorProvider
                        )
                    )
                    Text(
                        text = SimpleDateFormat(
                            "HH:mm", Locale.getDefault()
                        ).format(Date(System.currentTimeMillis())), style = TextStyle(
                            fontSize = 12.sp, color = whiteColorProvider
                        )
                    )
                }
            }
        }
    }
}

class RefreshAction : ActionCallback {
    override suspend fun onAction(
        context: Context, glanceId: GlanceId, parameters: ActionParameters
    ) {
        Log.d(FakerStatusWidget.TAG, "Manual refresh triggered by user")
        
        val def = HomeWidgetGlanceStateDefinition()
        updateAppWidgetState(context, def, glanceId) { state ->
            val prefs = state.preferences
            prefs.edit {
                putLong(FakerStatusWidget.PREF_LAST_UPDATE, System.currentTimeMillis())
                val count = prefs.getLong(FakerStatusWidget.PREF_UPDATE_COUNT, 0L)
                putLong(FakerStatusWidget.PREF_UPDATE_COUNT, count + 1L)
            }
            state
        }
        FakerStatusWidget().update(context, glanceId)
        
        Log.d(FakerStatusWidget.TAG, "Widget updated successfully")
    }
}
