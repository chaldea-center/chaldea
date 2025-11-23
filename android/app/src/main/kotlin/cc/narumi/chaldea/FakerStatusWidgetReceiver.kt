// Remember to set a package in order for home_widget to find the Receiver
package cc.narumi.chaldea

import HomeWidgetGlanceWidgetReceiver

class FakerStatusWidgetReceiver : HomeWidgetGlanceWidgetReceiver<FakerStatusWidget>() {
    override val glanceAppWidget = FakerStatusWidget()
}
