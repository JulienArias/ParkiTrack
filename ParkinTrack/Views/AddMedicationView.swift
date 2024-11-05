import SwiftUI

struct AddMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var medications: [Medication]
    
    @State private var selectedMedication: String = ""
    @State private var selectedDosage: String = ""
    @State private var selectedQuantity: Double = 1.0
    @State private var selectedTimes: Set<Date> = []
    @State private var showingCommonMedications = false
    @State private var showingTimeSelector = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacing) {
                // Médicaments courants
                Button {
                    showingCommonMedications = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(AppTheme.actionButton)
                        Text("Médicaments courants")
                            .foregroundColor(AppTheme.actionButton)
                            .font(AppTheme.headlineStyle)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.actionButton.opacity(0.6))
                    }
                    .padding()
                    .background(AppTheme.actionButtonLight)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .shadow(
                        color: AppTheme.shadowColor,
                        radius: AppTheme.shadowRadius,
                        x: 0,
                        y: AppTheme.shadowY
                    )
                }
                
                // Médicament sélectionné
                if !selectedMedication.isEmpty {
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
                }
                
                // Dosage sélectionné
                if !selectedDosage.isEmpty {
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(AppTheme.primary)
                        Text(selectedDosage)
                            .foregroundColor(AppTheme.primary)
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .shadow(radius: AppTheme.shadowRadius)
                }
                
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
                
                Spacer()
            }
            .padding()
            .background(AppTheme.background)
            .navigationTitle("Nouveau médicament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sauvegarder") {
                        let medication = Medication(
                            name: selectedMedication,
                            dosage: selectedQuantity,
                            scheduledTimes: Array(selectedTimes)
                        )
                        medications.append(medication)
                        dismiss()
                    }
                    .disabled(selectedMedication.isEmpty || selectedTimes.isEmpty)
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
        }
    }
}

// Les autres structures restent les mêmes, mais je vais ajuster CommonMedicationsView :

struct CommonMedicationsView: View {
    let onSelect: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let medications = [
        // Lévodopa et associations
        (name: "Levodopa/Carbidopa (Sinemet®)", dosages: ["100/25mg", "200/50mg", "250/25mg"]),
        (name: "Levodopa/Bensérazide (Modopar®)", dosages: ["50/12.5mg", "100/25mg", "200/50mg"]),
        (name: "Levodopa/Carbidopa/Entacapone (Stalevo®)", dosages: ["50/12.5/200mg", "100/25/200mg", "150/37.5/200mg", "200/50/200mg"]),
        
        // Agonistes dopaminergiques
        (name: "Ropinirole (Requip®)", dosages: ["0.25mg", "0.5mg", "1mg", "2mg", "5mg"]),
        (name: "Pramipexole (Sifrol®)", dosages: ["0.18mg", "0.7mg", "1.1mg", "2.1mg"]),
        (name: "Rotigotine (Neupro®)", dosages: ["2mg/24h", "4mg/24h", "6mg/24h", "8mg/24h"]),
        (name: "Apomorphine (Apokinon®)", dosages: ["10mg/ml", "30mg/3ml", "50mg/5ml"]),
        
        // Inhibiteurs de la MAO-B
        (name: "Rasagiline (Azilect®)", dosages: ["1mg"]),
        (name: "Sélégiline (Deprenyl®)", dosages: ["5mg", "10mg"]),
        (name: "Safinamide (Xadago®)", dosages: ["50mg", "100mg"]),
        
        // Inhibiteurs de la COMT
        (name: "Entacapone (Comtan®)", dosages: ["200mg"]),
        (name: "Opicapone (Ongentys®)", dosages: ["50mg"]),
        
        // Anticholinergiques
        (name: "Trihexyphénidyle (Artane®)", dosages: ["2mg", "5mg"]),
        (name: "Bipéridène (Akineton®)", dosages: ["2mg", "4mg"]),
        
        // Amantadine
        (name: "Amantadine (Mantadix®)", dosages: ["100mg"])
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(medications, id: \.name) { medication in
                        MedicationCard(
                            medication: medication,
                            onSelect: onSelect
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("Médicaments courants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Fermer") {
                    dismiss()
                }
            }
        }
    }
}

