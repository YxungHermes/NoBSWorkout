//
//  Date+Extensions.swift
//  NoBSWorkout
//
//  Useful extensions for Date formatting and manipulation
//

import Foundation

extension Date {

    /// Format date as "Today", "Yesterday", or actual date
    var smartFormatted: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day of week
            return formatter.string(from: self)
        } else if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d" // e.g., "Jan 15"
            return formatter.string(from: self)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy" // e.g., "Jan 15, 2024"
            return formatter.string(from: self)
        }
    }

    /// Format date and time (e.g., "Today at 2:30 PM")
    var smartFormattedWithTime: String {
        let dateStr = smartFormatted
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeStr = formatter.string(from: self)
        return "\(dateStr) at \(timeStr)"
    }

    /// Get relative time string (e.g., "2 hours ago", "3 days ago")
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Get relative time string (short form, e.g., "2h ago", "3d ago")
    var timeAgoShort: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// End of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    /// Check if date is in the same week as another date
    func isInSameWeek(as date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }

    /// Check if date is in the same month as another date
    func isInSameMonth(as date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }

    /// Get start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }

    /// Get end of week
    var endOfWeek: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfWeek)!
    }

    /// Days ago from today
    var daysAgo: Int {
        let calendar = Calendar.current
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfToday = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startOfSelf, to: startOfToday)
        return components.day ?? 0
    }
}
