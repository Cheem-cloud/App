import SwiftUI

struct PersonaSelectionView: View {
    @Binding var selectedPersona: Persona?
    let personas: [Persona]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a Persona")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            if personas.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(ThemeColors.secondaryText)
                    Text("No personas available")
                        .foregroundColor(ThemeColors.secondaryText)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(personas) { persona in
                            PersonaCard(persona: persona, isSelected: persona.id == selectedPersona?.id)
                                .onTapGesture {
                                    selectedPersona = persona
                                }
                        }
                    }
                }
            }
        }
    }
}

struct PersonaCard: View {
    let persona: Persona
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(ThemeColors.lightGreen)
                .frame(width: 60, height: 60)
                .overlay(
                    Text(persona.name.prefix(1).uppercased())
                        .font(.title2)
                        .foregroundColor(ThemeColors.textColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(persona.name)
                    .font(.headline)
                Text(persona.type)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
                
                if !persona.interests.isEmpty {
                    HStack {
                        ForEach(persona.interests.prefix(2), id: \.self) { interest in
                            Text(interest)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(ThemeColors.darkGreen)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ThemeColors.textColor)
                    .font(.title3)
            }
        }
        .padding()
        .background(isSelected ? ThemeColors.lightGreen.opacity(0.3) : ThemeColors.darkGreen.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? ThemeColors.lightGreen : Color.clear, lineWidth: 2)
        )
    }
}
