import Foundation

extension Date {
    /// Format date as relative string (e.g., "2 hours ago", "Yesterday")
    func relativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Format date as "MMM d, yyyy" (e.g., "Jan 23, 2026")
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
