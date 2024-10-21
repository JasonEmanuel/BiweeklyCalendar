//
//  DateExtension.swift
//  ViewWeatherForecast
//
//  Created by Jason Emanuel on 14/10/24.
//

import Foundation

extension Date {
    static var firstDayOfWeek = Calendar.current.firstWeekday
    
    static var capitalizedFirstLettersOfWeekdays: [String] {
        _ = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        var weekdays = formatter.shortWeekdaySymbols ?? []
        if firstDayOfWeek > 1 {
            for _ in 1..<firstDayOfWeek {
                let first = weekdays.removeFirst()
                weekdays.append(first)
            }
        }
        
        // Kembalikan array dengan huruf kapital pertama
        return weekdays.map { $0.capitalized }
    }
    
    static var fullMonthNames: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        return(1...12).compactMap { month in
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: 1))
            return date.map { dateFormatter.string(from: $0) }
        }
    }
    
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay)!
    }
    
    var startOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self)!
        return dayInPreviousMonth.startOfMonth
    }
    
    var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }
    
    var firstWeekDayBeforeStart: Date {
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        let numberFromPreviousMonth = startOfMonthWeekday - Self.firstDayOfWeek
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: startOfMonth)!
    }
    
    var firstWeekDayOfMonth: Int {
        Calendar.current.component(.weekday, from: startOfMonth)
    }
    
    var lastWeekDayOfMonth: Int {
        Calendar.current.component(.weekday, from: endOfMonth)
    }
    
    var calendarDisplayDays: [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        
        let firstDayOfMonth = self.startOfMonth
        let firstWeekDay = firstWeekDayOfMonth - 1
        
        if firstWeekDay > 0 {
            if let previousMonthEnd = calendar.date(byAdding: .day, value: -1, to: firstDayOfMonth) {
                for offset in (0..<firstWeekDay).reversed() {
                    if let day = calendar.date(byAdding: .day, value: -offset, to: previousMonthEnd) {
                        days.append(day)
                    }
                }
            }
        }
        
        for dayOffset in 0..<numberOfDaysInMonth {
            if let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) {
                days.append(currentDay)
            }
        }
        
        let remainingDays = 7 - lastWeekDayOfMonth
        if remainingDays > 0 && remainingDays < 7 {
            if let nextMonthStart = calendar.date(byAdding: .day, value: 1, to: endOfMonth) {
                for dayOffset in 0..<remainingDays {
                    if let day = calendar.date(byAdding: .day, value: dayOffset,to: nextMonthStart) {
                        days.append(day)
                    }
                }
            }
        }
        return days
    }
    
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
    
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var weekOfMonth: Int {
        Calendar.current.component(.weekOfMonth, from: self)
    }
    
    var isCurrentWeek: Bool {
        let calendar = Calendar.current
        let currentWeekOfYear = calendar.component(.weekOfYear, from: Date.now)
        let targetWeekOfYear = calendar.component(.weekOfYear, from: self)
        
        let currentYear = calendar.component(.yearForWeekOfYear, from: Date.now)
        let targetYear = calendar.component(.yearForWeekOfYear, from: self)
        
        return currentWeekOfYear == targetWeekOfYear && currentYear == targetYear
        
    }
    
    func isWithinNextWeek(from startDate: Date) -> Bool {
        let today = Date.now.startOfDay
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: today)!.startOfDay
        return self >= today && self <= endDate
    }
}
