//
//  Services.swift
//  ViewWeatherForecast
//
//  Created by Jason Emanuel on 17/10/24.
//

import Foundation

struct WeeklyForecast: Decodable{
    var weekStartDate: Date
    var weekEndDate: Date
    var precipitation: Double
}

struct ForecastData: Decodable {
    var startDate: String
    var endDate: String
    var totalPrecipitationForMonth: Double
    var weeklySums: [Double]
    
    enum CodingKeys: String, CodingKey {
        case startDate = "startDate"
        case endDate = "end_date"
        case totalPrecipitationForMonth = "totalPrecipitation4Months"
        case weeklySums
    }
}

func parseDate(from dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(secondsFromGMT: 0) 
    return formatter.date(from: dateString)
}

class Services {
    
    func fetchAPIData(completion: @escaping (Result<[ForecastData], Error>) -> Void) {
        let urlString = "https://api.saranalintasmedika.co.id/app/mc/seasonal/forecast?latitude=-7.1539&longitude=112.6561"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error Occured: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data returned from server")
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data returned from server"])))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Data: \(jsonString)")
            }
            
            do {
                print("Parsing data ...")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                var forecastDataArray : [ForecastData] = []
                
                for(key, value) in jsonDict ?? [:] {
                    if key.starts(with: "response_params"), let forecastDict = value as? [String: Any] {
                        let forecastData = try JSONDecoder().decode(ForecastData.self, from: JSONSerialization.data(withJSONObject: forecastDict))
                        forecastDataArray.append(forecastData)
                    }
                }
                
                forecastDataArray = forecastDataArray.sorted {
                    guard let date1 = parseDate(from: $0.startDate), let date2 = parseDate(from: $1.startDate) else {
                        return false
                    }
                    return date1 < date2
                }
                
                var weeklyForecasts: [WeeklyForecast] = []
                
                for forecast in forecastDataArray {
                    if let startDate = parseDate(from: forecast.startDate), let endDate = parseDate(from: forecast.endDate) {
                        // Call function to break down forecast into weekly aggregates
                        let weeklyData = self.aggregateWeeklyData(startDate: startDate, endDate: endDate, weeklySums: forecast.weeklySums)
                        weeklyForecasts.append(contentsOf: weeklyData)
                    }
                }
                
                debugPrint("Data received: \(weeklyForecasts)")
                completion(.success(forecastDataArray))
                
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func aggregateWeeklyData(startDate: Date, endDate: Date, weeklySums: [Double]) -> [WeeklyForecast] {
        var weeklyForecasts: [WeeklyForecast] = []
        
        let calendar = Calendar.current
        var currentStartDate = startDate
        var weeklyIndex = 0
        
        while currentStartDate <= endDate && weeklyIndex < weeklySums.count {
            // Calculate end date of the current week (7 days after start date or up to the endDate)
            let currentEndDate = min(calendar.date(byAdding: .day, value: 6, to: currentStartDate) ?? currentStartDate, endDate)
            
            // Create a weekly forecast entry
            let weeklyForecast = WeeklyForecast(
                weekStartDate: currentStartDate,
                weekEndDate: currentEndDate,
                precipitation: weeklySums[weeklyIndex]
            )
            
            weeklyForecasts.append(weeklyForecast)
            
            // Move to the next week
            currentStartDate = calendar.date(byAdding: .day, value: 7, to: currentStartDate) ?? currentStartDate
            weeklyIndex += 1
        }
        
        return weeklyForecasts
    }
}



