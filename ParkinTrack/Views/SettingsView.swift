import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var symptomViewModel: SymptomViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showingResetConfirmation = false
    @State private var showingProfileEditor = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacing) {
                    SettingsCard(title: "Notifications", icon: "bell.fill") {
                        Toggle("Activer les notifications", isOn: $settingsViewModel.enableNotifications)
                            .tint(AppTheme.primary)
                        
                        if settingsViewModel.enableNotifications {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Rappel avant la prise")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.primary.opacity(0.8))
                                
                                HStack {
                                    Slider(value: $settingsViewModel.reminderTime, in: 5...30, step: 5)
                                        .tint(AppTheme.primary)
                                    Text("\(Int(settingsViewModel.reminderTime)) min")
                                        .foregroundStyle(AppTheme.primary.opacity(0.8))
                                }
                                
                                Text("Vérification après la prise")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.primary.opacity(0.8))
                                
                                HStack {
                                    Slider(value: $settingsViewModel.checkTime, in: 5...30, step: 5)
                                        .tint(AppTheme.primary)
                                    Text("\(Int(settingsViewModel.checkTime)) min")
                                        .foregroundStyle(AppTheme.primary.opacity(0.8))
                                }
                            }
                        }
                    }
                    
                    SettingsCard(title: "À propos", icon: "info.circle.fill") {
                        HStack {
                            Text("Version")
                                .foregroundColor(AppTheme.primary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(AppTheme.primary.opacity(0.8))
                        }
                    }
                    
                    SettingsCard(title: "Données", icon: "arrow.clockwise") {
                        VStack(spacing: 12) {
                            Button(role: .destructive) {
                                showingResetConfirmation = true
                            } label: {
                                HStack {
                                    Text("Réinitialiser les données")
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise")
                                }
                                .foregroundColor(AppTheme.error)
                            }
                            
                            Text("Supprime toutes les données enregistrées")
                                .font(AppTheme.captionStyle)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    SettingsCard(title: "Profil", icon: "person.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            if settingsViewModel.userProfile.firstName.isEmpty {
                                Button {
                                    showingProfileEditor = true
                                } label: {
                                    HStack {
                                        Text("Configurer mon profil")
                                            .foregroundColor(AppTheme.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppTheme.primary.opacity(0.6))
                                    }
                                }
                            } else {
                                ProfileSummaryView(profile: settingsViewModel.userProfile)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    showingProfileEditor = true
                                } label: {
                                    HStack {
                                        Text("Modifier")
                                            .foregroundColor(AppTheme.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppTheme.primary.opacity(0.6))
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("Paramètres")
            .confirmationDialog(
                "Réinitialiser les données ?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Tout effacer", role: .destructive) {
                    symptomViewModel.resetAll()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action ne peut pas être annulée.")
            }
            .sheet(isPresented: $showingProfileEditor) {
                ProfileEditorView(profile: $settingsViewModel.userProfile)
            }
        }
    }
}

struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.primary)
            }
            content()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(radius: AppTheme.shadowRadius)
    }
}

struct ProfileSummaryView: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(profile.firstName) \(profile.lastName)")
                .font(AppTheme.headlineStyle)
            
            Text("Né(e) le \(profile.birthDate.formatted(date: .long, time: .omitted))")
                .font(AppTheme.bodyStyle)
            
            Text("Diagnostic en \(profile.diagnosisYear)")
                .font(AppTheme.bodyStyle)
            
            if !profile.neurologistName.isEmpty {
                Text("Neurologue : \(profile.neurologistName)")
                    .font(AppTheme.bodyStyle)
            }
            
            if !profile.emergencyContact.isEmpty {
                Text("Contact d'urgence : \(profile.emergencyContact)")
                    .font(AppTheme.bodyStyle)
            }
        }
        .foregroundStyle(.primary)
    }
}

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var profile: UserProfile
    @State private var tempProfile: UserProfile
    
    init(profile: Binding<UserProfile>) {
        self._profile = profile
        self._tempProfile = State(initialValue: profile.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations personnelles") {
                    TextField("Prénom", text: $tempProfile.firstName)
                    TextField("Nom", text: $tempProfile.lastName)
                    DatePicker("Date de naissance", selection: $tempProfile.birthDate, displayedComponents: .date)
                }
                
                Section("Informations médicales") {
                    Stepper("Année du diagnostic : \(tempProfile.diagnosisYear)",
                           value: $tempProfile.diagnosisYear,
                           in: 1950...Calendar.current.component(.year, from: Date()))
                    
                    TextField("Nom du neurologue", text: $tempProfile.neurologistName)
                    TextField("Autres conditions médicales", text: $tempProfile.otherConditions)
                }
                
                Section("Contact d'urgence") {
                    TextField("Contact d'urgence", text: $tempProfile.emergencyContact)
                }
                
                Section("Notes") {
                    TextEditor(text: $tempProfile.notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Mon profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        profile = tempProfile
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 