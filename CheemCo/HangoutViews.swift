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

struct TimeSlotButton: View {
    let time: Date
    let duration: Double
    let isSelected: Bool
    let onSelect: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    Text(timeFormatter.string(from: time))
                        .font(.headline)
                    
                    if let endTime = Calendar.current.date(
                        byAdding: .minute,
                        value: Int(duration * 60),
                        to: time
                    ) {
                        Text("Until \(timeFormatter.string(from: endTime))")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.secondaryText)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeColors.textColor)
                }
            }
            .padding()
            .background(isSelected ? ThemeColors.lightGreen : ThemeColors.darkGreen)
            .foregroundColor(ThemeColors.textColor)
            .cornerRadius(10)
        }
    }
}

struct TimeSlotSelectionView: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    @Binding var selectedTime: Date?
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Available Times")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            if viewModel.isLoadingTimeSlots {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.darkGreen))
            } else if viewModel.timeSlots.isEmpty {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(ThemeColors.secondaryText)
                    Text("No available times found")
                        .foregroundColor(ThemeColors.secondaryText)
                        .padding(.top)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 20, pinnedViews: .sectionHeaders) {
                        ForEach(viewModel.timeSlots, id: \.id) { daySlots in
                            Section(header: dayHeader(for: daySlots.date)) {
                                ForEach(daySlots.slots, id: \.self) { slot in
                                    TimeSlotButton(
                                        time: slot,
                                        duration: viewModel.duration,
                                        isSelected: selectedTime == slot,
                                        onSelect: { selectedTime = slot }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func dayHeader(for date: Date) -> some View {
        Text(dateFormatter.string(from: date))
            .font(.headline)
            .foregroundColor(ThemeColors.textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(ThemeColors.darkGreen)
    }
}
