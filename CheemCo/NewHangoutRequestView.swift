// NewHangoutRequestView.swift

import SwiftUI

struct NewHangoutRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HangoutRequestViewModel()
    @State private var selectedTime: Date?
    
    private let steps = ["Persona", "Hangout Type", "Duration", "Date"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Bar
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            ForEach(0..<steps.count, id: \.self) { index in
                                // Dot
                                Circle()
                                    .fill(index + 1 <= currentStepIndex ? ThemeColors.textColor : ThemeColors.secondaryText)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(index + 1 == currentStepIndex ? ThemeColors.textColor : Color.clear, lineWidth: 2)
                                    )
                                
                                // Line
                                if index < steps.count - 1 {
                                    Rectangle()
                                        .fill(index + 1 < currentStepIndex ? ThemeColors.textColor : ThemeColors.secondaryText)
                                        .frame(height: 2)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Step labels
                        HStack {
                            ForEach(0..<steps.count, id: \.self) { index in
                                Text(steps[index])
                                    .font(.caption)
                                    .foregroundColor(index + 1 == currentStepIndex ? ThemeColors.textColor : ThemeColors.secondaryText)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            switch viewModel.currentStep {
                            case .persona:
                                PersonaSelectionStep(viewModel: viewModel)
                            case .type:
                                HangoutTypeStep(viewModel: viewModel)
                            case .duration:
                                DurationStep(viewModel: viewModel)
                            case .time:
                                TimeSelectionStep(viewModel: viewModel, selectedTime: $selectedTime)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentStep != .persona {
                        Button("Back") {
                            viewModel.moveToPreviousStep()
                        }
                        .foregroundColor(ThemeColors.textColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentStep != .time {
                        Button("Next") {
                            if viewModel.canMoveToNextStep() {
                                viewModel.moveToNextStep()
                            }
                        }
                        .disabled(!viewModel.canMoveToNextStep())
                        .foregroundColor(ThemeColors.textColor)
                    } else {
                        Button("Submit") {
                            submitRequest()
                        }
                        .disabled(selectedTime == nil)
                        .foregroundColor(ThemeColors.textColor)
                    }
                }
            }
        }
    }
    
    private var currentStepIndex: Int {
        switch viewModel.currentStep {
        case .persona: return 1
        case .type: return 2
        case .duration: return 3
        case .time: return 4
        }
    }
    
    private func submitRequest() {
        guard let persona = viewModel.selectedPersona,
              let time = selectedTime else { return }
        
        let service = HangoutRequestService()
        service.submitHangoutRequest(
            persona: persona,
            hangoutType: viewModel.selectedHangoutType,
            duration: viewModel.selectedDuration,
            proposedTime: time
        )
        
        dismiss()
    }
}

struct SelectPersonaView: View {
    let personas: [Persona]
    @Binding var selectedPersona: Persona?
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select a Persona")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            ForEach(personas) { persona in
                Button {
                    selectedPersona = persona
                    onNext()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(persona.name)
                                .font(.headline)
                            Text(persona.type)
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        if selectedPersona?.id == persona.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeColors.textColor)
                        }
                    }
                    .padding()
                    .background(selectedPersona?.id == persona.id ? ThemeColors.lightGreen : ThemeColors.darkGreen)
                    .foregroundColor(ThemeColors.textColor)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct SelectTimeSlotView: View {
    @Binding var selectedTimeSlot: Date?
    let onSubmit: () -> Void
    
    var body: some View {
        VStack {
            Text("Select Time Slot")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            // TODO: Implement time slot selection UI
            
            Button("Submit") {
                onSubmit()
            }
            .padding()
            .background(ThemeColors.darkGreen)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray)
                    .frame(width: 10, height: 10)
            }
        }
    }
}

struct NewHangoutRequestView_Previews: PreviewProvider {
    static var previews: some View {
        NewHangoutRequestView()
    }
}
