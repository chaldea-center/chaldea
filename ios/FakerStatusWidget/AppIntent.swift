//
//  AppIntent.swift
//  FakerStatusWidget
//
//  Created by 鳴海あゆむ on 2025/3/22.
//

import AppIntents
import SwiftUI
import WidgetKit

enum BackgroundStyle: String, AppEnum {
  case solidColor
  case gradient
  case image

  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    return "Background Style"
  }

  static var caseDisplayRepresentations: [BackgroundStyle: DisplayRepresentation] {
    [
      .solidColor: "Solid Color",
      .gradient: "Gradient",
      .image: "Image",
    ]
  }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource { "Widget Configuration" }
  static var description: IntentDescription {
    "Configure the widget's appearance and accounts"
  }

  @Parameter(title: "Background Style", default: .image)
  var backgroundStyle: BackgroundStyle

  @Parameter(title: "Primary Color", default: "#EEEEEE")
  var backgroundColor: String

  @Parameter(title: "Secondary Color", default: "#800080")
  var secondaryColor: String

  @Parameter(title: "Background Image")
  var backgroundImage: String?

  @Parameter(title: "Selected Account IDs", default: [])
  var accountIds: [String]

  var primarySwiftUIColor: Color {
    Color(hex: backgroundColor) ?? .blue
  }

  var secondarySwiftUIColor: Color {
    Color(hex: secondaryColor) ?? .purple
  }
}
