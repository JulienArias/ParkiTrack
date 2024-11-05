import SwiftUI

struct MedicationView: View {
    @StateObject private var viewModel = MedicationViewModel()
    @State private var showingAddMedication = false
    @State private var medicationToEdit: Medication?
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if viewModel.medications.isEmpty {
                        ContentUnavailableView(
                            "Aucun médicament",
                            systemImage: "pills",
                            description: Text("Ajoutez vos médicaments en appuyant sur le bouton +")
                        )
                        .foregroundColor(AppTheme.primary)
                    } else {
                        ForEach(viewModel.medications) { medication in
                            MedicationRow(medication: medication)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    medicationToEdit = medication
                                }
                        }
                        .onDelete { indexSet in
                            viewModel.medications.remove(atOffsets: indexSet)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppTheme.background)
                
                // Bouton + flottant
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 70, height: 70)
                                .shadow(radius: AppTheme.shadowRadius)
                            
                            Button {
                                showingAddMedication = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .bold()
                                    .frame(width: 60, height: 60)
                                    .background(AppTheme.primary)
                                    .foregroundStyle(AppTheme.cardBackground)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("Médicaments")
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView(medications: $viewModel.medications)
            }
            .sheet(item: $medicationToEdit) { medication in
                EditMedicationView(
                    medications: $viewModel.medications,
                    medicationToEdit: medication
                )
            }
        }
    }
}

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Text(medication.name)
                .font(.headline)
                .foregroundColor(AppTheme.primary)
            
            Text("\(medication.dosage, specifier: "%.1f") comprimé(s)")
                .font(.subheadline)
                .foregroundStyle(AppTheme.primary.opacity(0.8))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(medication.scheduledTimes, id: \.self) { time in
                        Text(time.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.primary.opacity(0.1))
                            .foregroundColor(AppTheme.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(radius: AppTheme.shadowRadius)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    MedicationView()
} 