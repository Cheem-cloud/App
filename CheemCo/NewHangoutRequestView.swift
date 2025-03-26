import SwiftUI

// MARK: - View Models
class HangoutRequestViewModel: ObservableObject {
    @Published var currentStep = 1
    @Published var hangoutType: HangoutType = .hangout
    @Published var duration: Double = 1.0
    @Published var selectedTime: Date?
    @Published var selectedPersona: Persona?
    @Published var availablePersonas: [Persona] = []
    @Published var timeSlots: [DayTimeSlots] = []
    @Published var isLoadingTimeSlots = false
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case 1: return true // Type is always selected
        case 2: return true // Duration is always set
        case 3: return selectedTime != nil
        case 4: return selectedPersona != nil
        default: return false
        }
    }
    
    init() {
        // Add test personas
        availablePersonas = [
            Persona(
                id: "1",
                emailOwner: "kendall@example.com",
                name: "Tennis Pro Kendall",
                type: "Tennis Pro",
                description: "Professional tennis player and instructor",
                interests: ["Tennis", "Fitness", "Competition"],
                preferredActivities: ["Tennis Match", "Training Session"]
            ),
            Persona(
                id: "2",
                emailOwner: "kendall@example.com",
                name: "Business Kendall",
                type: "Business Woman",
                description: "Corporate executive and mentor",
                interests: ["Business", "Networking", "Leadership"],
                preferredActivities: ["Coffee Meeting", "Lunch", "Mentoring"]
            ),
            Persona(
                id: "3",
                emailOwner: "kendall@example.com",
                name: "Hiker Kendall",
                type: "Outdoor Enthusiast",
                description: "Adventure seeker and nature lover",
                interests: ["Hiking", "Photography", "Nature"],
                preferredActivities: ["Trail Hiking", "Nature Walk", "Photography"]
            )
        ]
    }
    
    func handleBack() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }
    
    func handleNext() {
        if currentStep < 4 && canProceedToNextStep {
            if currentStep == 2 {
                // Load time slots when moving to step 3
                loadTimeSlots()
            }
            currentStep += 1
        }
    }
    
    func loadTimeSlots() {
        isLoadingTimeSlots = true
        
        // Replace "user@email.com" with the actual email of the selected persona's owner
        GoogleCalendarService.shared.getAvailableTimeSlots(
            forEmail: "user@email.com",
            requestedDuration: duration
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingTimeSlots = false
                
                switch result {
                case .success(let availableSlots):
                    self?.timeSlots = availableSlots
                case .failure(let error):
                    print("Error loading time slots: \(error)")
                    self?.timeSlots = []
                }
            }
        }
    }
    
    private func generateSampleTimeSlots() {
        let calendar = Calendar.current
        let now = Date()
        var timeSlots: [DayTimeSlots] = []
        
        // Generate slots for next 7 days
        for dayOffset in 0...6 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            
            let startHour = dayOffset == 0 ? calendar.component(.hour, from: now) + 1 : 8
            let slots = (startHour...20).compactMap { hour -> Date? in
                calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)
            }
            
            timeSlots.append(DayTimeSlots(date: date, slots: slots))
        }
        
        DispatchQueue.main.async {
            self.timeSlots = timeSlots
            self.isLoadingTimeSlots = false
        }
    }
    
    func submitRequest() {
        // We'll implement this later
        print("Submitting request...")
    }
}

// MARK: - Models
struct DayTimeSlots: Identifiable {
    let id = UUID()
    let date: Date
    let slots: [Date]
}

// MARK: - Supporting Views
struct StepIndicator: View {
    @Binding var currentStep: Int
    let steps = [
        "Type",
        "Duration",
        "Time",
        "Persona"
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress dots
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
            
            // Step labels
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

// MARK: - Step Views
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
            
            if viewModel.timeSlots.isEmpty {
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
                        ForEach(viewModel.timeSlots) { daySlots in
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
        .onAppear {
            print("🕒 Loading time slots for duration: \(viewModel.duration)")
            print("📱 TimeSlotSelectionView appeared")
            if viewModel.timeSlots.isEmpty {
                print("⚠️ No time slots available")
            } else {
                print("✅ Found \(viewModel.timeSlots.count) days with available slots")
                for daySlot in viewModel.timeSlots {
                    print("📅 \(dateFormatter.string(from: daySlot.date)): \(daySlot.slots.count) slots")
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
// MARK: - Main View
struct NewHangoutRequestView: View {
    @StateObject private var viewModel = HangoutRequestViewModel()
    @Environment(\.dismiss) private var dismiss
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    // Step indicator
                    StepIndicator(currentStep: $viewModel.currentStep)
                        .padding()
                    
                    // Current step view
                    Group {
                        switch viewModel.currentStep {
                        case 1:
                            HangoutTypeSelectionView(selectedType: $viewModel.hangoutType)
                                .transition(AnyTransition.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case 2:
                            DurationSelectionView(selectedDuration: $viewModel.duration)
                                .transition(AnyTransition.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case 3:
                            TimeSlotSelectionView(viewModel: viewModel, selectedTime: $viewModel.selectedTime)
                                .transition(AnyTransition.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case 4:
                            PersonaSelectionView(
                                selectedPersona: $viewModel.selectedPersona,
                                personas: viewModel.availablePersonas
                            )
                            .transition(AnyTransition.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack {
                        if viewModel.currentStep > 1 {
                            Button("Back") {
                                withAnimation {
                                    viewModel.handleBack()
                                }
                            }
                            .foregroundColor(ThemeColors.textColor)
                            .transition(.opacity)
                        }
                        
                        Spacer()
                        
                        if viewModel.currentStep < 4 {
                            Button("Next") {
                                withAnimation {
                                    viewModel.handleNext()
                                }
                            }
                            .foregroundColor(ThemeColors.textColor)
                            .disabled(!viewModel.canProceedToNextStep)
                        } else {
                            Button("Submit") {
                                withAnimation {
                                    viewModel.submitRequest()
                                }
                            }
                            .foregroundColor(ThemeColors.textColor)
                            .disabled(!viewModel.canProceedToNextStep)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Hangout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.textColor)
                }
            }
        }
    }
}
