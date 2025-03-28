import SwiftUI
import UIKit

enum HangoutRequestStep {
    case persona
    case type
    case duration
    case time
}

struct TimeSlotGroup: Identifiable {
    let id = UUID()
    let date: Date
    let slots: [Date]
}

class HangoutRequestViewModel: ObservableObject {
    @Published var currentStep: HangoutRequestStep = .persona
    @Published var selectedPersona: Persona?
    @Published var selectedHangoutType: HangoutType = .hangout
    @Published var selectedDuration: TimeInterval = 3600 // 1 hour default
    @Published var selectedTimeSlot: Date?
    @Published var isLoadingTimeSlots: Bool = false
    @Published var timeSlots: [TimeSlotGroup] = []
    @Published var availableTimeSlots: [GoogleCalendarService.DayTimeSlots] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let calendarService = GoogleCalendarService.shared
    private let defaults = UserDefaults.standard
    private let settingsKey = "userSettings"
    
    func moveToNextStep() {
        switch currentStep {
        case .persona:
            currentStep = .type
        case .type:
            currentStep = .duration
        case .duration:
            currentStep = .time
            loadTimeSlots()
        case .time:
            break
        }
    }
    
    func moveToPreviousStep() {
        switch currentStep {
        case .persona:
            break
        case .type:
            currentStep = .persona
        case .duration:
            currentStep = .type
        case .time:
            currentStep = .duration
        }
    }
    
    func canMoveToNextStep() -> Bool {
        switch currentStep {
        case .persona:
            return selectedPersona != nil
        case .type:
            return true // Always has a default value
        case .duration:
            return true // Always has a default value
        case .time:
            return selectedTimeSlot != nil
        }
    }
    
    func createHangoutRequest() {
        // TODO: Implement hangout request creation
    }
    
    func selectPersonaAndContinue(_ persona: Persona) {
        selectedPersona = persona
        moveToNextStep()
    }
    
    private func loadTimeSlots() {
        guard let persona = selectedPersona else { return }
        
        isLoadingTimeSlots = true
        timeSlots = []
        
        calendarService.getAvailableTimeSlots(
            forEmail: persona.emailOwner,
            requestedDuration: selectedDuration
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingTimeSlots = false
                
                switch result {
                case .success(let daySlots):
                    self?.timeSlots = daySlots.map { TimeSlotGroup(date: $0.date, slots: $0.slots) }
                case .failure(let error):
                    print("Failed to load time slots: \(error)")
                    // TODO: Handle error state
                }
            }
        }
    }
    
    func loadAvailableTimeSlots() {
        guard let settings = loadSettings() else {
            error = "Please connect your calendar in Settings first"
            return
        }
        
        isLoading = true
        error = nil
        
        // Use the primary user's access token
        calendarService.getAvailableTimeSlots(
            forEmail: settings.primaryUser.email,
            requestedDuration: selectedDuration
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let daySlots):
                    self?.availableTimeSlots = daySlots
                    self?.timeSlots = daySlots.map { TimeSlotGroup(date: $0.date, slots: $0.slots) }
                    self?.isLoading = false
                case .failure(let error):
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    private func loadSettings() -> UserSettings? {
        if let data = defaults.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            return settings
        }
        return nil
    }
    
    var hangoutTypeBinding: Binding<HangoutType> {
        Binding(
            get: { self.selectedHangoutType },
            set: { self.selectedHangoutType = $0 }
        )
    }
}

struct StepIndicator: View {
    @Binding var currentStep: Int
    let steps = [
        "Persona",
        "Type",
        "Duration",
        "Time"
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index + 1 <= currentStep ? ThemeColors.textColor : ThemeColors.secondaryText)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(ThemeColors.textColor, lineWidth: index + 1 == currentStep ? 2 : 0)
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                    
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(index + 1 < currentStep ? ThemeColors.textColor : ThemeColors.secondaryText)
                            .frame(height: 2)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
            }
            
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    Text(steps[index])
                        .font(.caption)
                        .foregroundColor(index + 1 == currentStep ? ThemeColors.textColor : ThemeColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(ThemeColors.darkGreen.opacity(0.3))
        .cornerRadius(12)
    }
}
