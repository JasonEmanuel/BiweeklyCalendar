//
//  CalendarViewModel.swift
//  ViewWeatherForecast
//
//  Created by Jason Emanuel on 18/10/24.
//

import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var weeklySums: [Double] = []
    @Published var weeklyRange: [String] = []
    @Published var selectedMonth = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()))) ?? Date()
    @Published var date = Date.now
    @Published var days: [Date] = []
    
    private let earliestMonth = Calendar.current.date(from: DateComponents(year: 2024, month: 10))!
    var isPreviousMonthDisabled: Bool {
        return selectedMonth <= earliestMonth
    }
    
    var weeklyForecasts: [WeeklyForecast] = []
    
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    private let startReferenceDate: Date = {
        let components = DateComponents(year: 2024, month: 10, day: 1)
        return Calendar.current.date(from: components)!
    }()
    
    init() {
        fetchWeatherForecast()
    }
    
    func fetchWeatherForecast() {
        let apiService = Services()
        
        apiService.fetchAPIData { result in
            switch result {
            case .success(let forecast):
                DispatchQueue.main.async {
                    self.weeklyForecasts = forecast.flatMap { forecastData in
                        forecastData.weeklySums.enumerated().compactMap { index, precipitation in
                            guard let startDate = parseDate(from: forecastData.startDate) else { return nil }
                            let weekStartDate = Calendar.current.date(byAdding: .day, value: index * 7, to: startDate)!
                            let weekEndDate = Calendar.current.date(byAdding: .day, value: index * 7 + 6, to: weekStartDate)!
                            return WeeklyForecast(weekStartDate: weekStartDate, weekEndDate: weekEndDate, precipitation: precipitation)
                        }
                    }
                    self.filterDataBySelectedMonth()
                }
            case .failure(let error):
                print("Error fetching weather forecast: \(error)")
            }
        }
    }
    
    func filterDataBySelectedMonth() {
        let calendar = Calendar.current
        let selectedMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let selectedMonthEnd = calendar.date(byAdding: .month, value: 1, to: selectedMonthStart)!
        
        let filteredForecasts = weeklyForecasts.filter { forecast in
            (forecast.weekStartDate >= selectedMonthStart && forecast.weekStartDate < selectedMonthEnd)
        }
        self.weeklySums = filteredForecasts.map { $0.precipitation }
    }
    
    func weekNumber(for day: Date) -> Int {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: day))!
        let dayOffset = Calendar.current.dateComponents([.day], from: startOfMonth, to: day).day ?? 0
        return dayOffset / 7
    }
    
    func changeMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) else { return }
        selectedMonth = newMonth
        filterDataBySelectedMonth()
    }
    
    func weeklySum(for weekNumber: Int) -> Double? {
        return weekNumber < weeklySums.count ? weeklySums[weekNumber] : nil
    }
    
    func weekIndex(for day: Date) -> Int {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startReferenceDate, to: day).day ?? 0
        return daysSinceStart / 7
    }
    
    func daysForWeek(weekIndex: Int) -> [Date] {
        let startOfWeek = Calendar.current.date(byAdding: .day, value: weekIndex * 7, to: startReferenceDate)!
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        var daysInWeek: [Date] = []
        for dayOffset in 0..<7 {
            if let day = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                if day >= selectedMonth.startOfMonth && day <= selectedMonth.endOfMonth {
                    daysInWeek.append(day)
                }
            }
        }
        return daysInWeek
    }
    
    func forecast(for day: Date) -> WeeklyForecast? {
        return weeklyForecasts.first { forecast in
            return day >= forecast.weekStartDate && day <= forecast.weekEndDate
        }
    }
}
