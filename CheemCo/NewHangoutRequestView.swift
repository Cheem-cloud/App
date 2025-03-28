// NewHangoutRequestView.swift

import SwiftUI

struct NewHangoutRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HangoutRequestViewModel()
    @State private var currentStep = 1
    @State private var selectedTime: Date?
    
    var body: some View {
        ZStack {
            ThemeColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(ThemeColors.textColor)
                    }
                    .padding()
                    
                    Spacer()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentStep {
                        case 1:
                            PersonaCarouselView(viewModel: viewModel)
                                .onChange(of: viewModel.selectedPersona) { newValue in
                                    if newValue != nil {
                                        withAnimation {
                                            currentStep = 2
                                        }
                                    }
                                }
                        case 2:
                            DurationSelectionView(selectedDuration: $viewModel.selectedDuration)
                        case 3:
                            TimeSlotPickerView(viewModel: viewModel, selectedTime: $selectedTime)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func submitRequest() {
        guard let persona = viewModel.selectedPersona,
              let time = selectedTime,
              let hangoutType = viewModel.selectedHangoutType else { return }
        
        let service = HangoutRequestService()
        service.submitHangoutRequest(
            persona: persona,
            hangoutType: hangoutType,
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
