//
//  FakerStatusWidget.swift
//  FakerStatusWidget
//
//  Created by 鳴海あゆむ on 2025/3/22.
//

import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    return SimpleEntry(
      date: Date(), configuration: ConfigurationAppIntent(),
      accountsData: AccountData.mockData)
  }

  func snapshot(for configuration: ConfigurationAppIntent, in context: Context)
    async -> SimpleEntry
  {
    return SimpleEntry(
      date: Date(), configuration: configuration,
      accountsData: AccountData.mockData)
  }

  func timeline(for configuration: ConfigurationAppIntent, in context: Context)
    async -> Timeline<SimpleEntry>
  {
    let sharedDefaults = UserDefaults(
      suiteName: "group.cc.narumi.chaldea.shared")
    let accountsData = sharedDefaults?.string(forKey: "accountsData") ?? "[]"

    let currentDate = Date()
    let entry = SimpleEntry(
      date: currentDate, configuration: configuration,
      accountsData: accountsData)

    let nextUpdateDate = Calendar.current.date(
      byAdding: .minute, value: 5, to: currentDate)!

    return Timeline(entries: [entry], policy: .after(nextUpdateDate))
  }

  //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
  //        // Generate a list containing the contexts this widget is relevant in.
  //    }
}

struct AccountData: Codable {
  let id: String
  let name: String
  var gameServer: String
  var biliServer: String = ""
  var actMax: Int = 144
  var actRecoverAt: Int
  var carryOverActPoint: Int = 0

  var currentAP: Int {
    let timeDifference = actRecoverAt - Int(Date().timeIntervalSince1970)
    let curAp = (Double(actMax) - (Double(timeDifference) / 300.0))
    return max(0, min(Int(curAp.rounded(.down)), actMax)) + carryOverActPoint
  }

  var timeToFullRecover: TimeInterval {
    let timeLeft = actRecoverAt - Int(Date().timeIntervalSince1970)
    return TimeInterval(timeLeft)
  }

  static var mockData: String {
    let now = Int(Date().timeIntervalSince1970)
    let data = [
      AccountData(
        id: "1", name: "藤丸", gameServer: "JP",
        actRecoverAt: now - 1),
      AccountData(
        id: "2", name: "立香", gameServer: "CN",
        actRecoverAt: now + 360),
      AccountData(
        id: "3", name: "Hujimaru", gameServer: "NA",
        actRecoverAt: now + 3600),
      AccountData(
        id: "4", name: "藤丸", gameServer: "TW",
        actRecoverAt: now + 7200),
      AccountData(
        id: "5", name: "Hujimaru", gameServer: "KR",
        actRecoverAt: now + 7200),
      AccountData(
        id: "6", name: "藤丸", gameServer: "JP",
        actRecoverAt: now + 7200),
    ]
    do {
      let jsonData = try JSONEncoder().encode(data)
      return String(data: jsonData, encoding: .utf8) ?? "[]"
    } catch {
      return "[]"
    }
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
  let accountsData: String

  var accounts: [AccountData] {
    guard let data = accountsData.data(using: .utf8) else { return [] }
    do {
      return try JSONDecoder().decode([AccountData].self, from: data)
    } catch {
      return []
    }
  }

  var displayAccounts: [AccountData] {
    let selectedIds = Set(configuration.accountIds)
    let shownAccounts = accounts.filter { selectedIds.contains($0.id) }
    if shownAccounts.isEmpty {
      return accounts
    } else {
      return shownAccounts
    }
  }
}

struct GameServerIcon: View {
  let server: String

  static let serverIcons: [String: String] = [
    "jp": "🇯🇵",
    "cn": "🇨🇳",
    //    "tw": "🇹🇼",
    "na": "🇺🇸",
    "kr": "🇰🇷",
  ]

