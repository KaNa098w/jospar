import SwiftUI
import WidgetKit

private let appGroupId = "group.com.beyinfotech.jospar"
private let dataKey = "jospar_widget_data"

struct JosparTask: Codable, Identifiable {
  let id: String
  let title: String
  let color: String
}

struct JosparWidgetData: Codable {
  let date: String
  let primary: String
  let title: String
  let empty: String
  let add: String
  let completed: Int
  let total: Int
  let remaining: Int
  let tasks: [JosparTask]

  static let placeholder = JosparWidgetData(
    date: Self.today,
    primary: "#0267AA",
    title: "СЕГОДНЯ",
    empty: "Ничего не запланировано",
    add: "ДОБАВИТЬ",
    completed: 2,
    total: 5,
    remaining: 3,
    tasks: [
      JosparTask(id: "1", title: "Подготовить презентацию", color: "#0267AA"),
      JosparTask(id: "2", title: "Позвонить клиенту", color: "#34C759"),
      JosparTask(id: "3", title: "Купить продукты", color: "#FF9500"),
    ]
  )

  static var today: String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
}

struct JosparEntry: TimelineEntry {
  let date: Date
  let data: JosparWidgetData
}

struct JosparProvider: TimelineProvider {
  func placeholder(in context: Context) -> JosparEntry {
    JosparEntry(date: Date(), data: .placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (JosparEntry) -> Void) {
    completion(JosparEntry(date: Date(), data: loadData() ?? .placeholder))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<JosparEntry>) -> Void) {
    let entry = JosparEntry(date: Date(), data: loadData() ?? emptyData())
    let nextMidnight = Calendar.current.nextDate(
      after: Date(),
      matching: DateComponents(hour: 0, minute: 1),
      matchingPolicy: .nextTime
    ) ?? Date().addingTimeInterval(3600)
    completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
  }

  private func loadData() -> JosparWidgetData? {
    guard
      let raw = UserDefaults(suiteName: appGroupId)?.string(forKey: dataKey),
      let json = raw.data(using: .utf8),
      let decoded = try? JSONDecoder().decode(JosparWidgetData.self, from: json)
    else { return nil }
    return decoded.date == JosparWidgetData.today ? decoded : emptyData(from: decoded)
  }

  private func emptyData(from previous: JosparWidgetData? = nil) -> JosparWidgetData {
    JosparWidgetData(
      date: JosparWidgetData.today,
      primary: previous?.primary ?? "#0267AA",
      title: previous?.title ?? "СЕГОДНЯ",
      empty: previous?.empty ?? "Откройте Jospar для обновления",
      add: previous?.add ?? "ДОБАВИТЬ",
      completed: 0,
      total: 0,
      remaining: 0,
      tasks: []
    )
  }
}

