import SwiftUI
import UIKit

struct TimeSlotGroup: Identifiable {
    let id = UUID()
    let date: Date
    let slots: [Date]
}

class HangoutRequestViewModel: ObservableObject {
    @Published var selectedPersona: Persona?
    @Published var selectedHangoutType: HangoutType?
    @Published var selectedDuration: Double = 1.0
    @Published var selectedTimeSlot: Date?
    @Published var isLoadingTimeSlots: Bool = false
    @Published var timeSlots: [TimeSlotGroup] = []
    
    func createHangoutRequest() {
        // TODO: Implement hangout request creation
    }
    
    func selectPersonaAndContinue(_ persona: Persona) {
        selectedPersona = persona
        // Additional logic for continuing to the next step can be added here
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
