import SwiftUI

struct PersonaCarouselView: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select a Persona")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            TabView {
                ForEach(Persona.examples) { persona in
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            // Profile Image or Initial
                            Circle()
                                .fill(ThemeColors.lightGreen)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(persona.name.prefix(1).uppercased())
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(ThemeColors.textColor)
                                )
                            
                            // Name and Type
                            VStack(spacing: 8) {
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
                        .padding()
                        .background(ThemeColors.darkGreen)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}
