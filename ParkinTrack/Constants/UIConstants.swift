import SwiftUI

enum UIConstants {
    static let stateButtonHeight: CGFloat = 60
    static let standardPadding: CGFloat = 16
    static let compactPadding: CGFloat = 8
    
    static let stateButtons: [(title: String, icon: String, color: Color, state: SymptomState)] = [
        ("On", "sun.max.fill", AppTheme.secondary, .on),
        ("Off", "moon.fill", AppTheme.warning, .off),
        ("Dys", "waveform.path.ecg.rectangle.fill", AppTheme.accent, .dys),
        ("Trem", "hand.raised.fill", AppTheme.tremColor, .trem)
    ]
    
    static let stateDescriptions: [(icon: String, color: Color, text: String)] = [
        ("sun.max.fill", AppTheme.secondary, "On : Médicaments efficaces, symptômes contrôlés"),
        ("moon.fill", AppTheme.warning, "Off : Médicaments moins efficaces, symptômes présents"),
        ("waveform.path.ecg.rectangle.fill", AppTheme.accent, "Dys : Mouvements involontaires gênants"),
        ("hand.raised.fill", AppTheme.tremColor, "Trem : Présence de tremblements")
    ]
} 