struct MedicationCard: View {
    let medication: (name: String, dosages: [String])
    let onSelect: (String, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Titre du médicament
            Text(medication.name)
                .font(.headline)
                .foregroundStyle(.primary)
            
            // Dosages disponibles
            FlowLayout(spacing: 8) {
                ForEach(medication.dosages, id: \.self) { dosage in
                    Button {
                        onSelect(medication.name, dosage)
                    } label: {
                        Text(dosage)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.primary.opacity(0.1))
                            .foregroundStyle(AppTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(radius: AppTheme.shadowRadius)
    }
}

// Layout personnalisé pour organiser les boutons de dosage de manière fluide
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var currentRowIndex = 0
        
        for size in sizes {
            if currentRowWidth + size.width + spacing > (proposal.width ?? .infinity) {
                // Nouvelle ligne
                height += currentRowHeight + spacing
                currentRowWidth = size.width
                currentRowHeight = size.height
                currentRowIndex = 0
            } else {
                currentRowWidth += size.width + (currentRowIndex > 0 ? spacing : 0)
                currentRowHeight = max(currentRowHeight, size.height)
                currentRowIndex += 1
            }
        }
        
        height += currentRowHeight
        
        return CGSize(width: proposal.width ?? .infinity, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var currentPoint = CGPoint(x: bounds.minX, y: bounds.minY)
        var currentRowHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if currentPoint.x + size.width + (index > 0 ? spacing : 0) > bounds.maxX {
                // Nouvelle ligne
                currentPoint.x = bounds.minX
                currentPoint.y += currentRowHeight + spacing
                currentRowHeight = 0
            }
            
            if index > 0 && currentPoint.x > bounds.minX {
                currentPoint.x += spacing
            }
            
            subview.place(
                at: CGPoint(x: currentPoint.x, y: currentPoint.y),
                proposal: ProposedViewSize(size)
            )
            
            currentPoint.x += size.width
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}

// Composant pour afficher un horaire sélectionné
struct TimeChip: View {
    let time: Date
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(time.formatted(date: .omitted, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.blue)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .clipShape(Capsule())
    }
}

// Vue pour la sélection des horaires
struct TimeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTimes: Set<Date>
    
    private let hours = Array(6...22)
    private let minutes = [0, 15, 30, 45]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(hours, id: \.self) { hour in
                        HStack(alignment: .center, spacing: 16) {
                            // Heure
                            Text("\(hour)h")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.primary)
                                .frame(width: 60, alignment: .trailing)
                            
                            // Minutes
                            HStack(spacing: 8) {
                                ForEach(minutes, id: \.self) { minute in
                                    let timeString = String(format: "%02d:%02d", hour, minute)
                                    if let date = timeString.toDate() {
                                        Button {
                                            if selectedTimes.contains(date) {
                                                selectedTimes.remove(date)
                                            } else {
                                                selectedTimes.insert(date)
                                            }
                                        } label: {
                                            Text(String(format: "%02d", minute))
                                                .font(.headline)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 44)
                                                .background(selectedTimes.contains(date) ? AppTheme.primary : AppTheme.cardBackground)
                                                .foregroundColor(selectedTimes.contains(date) ? .white : .primary)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(AppTheme.cardBackground)
                    }
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Sélection des horaires")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Terminé") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
}

// Extension pour convertir une chaîne d'heure en Date
extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .current
        
        if let date = formatter.date(from: self) {
            return Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: date),
                                      minute: Calendar.current.component(.minute, from: date),
                                      second: 0,
                                      of: Date())
        }
        return nil
    }
}

// Ajout de la prévisualisation à la fin du fichier
#Preview {
    NavigationStack {
        AddMedicationView(medications: .constant([]))
    }
}

#Preview("Common Medications") {
    CommonMedicationsView { _, _ in }
}

#Preview("Time Selector") {
    TimeSelectorView(selectedTimes: .constant([]))
} 