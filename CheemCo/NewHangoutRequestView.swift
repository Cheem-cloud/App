import SwiftUI

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

struct HangoutTypeSelectionView: View {
    @Binding var selectedType: HangoutType
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What type of hangout?")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            ForEach(HangoutType.allCases, id: \.self) { type in
                Button {
                    selectedType = type
                } label: {
                    HStack {
                        Image(systemName: type.icon)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(type.rawValue)
                                .font(.headline)
                            Text(type.description)
                                .font(.subheadline)
                                .opacity(0.8)
                        }
                        
                        Spacer()
                        
                        if type == selectedType {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeColors.textColor)
                        }
                    }
                    .padding()
                    .background(type == selectedType ? ThemeColors.lightGreen : ThemeColors.darkGreen)
                    .foregroundColor(ThemeColors.textColor)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct DurationSelectionView: View {
    @Binding var selectedDuration: Double
    
    let durations = [
        (0.5, "30 minutes"),
        (1.0, "1 hour"),
        (1.5, "1.5 hours"),
        (2.0, "2 hours"),
        (3.0, "3 hours")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How long would you like?")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            ForEach(durations, id: \.0) { duration in
                Button {
                    selectedDuration = duration.0
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .font(.title2)
                        
                        Text(duration.1)
                            .font(.headline)
                        
                        Spacer()
                        
                        if selectedDuration == duration.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeColors.textColor)
                        }
                    }
                    .padding()
                    .background(selectedDuration == duration.0 ? ThemeColors.lightGreen : ThemeColors.darkGreen)
                    .foregroundColor(ThemeColors.textColor)
                    .cornerRadius(10)
                }
            }
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
                        ForEach(viewModel.timeSlots, id: \.date) { daySlots in
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
