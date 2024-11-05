import Foundation

struct SymptomEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let state: SymptomState
    
    init(state: SymptomState, date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.state = state
    }
    
    static func == (lhs: SymptomEntry, rhs: SymptomEntry) -> Bool {
        lhs.id == rhs.id
    }
} 