  var body: some View {
    let size: CGFloat = 18
    if let flag = GameServerIcon.serverIcons[server.lowercased()] {
      Text(flag)
        .frame(width: size, height: size)
    } else {
      Text(server)
        .font(.system(size: 8))
        .frame(width: size, height: size)
        .background(Color.blue.opacity(0.2))
        .clipShape(Circle())
    }
  }
}

struct AccountStatusView: View {
  let account: AccountData

  var body: some View {
    HStack {
      GameServerIcon(server: account.gameServer).padding(.trailing, 0)

      Text(account.name)
        .font(.system(size: 14))
        .frame(maxWidth: .infinity, alignment: .leading)

      //      Spacer(minLength: 0)

      VStack(alignment: .trailing) {

        Text("\(account.currentAP)/\(account.actMax)")
          .font(.caption2).multilineTextAlignment(.trailing)

        if account.timeToFullRecover < -99.0 * 3600 {
          Text("99+h")
            .font(.system(.caption2, design: .monospaced))
            .foregroundColor(.red)
            .multilineTextAlignment(.trailing)
        } else {
          Text(
            Date(timeIntervalSinceNow: account.timeToFullRecover), style: .timer
          )
          .font(.system(.caption2, design: .monospaced))
          .foregroundColor(
            account.timeToFullRecover < 0 ? .red : .primary.opacity(0.6)
          )
          .multilineTextAlignment(.trailing)
        }
      }
      .frame(alignment: .leading)
    }
  }
}

struct FakerStatusWidgetEntryView: View {
  @Environment(\.widgetFamily) private var family
  var entry: Provider.Entry

  @ViewBuilder
  var content: some View {
    switch family {
    case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge:
      VStack(spacing: 0) {
        VStack {
          ForEach(
            entry.displayAccounts.prefix(maxDisplayCount),
            id: \.id
          ) { account in
            Spacer(minLength: 0)
            AccountStatusView(account: account)
            Spacer(minLength: 0)
            Divider()
          }
          if entry.displayAccounts.isEmpty {
            Text("No Account Selected").font(.caption)
          }
        }

        Button(intent: RefreshIntent()) {
          HStack {
            Image(systemName: "arrow.clockwise")
              .font(.caption)
            Text(entry.date, style: .time).font(.caption)
          }.padding(.top, 8)
        }
        .buttonStyle(.plain)
      }.padding(.horizontal, -4).padding(.bottom, -8)

    default:
      Text("Unsupported widget family")
    }
  }

  private var maxDisplayCount: Int {
    switch family {
    case .systemSmall:
      return 3
    case .systemMedium:
      return 3
    case .systemLarge:
      return 6
    case .systemExtraLarge:
      return 9
    default:
      return 3
    }
  }

  var body: some View {
    switch entry.configuration.backgroundStyle {
    case .solidColor:
      content
        .containerBackground(
          entry.configuration.primarySwiftUIColor, for: .widget)
    case .gradient:
      content
        .containerBackground(
          LinearGradient(
            colors: [
              entry.configuration.primarySwiftUIColor,
              entry.configuration.secondarySwiftUIColor,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ), for: .widget)
    case .image:
      content
        .containerBackground(for: .widget) {
          Image(entry.configuration.backgroundImage ?? "widget_background")
            .resizable()
            .scaledToFill()
            .overlay(Color.gray.opacity(0.4))
            .blur(radius: 8)
        }
    }
  }
}

struct FakerStatusWidget: Widget {
  let kind: String = "FakerStatusWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()
    ) { entry in
      FakerStatusWidgetEntryView(entry: entry)
    }.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
      .configurationDisplayName("Faker Status")
      .description("Fake/Grand Order")
  }
}

#Preview(as: .systemSmall) {
  FakerStatusWidget()
} timeline: {
  SimpleEntry(
    date: .now + 10, configuration: ConfigurationAppIntent(),
    accountsData: AccountData.mockData)
}

#Preview(as: .systemMedium) {
  FakerStatusWidget()
} timeline: {
  SimpleEntry(
    date: .now + 10, configuration: ConfigurationAppIntent(),
    accountsData: AccountData.mockData)
}
