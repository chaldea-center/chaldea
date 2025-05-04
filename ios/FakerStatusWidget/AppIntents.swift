//
//  AppIntents.swift
//  FakerStatusWidget
//
//  Created by 鳴海あゆむ on 2025/3/22.
//

import AppIntents
import WidgetKit

struct RefreshIntent: AppIntent {
  static var title: LocalizedStringResource = "Refresh Widget"
  static var description = IntentDescription("Refresh the widget data")

  func perform() async throws -> some IntentResult {
    // In real implementation, trigger data refresh from shared container
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

struct OpenConfigurationIntent: AppIntent {
  static var title: LocalizedStringResource = "Open Configuration"
  static var description = IntentDescription("Open widget configuration")

  func perform() async throws -> some IntentResult {
    // In real implementation, open app's widget configuration page
    return .result()
  }
}
