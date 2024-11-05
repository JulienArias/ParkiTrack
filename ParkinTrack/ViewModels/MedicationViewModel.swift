import SwiftUI

class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication] = [] {
        didSet {
            saveMedications()
        }
    }
    
    init() {
        loadMedications()
    }
    
    private func saveMedications() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "Medications")
        }
    }
    
    private func loadMedications() {
        if let data = UserDefaults.standard.data(forKey: "Medications"),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            medications = decoded
        }
    }
} 