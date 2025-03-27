import SwiftUI

struct PersonaCarouselView: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select a Persona")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            ForEach(Persona.examples) { persona in
                Button {
                    viewModel.selectPersonaAndContinue(persona)
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
                        
                        if viewModel.selectedPersona?.id == persona.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ThemeColors.textColor)
                        }
                    }
                    .padding()
                    .background(viewModel.selectedPersona?.id == persona.id ? ThemeColors.lightGreen : ThemeColors.darkGreen)
                    .foregroundColor(ThemeColors.textColor)
                    .cornerRadius(10)
                }
            }
        }
    }
}
