import SwiftUI

struct PersonaCarouselView: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    
    var body: some View {
        TabView {
            ForEach(Persona.examples) { persona in
                VStack {
                    Text(persona.name)
                        .font(.title2)
                    Text(persona.type)
                        .font(.subheadline)
                    Text(persona.description)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Select") {
                        viewModel.selectPersonaAndContinue(persona)
                    }
                    .padding()
                    .background(ThemeColors.darkGreen)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}
