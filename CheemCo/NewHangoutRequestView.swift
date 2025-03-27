// NewHangoutRequestView.swift

import SwiftUI

struct NewHangoutRequestView: View {
    @State private var selectedPersona: Persona?
    @State private var selectedHangoutType: String = ""
    @State private var selectedDuration: Int = 60 // Default 60 minutes
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
                SelectHangoutTypeView(selectedHangoutType: $selectedHangoutType) {
                    currentStep += 1
                }
            case 2:
                SelectDurationView(selectedDuration: $selectedDuration) {
                    currentStep += 1
                }
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
        guard let selectedPersona = selectedPersona, let selectedTimeSlot = selectedTimeSlot else {
            // Handle error case
            return
        }
        
        let service = HangoutRequestService()
        service.submitHangoutRequest(
            userId: UserDefaults.standard.string(forKey: "currentUserId") ?? "",
            personaId: selectedPersona.id,
            hangoutType: selectedHangoutType,
            proposedTime: selectedTimeSlot,
            duration: selectedDuration
        )
        
        // Handle success - navigate back or show confirmation
    }
}

// Supporting views
struct SelectPersonaView: View {
    let personas: [Persona]
    @Binding var selectedPersona: Persona?
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Text("Select Persona")
                .font(.headline)
            
            // Carousel of personas
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(personas, id: \.id) { persona in
                        PersonaCard(persona: persona, isSelected: selectedPersona?.id == persona.id)
                            .onTapGesture {
                                selectedPersona = persona
                            }
                    }
                }
                .padding()
            }
            
            Button("Next") {
                guard selectedPersona != nil else { return }
                onNext()
            }
            .disabled(selectedPersona == nil)
            .padding()
        }
    }
}

struct PersonaCard: View {
    let persona: Persona
    let isSelected: Bool
    
    var body: some View {
        VStack {
            if let image = persona.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
            }
            
            Text(persona.name)
                .fontWeight(.medium)
            
            Text(persona.description)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}

// Placeholder for other supporting views - implement as needed
struct SelectHangoutTypeView: View {
    @Binding var selectedHangoutType: String
    let onNext: () -> Void
    
    var body: some View {
        // Implementation
        Text("Select Hangout Type")
    }
}

struct SelectDurationView: View {
    @Binding var selectedDuration: Int
    let onNext: () -> Void
    
    var body: some View {
        // Implementation
        Text("Select Duration")
    }
}

struct SelectTimeSlotView: View {
    @Binding var selectedTimeSlot: Date?
    let onComplete: () -> Void
    
    var body: some View {
        // Implementation
        Text("Select Time Slot")
    }
}

struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        // Implementation
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
