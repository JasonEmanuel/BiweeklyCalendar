//
//  CalendarView.swift
//  ViewWeatherForecast
//
//  Created by Jason Emanuel on 14/10/24.
//

import SwiftUI

struct CalendarView: View {
    
    @StateObject private var vm = CalendarViewModel()
    let weeklySums: [Double]
    
    let weekColors: [Color] = [
        Color.green.opacity(0.2),
        Color.blue.opacity(0.2),
        Color.orange.opacity(0.2),
        Color.purple.opacity(0.2),
        Color.red.opacity(0.2)
    ]
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    HStack {
                        Text("Siklus Tanam 1")
                            .font(.title)
                            .fontWeight(.black)
                        Spacer()
                    }
                    HStack {
                        Text("\(vm.selectedMonth.monthName) \(vm.selectedMonth.yearString)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                vm.changeMonth(by: -1)
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(vm.isPreviousMonthDisabled ? Color.gray.opacity(0.5) : Color.black.opacity(0.4))
                                    )
                            }
                            .disabled(vm.isPreviousMonthDisabled)
                            
                            Button(action: {
                                vm.changeMonth(by: 1)
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(.black.opacity(0.4)))
                            }
                        }
                        
                    }
                    .padding(.top, -10)
                    .onChange(of: vm.selectedMonth) { newValue in
                        vm.filterDataBySelectedMonth()
                        vm.date = vm.selectedMonth
                        vm.days = vm.date.calendarDisplayDays
                    }
                    
                }
                .padding()
                
                HStack {
                    ForEach(vm.daysOfWeek.indices, id: \.self) { index in
                        Text(vm.daysOfWeek[index])
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                
                VStack(spacing: 0) {
                    ForEach(0..<vm.days.count / 7, id: \.self) { rowIndex in
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \.self) { columnIndex in
                                let day = vm.days[rowIndex * 7 + columnIndex]
                                let isCurrentMonth = day.monthInt == vm.selectedMonth.monthInt
                                
                                // Use the new weekIndex calculation
                                let weekIndex = vm.weekIndex(for: day)
                                let weekColor = weekColors[weekIndex % weekColors.count]
                                
                                Text(day.formatted(.dateTime.day()))
                                    .fontWeight(isCurrentMonth ? .bold : .regular)
                                    .foregroundStyle(isCurrentMonth ? .primary : .secondary)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(isCurrentMonth ? weekColor : Color.clear)
                                    .overlay(
                                        VStack {
                                            if let forecast = vm.forecast(for: day) {
                                                Text("Week: \(forecast.precipitation, specifier: "%.2f") mm")
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                                    .padding(5)
                                                    .background(Color.green.opacity(0.2))
                                                    .cornerRadius(8)
                                                    .offset(y: -20)
                                            }
                                        }
                                    )
                            }
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                vm.days = vm.date.calendarDisplayDays
                vm.filterDataBySelectedMonth()
            }
            .onChange(of: vm.date) {
                vm.days = vm.date.calendarDisplayDays
            }
        }
        .onAppear {
            vm.fetchWeatherForecast()
        }
    }
}

#Preview {
    CalendarView(weeklySums: [33.2, 40.3, 25.9, 5.9, 17.9])
}
