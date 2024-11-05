import Foundation

struct Medication: Identifiable, Codable {
    let id: UUID
    var name: String
    var dosage: Double
    var scheduledTimes: [Date]
    
    init(name: String, dosage: Double, scheduledTimes: [Date]) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.scheduledTimes = scheduledTimes
    }
} 