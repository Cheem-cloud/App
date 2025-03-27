import SwiftUI
import Foundation

class HangoutRequestViewModel: ObservableObject {
    @Published var currentStep = 1
    @Published var selectedPersona: Persona?
    @Published var hangoutType: HangoutType = .hangout
    @Published var duration: Double = 1.0
    @Published var selectedTime: Date?
    @Published var timeSlots: [GoogleCalendarService.DayTimeSlots] = []
    @Published var isLoadingTimeSlots = false
    @Published var availablePersonas: [Persona] = []
    @Published var showingError = false
    @Published var errorMessage = ""
    
    init() {
        self.availablePersonas = Persona.examples
    }
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case 1: return selectedPersona != nil
        case 2: return true // Type is always selected
        case 3: return true // Duration is always set
        case 4: return selectedTime != nil
        default: return false
        }
    }
    
    func selectPersonaAndContinue(_ persona: Persona) {
        self.selectedPersona = persona
        withAnimation {
            self.currentStep += 1
        }
    }
    
    func handleBack() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }
    
    func handleNext() {
        if currentStep < 4 && canProceedToNextStep {
            if currentStep == 2 {
                loadTimeSlots()
            }
            currentStep += 1
        }
    }
    
    func loadTimeSlots() {
        guard let persona = selectedPersona else { return }
        
        print("🔄 Loading time slots for \(persona.emailOwner) with duration: \(duration) hours")
        isLoadingTimeSlots = true
        
        GoogleCalendarService.shared.getAvailableTimeSlots(
            forEmail: persona.emailOwner,
            requestedDuration: duration
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingTimeSlots = false
                
                switch result {
                case .success(let availableSlots):
                    print("✅ Received \(availableSlots.count) days with slots")
                    self?.timeSlots = availableSlots
                case .failure(let error):
                    print("❌ Error loading time slots: \(error)")
                    self?.timeSlots = []
                    self?.showingError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func submitRequest(dismiss: @escaping () -> Void) {
        guard let persona = selectedPersona,
              let selectedTime = selectedTime else {
            showingError = true
            errorMessage = "Missing required information"
            return
        }
        
        HangoutRequestService.shared.submitRequest(
            fromPersona: persona,  // Update this based on current user's persona
            toPersona: persona,
            type: hangoutType,
            time: selectedTime
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Request submitted successfully")
                    dismiss()
                case .failure(let error):
                    print("❌ Failed to submit request: \(error)")
                    self?.showingError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct NewHangoutRequestView: View {
    @StateObject private var viewModel = HangoutRequestViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                            PersonaCarouselView(viewModel: viewModel)
                        case 2:
                            HangoutTypeSelectionView(selectedType: $viewModel.hangoutType)
                        case 3:
                            DurationSelectionView(selectedDuration: $viewModel.duration)
                        case 4:
                            TimeSlotSelectionView(viewModel: viewModel, selectedTime: $viewModel.selectedTime)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                    
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
                                    viewModel.submitRequest(dismiss: { dismiss() })
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
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
