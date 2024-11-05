import SwiftUI

struct StateView: View {
    @EnvironmentObject var viewModel: SymptomViewModel
    @State private var selectedState: SymptomState?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Fond principal
                AppTheme.background
                    .ignoresSafeArea()
                
                // Fond unique pour la section des boutons
                Color(.systemGray6) // Couleur plus claire
                    .frame(height: UIScreen.main.bounds.height * 0.45) // Un peu plus haut pour englober la fin de la carte
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 30,
                            style: .continuous
                        )
                        .corners([.topLeft, .topRight])
                    )
                    .ignoresSafeArea(edges: .bottom)
                
                // Contenu
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: AppTheme.spacing) {
                            WelcomeHeader()
                            StateLegend()
                        }
                        .padding()
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    StateButtonsGrid(selectedState: $selectedState, viewModel: viewModel)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("État actuel")
        }
    }
}

// Extension corrigée pour appliquer les coins arrondis seulement en haut
extension RoundedRectangle {
    func corners(_ corners: UIRectCorner) -> some Shape {
        let radius = self.cornerSize.width
        return Path { path in
            let cgPath = UIBezierPath(
                roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), // Dimensions réelles au lieu de 1000
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
            path.addPath(Path(cgPath))
        }
    }
}

// MARK: - Subviews
private struct WelcomeHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "hand.wave.fill")
                .foregroundColor(AppTheme.primary)
            Text("Comment vous sentez-vous ?")
                .font(AppTheme.headlineStyle)
                .foregroundColor(AppTheme.primary)
        }
        .padding(.vertical, UIConstants.compactPadding)
    }
}

private struct StateLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(UIConstants.stateDescriptions, id: \.text) { item in
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: item.icon)
                        .foregroundColor(item.color)
                        .font(.title3)
                        .frame(width: 24)
                    
                    Text(item.text)
                        .font(AppTheme.subheadlineStyle)
                        .foregroundColor(.primary)
                        .lineLimit(2) // Permet 2 lignes si nécessaire
                        .fixedSize(horizontal: false, vertical: true) // Permet le retour à la ligne
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(
            color: AppTheme.shadowColor,
            radius: AppTheme.shadowRadius,
            x: 0,
            y: AppTheme.shadowY
        )
    }
}

private struct StateButtonsGrid: View {
    @Binding var selectedState: SymptomState?
    let viewModel: SymptomViewModel
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible())], spacing: UIConstants.compactPadding) {
            ForEach(UIConstants.stateButtons, id: \.title) { button in
                StateButton(
                    title: button.title,
                    icon: button.icon,
                    color: button.color,
                    isSelected: selectedState == button.state
                ) {
                    selectedState = button.state
                    viewModel.addSymptom(button.state)
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views
struct StateButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            // Animation de pression
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Retour haptique
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.3)
            
            // Action
            action()
            
            // Retour l'état normal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Spacer()
                Text(title)
                    .font(AppTheme.headlineStyle)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIConstants.stateButtonHeight)
            .padding(.horizontal, 24)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct CompactLegendItem: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(AppTheme.captionStyle)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StateView()
        .environmentObject(SymptomViewModel())
} 