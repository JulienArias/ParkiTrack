import SwiftUI

struct EditMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var medications: [Medication]
    let medicationToEdit: Medication
    
    @State private var selectedMedication: String
    @State private var selectedDosage: String
    @State private var selectedQuantity: Double
    @State private var selectedTimes: Set<Date>
    @State private var showingCommonMedications = false
    @State private var showingTimeSelector = false
    @State private var showingDeleteConfirmation = false
    
    init(medications: Binding<[Medication]>, medicationToEdit: Medication) {
        self._medications = medications
        self.medicationToEdit = medicationToEdit
        
        _selectedMedication = State(initialValue: medicationToEdit.name)
        _selectedDosage = State(initialValue: "") // À adapter selon votre modèle
        _selectedQuantity = State(initialValue: medicationToEdit.dosage)
        _selectedTimes = State(initialValue: Set(medicationToEdit.scheduledTimes))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacing) {
                // Médicaments courants
                Button {
                    showingCommonMedications = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(AppTheme.primary)
                        Text("Médicaments courants")
                            .foregroundColor(AppTheme.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.primary.opacity(0.6))
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .shadow(radius: AppTheme.shadowRadius)
                }
                
                // Médicament sélectionné
                HStack {
                    Image(systemName: "pills")
                        .foregroundColor(AppTheme.primary)
                    Text(selectedMedication)
                        .foregroundColor(AppTheme.primary)
                    Spacer()
                }
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .shadow(radius: AppTheme.shadowRadius)
                
                // Quantité
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantité")
                        .foregroundColor(AppTheme.primary)
                    HStack(spacing: 12) {
                        Button {
                            selectedQuantity = 0.5
                        } label: {
                            Text("½")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedQuantity == 0.5 ? AppTheme.primary : AppTheme.cardBackground)
                                .foregroundColor(selectedQuantity == 0.5 ? .white : AppTheme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .stroke(AppTheme.primary, lineWidth: 1)
                                )
                        }
                        
                        Button {
                            selectedQuantity = 1.0
                        } label: {
                            Text("1")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedQuantity == 1.0 ? AppTheme.primary : AppTheme.cardBackground)
                                .foregroundColor(selectedQuantity == 1.0 ? .white : AppTheme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .stroke(AppTheme.primary, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .shadow(radius: AppTheme.shadowRadius)
                
                // Heures de prise
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(AppTheme.primary)
                        Text("Heures de prise")
                            .foregroundColor(AppTheme.primary)
                        Spacer()
                    }
                    
                    if selectedTimes.isEmpty {
                        Text("Aucun horaire sélectionné")
                            .foregroundColor(AppTheme.primary.opacity(0.6))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedTimes).sorted(), id: \.self) { time in
                                    TimeChip(time: time) {
                                        selectedTimes.remove(time)
                                    }
                                }
                            }
                        }
                    }
                    
                    Button {
                        showingTimeSelector = true
                    } label: {
                        Text("Ajouter un horaire")
                            .foregroundColor(AppTheme.primary)
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .shadow(radius: AppTheme.shadowRadius)
                
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Supprimer ce médicament", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.error.opacity(0.1))
                        .foregroundColor(AppTheme.error)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .background(AppTheme.background)
            .navigationTitle("Modifier le médicament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sauvegarder") {
                        if let index = medications.firstIndex(where: { $0.id == medicationToEdit.id }) {
                            let updatedMedication = Medication(
                                name: selectedMedication,
                                dosage: selectedQuantity,
                                scheduledTimes: Array(selectedTimes)
                            )
                            medications[index] = updatedMedication
                        }
                        dismiss()
                    }
                    .disabled(selectedMedication.isEmpty || selectedTimes.isEmpty)
                    .foregroundColor(AppTheme.primary)
                }
            }
            .sheet(isPresented: $showingCommonMedications) {
                CommonMedicationsView { name, dosage in
                    selectedMedication = name
                    selectedDosage = dosage
                    showingCommonMedications = false
                }
            }
            .sheet(isPresented: $showingTimeSelector) {
                TimeSelectorView(selectedTimes: $selectedTimes)
            }
            .confirmationDialog(
                "Supprimer le médicament ?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Supprimer", role: .destructive) {
                    if let index = medications.firstIndex(where: { $0.id == medicationToEdit.id }) {
                        medications.remove(at: index)
                        dismiss()
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action ne peut pas être annulée.")
            }
        }
    }
}

#Preview {
    EditMedicationView(
        medications: .constant([]),
        medicationToEdit: Medication(
            name: "Test",
            dosage: 1.0,
            scheduledTimes: []
        )
    )
} 