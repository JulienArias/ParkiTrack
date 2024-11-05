import SwiftUI

class SymptomViewModel: ObservableObject {
    @Published var symptomEntries: [SymptomEntry] = [] {
        didSet {
            saveSymptoms()
            print("Données sauvegardées: \(symptomEntries.count) entrées")
        }
    }
    
    init() {
        loadSymptoms()
        print("Données chargées: \(symptomEntries.count) entrées")
    }
    
    func addSymptom(_ state: SymptomState) {
        let entry = SymptomEntry(state: state)
        symptomEntries.append(entry)
        print("Nouvel état ajouté: \(state)")
    }
    
    func resetAll() {
        print("Suppression de toutes les données")
        symptomEntries.removeAll()
        UserDefaults.standard.removeObject(forKey: "SymptomEntries")
        objectWillChange.send()
        print("Données supprimées")
    }
    
    private func saveSymptoms() {
        if let encoded = try? JSONEncoder().encode(symptomEntries) {
            UserDefaults.standard.set(encoded, forKey: "SymptomEntries")
        }
    }
    
    private func loadSymptoms() {
        if let data = UserDefaults.standard.data(forKey: "SymptomEntries"),
           let decoded = try? JSONDecoder().decode([SymptomEntry].self, from: data) {
            symptomEntries = decoded
        }
    }
} 