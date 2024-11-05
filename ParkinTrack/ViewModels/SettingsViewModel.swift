import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var enableNotifications: Bool {
        didSet {
            saveSettings()
            // Si les notifications sont désactivées, demander l'autorisation
            if enableNotifications {
                requestNotificationPermission()
            }
        }
    }
    
    @Published var reminderTime: Double {
        didSet {
            saveSettings()
        }
    }
    
    @Published var checkTime: Double {
        didSet {
            saveSettings()
        }
    }
    
    @Published var userProfile: UserProfile {
        didSet {
            saveProfile()
        }
    }
    
    init() {
        // Initialiser d'abord toutes les propriétés
        self.enableNotifications = UserDefaults.standard.bool(forKey: "EnableNotifications")
        self.reminderTime = UserDefaults.standard.double(forKey: "ReminderTime")
        self.checkTime = UserDefaults.standard.double(forKey: "CheckTime")
        
        // Charger le profil
        if let data = UserDefaults.standard.data(forKey: "UserProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
        } else {
            self.userProfile = .empty
        }
        
        // Ensuite, définir les valeurs par défaut si nécessaire
        if self.reminderTime == 0 { self.reminderTime = 15 }
        if self.checkTime == 0 { self.checkTime = 15 }
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "UserProfile")
            print("Profil sauvegardé")
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(enableNotifications, forKey: "EnableNotifications")
        UserDefaults.standard.set(reminderTime, forKey: "ReminderTime")
        UserDefaults.standard.set(checkTime, forKey: "CheckTime")
        print("Paramètres sauvegardés")
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Autorisation des notifications accordée")
            } else if let error = error {
                print("Erreur d'autorisation des notifications: \(error.localizedDescription)")
            }
        }
    }
} 