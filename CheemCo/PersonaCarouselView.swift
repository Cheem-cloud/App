import SwiftUI

struct PersonaCarouselView: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Select a Persona")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom, 8)
            
            TabView {
                ForEach(Persona.examples) { persona in
                    VStack(spacing: 12) {
                        // Profile Image
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(ThemeColors.lightGreen)
                        
                        // Name and Type
                        VStack(spacing: 4) {
                            Text(persona.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(persona.type)
                                .font(.headline)
                                .foregroundColor(ThemeColors.secondaryText)
                        }
                        
                        // Description
                        Text(persona.description)
                            .multilineTextAlignment(.center)
                            .foregroundColor(ThemeColors.textColor)
                            .padding(.horizontal)
                        
                        // Interests
                        if !persona.interests.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(persona.interests, id: \.self) { interest in
                                        Text(interest)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(ThemeColors.darkGreen)
                                            .foregroundColor(ThemeColors.textColor)
                                            .cornerRadius(15)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                        
                        // Hangout Request Button
                        Button {
                            viewModel.selectPersonaAndContinue(persona)
                        } label: {
                            Text("Hangout Request")
                                .font(.headline)
                                .foregroundColor(ThemeColors.textColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ThemeColors.lightGreen)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
            }
            .frame(height: 450)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}
