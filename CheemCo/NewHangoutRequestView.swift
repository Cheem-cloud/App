// NewHangoutRequestView.swift

import SwiftUI

struct NewHangoutRequestView: View {
    @State private var selectedPersona: Persona?
    @State private var selectedHangoutType: HangoutType?
    @State private var selectedDuration: Double = 1.0 // Default 1 hour
    @State private var selectedTimeSlot: Date?
    @State private var currentStep: Int = 0
    
    // Make sure we're using the examples property correctly
    private let personas = Persona.examples
    
    var body: some View {
        VStack {
            switch currentStep {
            case 0:
                SelectPersonaView(personas: personas, selectedPersona: $selectedPersona) {
                    currentStep += 1
                }
            case 1:
                HangoutTypeSelectionView(selectedType: Binding(
                    get: { selectedHangoutType ?? .hangout },
                    set: { selectedHangoutType = $0 }
                ))
            case 2:
                DurationSelectionView(selectedDuration: $selectedDuration)
            case 3:
                SelectTimeSlotView(selectedTimeSlot: $selectedTimeSlot) {
                    submitRequest()
                }
            default:
                Text("Invalid step")
            }
            
            StepIndicatorView(currentStep: currentStep, totalSteps: 4)
        }
        .navigationTitle("New Hangout Request")
    }
    
    private func submitRequest() {
        guard let selectedPersona = selectedPersona,
              let selectedHangoutType = selectedHangoutType,
              let selectedTimeSlot = selectedTimeSlot else {
            // Handle error case
            return
        }
        
        let service = HangoutRequestService()
        service.submitHangoutRequest(
            persona: selectedPersona,
            hangoutType: selectedHangoutType,
            duration: selectedDuration,
            proposedTime: selectedTimeSlot
        )
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
