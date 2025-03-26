import Foundation

class GoogleCalendarService {
    static let shared = GoogleCalendarService()
    private let baseURL = "https://www.googleapis.com/calendar/v3"
    
    // Time window constants
    private let businessHourStart = 8  // 8 AM
    private let businessHourEnd = 21   // 9 PM
    private let daysToCheck = 7
    
    struct TimeSlot {
        let start: Date
        let end: Date
        var duration: TimeInterval { end.timeIntervalSince(start) }
    }
    
    struct DayTimeSlots {
        let date: Date
        let slots: [Date]
    }
    
    struct CalendarError: Error {
        let message: String
    }
    
    func getAvailableTimeSlots(
        forEmail email: String,
        requestedDuration: Double,
        completion: @escaping (Result<[DayTimeSlots], Error>) -> Void
    ) {
        print("⭐️ Starting to get available time slots for email: \(email)")
        GoogleCalendarConfig.shared.authorizeCalendarAccess { [weak self] result in
            switch result {
            case .success(let accessToken):
                print("✅ Successfully got access token")
                self?.fetchCalendarForEmail(email, accessToken: accessToken) { result in
                    switch result {
                    case .success(let calendarId):
                        print("📅 Found calendar ID: \(calendarId)")
                        self?.checkAvailability(
                            calendarId: calendarId,
                            accessToken: accessToken,
                            requestedDuration: requestedDuration,
                            completion: completion
                        )
                    case .failure(let error):
                        print("❌ Failed to fetch calendar: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("❌ Authorization failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    private func fetchCalendarForEmail(
        _ email: String,
        accessToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let urlString = "\(baseURL)/users/me/calendarList"
        guard let url = URL(string: urlString) else {
            completion(.failure(CalendarError(message: "Invalid URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(CalendarError(message: "No data received")))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let items = json?["items"] as? [[String: Any]] else {
                    completion(.failure(CalendarError(message: "Invalid response format")))
                    return
                }
                
                if let calendar = items.first(where: { ($0["primary"] as? Bool == true) }) {
                    completion(.success(calendar["id"] as? String ?? "primary"))
                } else {
                    completion(.failure(CalendarError(message: "No calendar found")))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func checkAvailability(
        calendarId: String,
        accessToken: String,
        requestedDuration: Double,
        completion: @escaping (Result<[DayTimeSlots], Error>) -> Void
    ) {
        print("🔍 Checking availability for calendar: \(calendarId)")
        
        let urlString = "\(baseURL)/calendars/\(calendarId)/freeBusy"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            completion(.failure(CalendarError(message: "Invalid URL")))
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        guard let endDate = calendar.date(byAdding: .day, value: daysToCheck, to: now) else {
            print("❌ Failed to calculate end date")
            completion(.failure(CalendarError(message: "Could not calculate date range")))
            return
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let timeMin = dateFormatter.string(from: now)
        let timeMax = dateFormatter.string(from: endDate)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "timeMin": timeMin,
            "timeMax": timeMax,
            "items": [["id": calendarId]]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        // Debug request information
        print("🌐 Request URL: \(urlString)")
        print("📤 Request headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("   \(key): \(value)")
        }
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Request body: \(bodyString)")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(CalendarError(message: "No data received")))
                return
            }
            
            // Debug response information
            print("📦 Raw response data:")
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status code: \(httpResponse.statusCode)")
                print("📥 Response headers:")
                httpResponse.allHeaderFields.forEach { key, value in
                    print("   \(key): \(value)")
                }
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .json5Allowed]) as? [String: Any]
                print("📊 Parsed JSON: \(String(describing: json))")
                
                guard let calendars = json?["calendars"] as? [String: Any] else {
                    print("❌ Failed to parse calendars")
                    print("json contents: \(String(describing: json))")
                    completion(.failure(CalendarError(message: "Invalid response format - no calendars")))
                    return
                }
                
                guard let calendarData = calendars[calendarId] as? [String: Any] else {
                    print("❌ Failed to parse calendar data")
                    print("calendars: \(calendars)")
                    completion(.failure(CalendarError(message: "Invalid response format - no calendar data")))
                    return
                }
                
                guard let busyData = calendarData["busy"] as? [[String: String]] else {
                    print("❌ Failed to parse busy data")
                    print("calendarData: \(calendarData)")
                    completion(.failure(CalendarError(message: "Invalid response format - no busy data")))
                    return
                }
                
                let busySlots = self?.parseBusyPeriods(from: busyData) ?? []
                print("⏰ Found \(busySlots.count) busy slots")
                busySlots.forEach { slot in
                    print("   🚫 Busy: \(slot.start) to \(slot.end)")
                }
                
                let availableSlots = self?.generateAvailableSlots(
                    fromDate: now,
                    toDate: endDate,
                    busySlots: busySlots,
                    requestedDuration: requestedDuration
                ) ?? []
                
                print("✅ Generated \(availableSlots.count) available days")
                availableSlots.forEach { day in
                    print("   📅 \(day.date): \(day.slots.count) slots")
                }
                
                DispatchQueue.main.async {
                    completion(.success(availableSlots))
                }
            } catch {
                print("❌ JSON parsing error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func parseBusyPeriods(from data: [[String: String]]) -> [TimeSlot] {
        let dateFormatter = ISO8601DateFormatter()
        
        return data.compactMap { period -> TimeSlot? in
            guard let startString = period["start"],
                  let endString = period["end"],
                  let start = dateFormatter.date(from: startString),
                  let end = dateFormatter.date(from: endString) else {
                return nil
            }
            
            return TimeSlot(start: start, end: end)
        }
    }
    
    private func generateAvailableSlots(
        fromDate: Date,
        toDate: Date,
        busySlots: [TimeSlot],
        requestedDuration: Double
    ) -> [DayTimeSlots] {
        let calendar = Calendar.current
        let durationInSeconds = requestedDuration * 3600
        var availableSlots: [DayTimeSlots] = []
        
        var currentDate = fromDate
        let timeZone = calendar.timeZone
        
        while currentDate < toDate {
            var daySlots: [Date] = []
            
            guard let dayStart = calendar.date(
                bySettingHour: businessHourStart,
                minute: 0,
                second: 0,
                of: currentDate
            ) else { continue }
            
            guard let dayEnd = calendar.date(
                bySettingHour: businessHourEnd,
                minute: 0,
                second: 0,
                of: currentDate
            ) else { continue }
            
            let startTime: Date
            if currentDate > dayStart {
                let minutes = calendar.component(.minute, from: currentDate)
                let roundedMinutes = (minutes + 29) / 30 * 30
                startTime = calendar.date(
                    bySettingHour: calendar.component(.hour, from: currentDate),
                    minute: roundedMinutes,
                    second: 0,
                    of: currentDate
                ) ?? currentDate
            } else {
                startTime = dayStart
            }
            
            var slotStart = startTime
            while slotStart.addingTimeInterval(durationInSeconds) <= dayEnd {
                let slotEnd = slotStart.addingTimeInterval(durationInSeconds)
                
                let hasConflict = busySlots.contains { busySlot in
                    let busyStart = calendar.date(byAdding: .second, value: timeZone.secondsFromGMT(), to: busySlot.start) ?? busySlot.start
                    let busyEnd = calendar.date(byAdding: .second, value: timeZone.secondsFromGMT(), to: busySlot.end) ?? busySlot.end
                    
                    return !(slotEnd <= busyStart || slotStart >= busyEnd)
                }
                
                if !hasConflict {
                    daySlots.append(slotStart)
                }
                
                slotStart = slotStart.addingTimeInterval(1800)
            }
            
            if !daySlots.isEmpty {
                availableSlots.append(DayTimeSlots(date: currentDate, slots: daySlots))
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return availableSlots
    }
}
