import SwiftUI

struct PersonaSelectionStep: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    
    var body: some View {
        PersonaCarouselView(viewModel: viewModel)
            .onChange(of: viewModel.selectedPersona) { newValue in
                if newValue != nil {
                    viewModel.moveToNextStep()
                }
            }
    }
}

struct HangoutTypeStep: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What type of hangout?")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            ForEach(HangoutType.allCases, id: \.self) { type in
                Button {
                    viewModel.selectedHangoutType = type
                    viewModel.moveToNextStep()
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
                        
                        if type == viewModel.selectedHangoutType {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeColors.textColor)
                        }
                    }
                    .padding()
                    .background(type == viewModel.selectedHangoutType ? ThemeColors.lightGreen : ThemeColors.darkGreen)
                    .foregroundColor(ThemeColors.textColor)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct DurationStep: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    
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
                    viewModel.selectedDuration = duration.0
                    viewModel.moveToNextStep()
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .font(.title2)
                        
                        Text(duration.1)
                            .font(.headline)
                        
                        Spacer()
                        
                        if viewModel.selectedDuration == duration.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeColors.textColor)
                        }
                    }
                    .padding()
                    .background(viewModel.selectedDuration == duration.0 ? ThemeColors.lightGreen : ThemeColors.darkGreen)
                    .foregroundColor(ThemeColors.textColor)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct TimeSelectionStep: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    @Binding var selectedTime: Date?
    
    var body: some View {
        TimeSlotPickerView(viewModel: viewModel, selectedTime: $selectedTime)
    }
} 