struct JosparTasksWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: JosparEntry

  private var primary: Color { Color(hex: entry.data.primary) }
  private var addURL: URL {
    URL(string: "jospar://widget/add?date=\(entry.data.date)")!
  }

  var body: some View {
    Group {
      if family == .systemSmall {
        smallView
      } else {
        tasksView(maxTasks: family == .systemLarge ? 5 : 3)
      }
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 8)
    .josparWidgetBackground()
  }

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 5) {
        Text(entry.data.title)
          .font(.custom("Oswald-Bold", size: 19))
          .foregroundColor(primary)
          .lineLimit(1)
        Spacer(minLength: 2)
        Text("\(entry.data.completed)/\(entry.data.total)")
          .font(.system(size: 11, weight: .bold))
          .foregroundColor(primary)
      }
      ProgressView(
        value: Double(entry.data.completed),
        total: Double(max(entry.data.total, 1))
      )
      .tint(primary)
      .padding(.vertical, 4)

      if entry.data.tasks.isEmpty {
        Text(entry.data.empty)
          .font(.system(size: 10))
          .foregroundColor(.secondary)
          .lineLimit(2)
          .frame(maxWidth: .infinity, minHeight: 48, alignment: .center)
      } else {
        ForEach(Array(entry.data.tasks.prefix(2))) { task in
          taskRow(task, compact: true)
        }
      }
      Spacer(minLength: 3)
      Link(destination: addURL) {
        HStack(spacing: 4) {
          Image(systemName: "plus")
          Text(entry.data.add)
            .lineLimit(1)
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 28)
        .background(primary)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
      }
    }
  }

  private func tasksView(maxTasks: Int) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text(entry.data.title)
          .font(.custom("Oswald-Bold", size: 24))
          .foregroundColor(primary)
        Spacer()
        Text("\(entry.data.completed) / \(entry.data.total)")
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(primary)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(primary.opacity(0.10))
          .clipShape(Capsule())
      }
      ProgressView(
        value: Double(entry.data.completed),
        total: Double(max(entry.data.total, 1))
      )
      .tint(primary)
      .padding(.top, 5)
      .padding(.bottom, 3)

      if entry.data.tasks.isEmpty {
        Spacer()
        Text(entry.data.empty)
          .font(.system(size: 14))
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
        Spacer()
      } else {
        ForEach(Array(entry.data.tasks.prefix(maxTasks))) { task in
          taskRow(task)
        }
        Color.clear.frame(height: 3)
      }

      Link(destination: addURL) {
        HStack(spacing: 4) {
          Image(systemName: "plus")
          Text(entry.data.add)
        }
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 32)
        .background(primary)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
      }
    }
  }

  private func taskRow(_ task: JosparTask, compact: Bool = false) -> some View {
    HStack(spacing: compact ? 6 : 9) {
      Link(destination: completeURL(task.id)) {
        RoundedRectangle(cornerRadius: compact ? 4 : 5, style: .continuous)
          .stroke(Color(hex: task.color), lineWidth: 1.5)
          .frame(width: compact ? 17 : 20, height: compact ? 17 : 20)
          .contentShape(Rectangle())
      }
      Link(destination: taskURL(task.id)) {
        Text(task.title)
          .font(.system(size: compact ? 11 : 15))
          .foregroundColor(.primary)
          .lineLimit(1)
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
      }
    }
    .frame(maxWidth: .infinity, minHeight: compact ? 22 : 29)
  }

  private func taskURL(_ id: String) -> URL {
    widgetURL(action: "task", id: id)
  }

  private func completeURL(_ id: String) -> URL {
    widgetURL(action: "complete", id: id)
  }

  private func widgetURL(action: String, id: String) -> URL {
    var components = URLComponents()
    components.scheme = "jospar"
    components.host = "widget"
    components.path = "/\(action)"
    components.queryItems = [URLQueryItem(name: "id", value: id)]
    return components.url!
  }
}

private extension View {
  @ViewBuilder
  func josparWidgetBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(for: .widget) { Color(uiColor: .secondarySystemBackground) }
    } else {
      background(Color(uiColor: .secondarySystemBackground))
    }
  }
}

private extension Color {
  init(hex: String) {
    let raw = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    let value = UInt64(raw, radix: 16) ?? 0x0267AA
    self.init(
      red: Double((value >> 16) & 0xff) / 255,
      green: Double((value >> 8) & 0xff) / 255,
      blue: Double(value & 0xff) / 255
    )
  }
}

@main
struct JosparTasksWidget: Widget {
  let kind = "JosparTasksWidget"

  var body: some WidgetConfiguration {
    configuration
  }

  private var configuration: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: JosparProvider()) { entry in
      JosparTasksWidgetView(entry: entry)
    }
    .configurationDisplayName("Jospar — Сегодня")
    .description("Ближайшие задачи и прогресс на сегодня.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    .contentMarginsDisabled()
  }
}

struct JosparTasksWidget_Previews: PreviewProvider {
  static var previews: some View {
    JosparTasksWidgetView(entry: JosparEntry(date: Date(), data: .placeholder))
      .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
