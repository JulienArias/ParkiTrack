import Foundation

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var birthDate: Date
    var diagnosisYear: Int
    var neurologistName: String
    var medications: [String]
    var otherConditions: String
    var emergencyContact: String
    var notes: String
    
    static let empty = UserProfile(
        firstName: "",
        lastName: "",
        birthDate: Date(),
        diagnosisYear: Calendar.current.component(.year, from: Date()),
        neurologistName: "",
        medications: [],
        otherConditions: "",
        emergencyContact: "",
        notes: ""
    )
} 