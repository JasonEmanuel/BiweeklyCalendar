//
//  ViewWeatherForecastApp.swift
//  ViewWeatherForecast
//
//  Created by Jason Emanuel on 14/10/24.
//

import SwiftUI
import SwiftData

@main
struct ViewWeatherForecastApp: App {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.weeklySums.isEmpty {
                Text("Loading weather data...")
            } else {
                CalendarView(weeklySums: viewModel.weeklySums)
            }
        }
    }
}
