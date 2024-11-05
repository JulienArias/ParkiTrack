import PDFKit
import UIKit
import Charts

class StatsPDFCreator {
    private let symptomData: [SymptomEntry]
    private let medications: [Medication]
    private let timeSlots: [String]
    private let userProfile: UserProfile
    
    init(symptomData: [SymptomEntry], medications: [Medication], userProfile: UserProfile) {
        self.symptomData = symptomData
        self.medications = medications
        self.userProfile = userProfile
        
        // Créer les créneaux horaires
        var slots: [String] = []
        for hour in 0..<24 {
            slots.append(String(format: "%02d:00", hour))
            slots.append(String(format: "%02d:30", hour))
        }
        self.timeSlots = slots
    }
    
    func createPDF() -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            var yPosition: CGFloat = 40
            
            // En-tête avec informations patient
            yPosition = drawHeader(yPosition: yPosition)
            
            // Informations patient
            yPosition = drawPatientInfo(yPosition: yPosition + 20)
            
            // Résumé des statistiques
            yPosition = drawSummaryStats(yPosition: yPosition + 20)
            
            // Capture et dessin des graphiques
            let chartHeight: CGFloat = 841.8 * 0.15
            
            // Graphique ON/OFF
            let onOffChart = DailyChartView(
                title: "États ON/OFF",
                data: symptomData,
                type: .onOff
            )
            .frame(height: chartHeight)
            let onOffImage = onOffChart.snapshot()
            onOffImage.draw(in: CGRect(x: 50, y: yPosition + 20, width: 495.2, height: chartHeight))
            yPosition += chartHeight + 30
            
            // Graphique Dyskinésies
            let dysChart = DailyChartView(
                title: "Dyskinésies",
                data: symptomData,
                type: .dyskinesia
            )
            .frame(height: chartHeight)
            let dysImage = dysChart.snapshot()
            dysImage.draw(in: CGRect(x: 50, y: yPosition + 20, width: 495.2, height: chartHeight))
            yPosition += chartHeight + 30
            
            // Graphique Tremblements
            let tremChart = DailyChartView(
                title: "Tremblements",
                data: symptomData,
                type: .tremor
            )
            .frame(height: chartHeight)
            let tremImage = tremChart.snapshot()
            tremImage.draw(in: CGRect(x: 50, y: yPosition + 20, width: 495.2, height: chartHeight))
            yPosition += chartHeight + 30
            
            // Liste des médicaments
            yPosition = drawMedicationList(yPosition: yPosition + 30)
        }
        
        return data
    }
    
    private func drawPatientInfo(yPosition: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14)
        ]
        
        let age = Calendar.current.dateComponents([.year], from: userProfile.birthDate, to: Date()).year ?? 0
        
        let patientInfo = """
        Patient : \(userProfile.firstName) \(userProfile.lastName)
        Âge : \(age) ans
        Diagnostic : \(userProfile.diagnosisYear)
        """
        
        patientInfo.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: attributes)
        
        return yPosition + 60
    }
    
    private func drawHeader(yPosition: CGFloat) -> CGFloat {
        // Dessiner l'icône de l'application
        if let appIcon = UIImage(named: "AppIcon") {
            let iconSize: CGFloat = 40
            let iconRect = CGRect(x: 50, y: yPosition, width: iconSize, height: iconSize)
            appIcon.draw(in: iconRect)
            
            // Nom de l'application
            let appNameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor(AppTheme.primary)
            ]
            "ParkinTrack".draw(at: CGPoint(x: 100, y: yPosition + 8), withAttributes: appNameAttributes)
            
            // Titre du rapport
            let title = "Rapport d'états - 4 dernières semaines"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            title.draw(at: CGPoint(x: 50, y: yPosition + 60), withAttributes: titleAttributes)
            
            // Date du rapport
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = "Généré le \(dateFormatter.string(from: Date()))"
            dateString.draw(at: CGPoint(x: 50, y: yPosition + 90), withAttributes: [
                .font: UIFont.systemFont(ofSize: 12)
            ])
            
            return yPosition + 110
        } else {
            // Fallback si l'icône n'est pas disponible
            let title = "Rapport d'états - 4 dernières semaines"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = "Généré le \(dateFormatter.string(from: Date()))"
            dateString.draw(at: CGPoint(x: 50, y: yPosition + 30), withAttributes: [
                .font: UIFont.systemFont(ofSize: 12)
            ])
            
            return yPosition + 50
        }
    }
    
    private func drawSummaryStats(yPosition: CGFloat) -> CGFloat {
        let summary = calculateSummaryStats()
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
        "Résumé".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14)
        ]
        
        var currentY = yPosition + 25
        for stat in summary {
            stat.draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
            currentY += 20
        }
        
        return currentY
    }
    
    private func drawMedicationList(yPosition: CGFloat) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
        // Titre avec ligne de séparation
        "Médicaments prescrits".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
        
        // Ligne de séparation
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 50, y: yPosition + 25))
        path.addLine(to: CGPoint(x: 545, y: yPosition + 25))
        UIColor.gray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12)
        ]
        
        var currentY = yPosition + 40
        for medication in medications {
            // Nom et dosage
            let nameAndDosage = "\(medication.name) - \(medication.dosage) comprimé(s)"
            nameAndDosage.draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
            currentY += 20
            
            // Horaires sur une ligne séparée et indentée
            let times = "Horaires : " + medication.scheduledTimes
                .map { $0.formatted(date: .omitted, time: .shortened) }
                .joined(separator: ", ")
            times.draw(at: CGPoint(x: 90, y: currentY), withAttributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.gray
            ])
            currentY += 30 // Plus d'espace entre les médicaments
        }
        
        return currentY
    }
    
    private enum ChartDataType {
        case onOff, dyskinesia, tremor
    }
    
    private func calculateSummaryStats() -> [String] {
        var summary: [String] = []
        var bestHour = (hour: 0, ratio: -1.0)
        var worstHour = (hour: 0, ratio: 1.0)
        var totalOnTime = 0.0
        var totalEntries = 0
        
        // Calculer les statistiques comme dans DailyStatsView
        for slot in timeSlots {
            let components = slot.split(separator: ":")
            if let hour = Int(components[0]) {
                let stats = calculateStats(for: slot)
                
                if stats.onOffValue > bestHour.ratio {
                    bestHour = (hour, stats.onOffValue)
                }
                if stats.onOffValue < worstHour.ratio && stats.onOffValue != 0 {
                    worstHour = (hour, stats.onOffValue)
                }
                
                if stats.onOffValue > 0 {
                    totalOnTime += stats.onOffValue
                    totalEntries += 1
                }
            }
        }
        
        if bestHour.ratio > 0 {
            summary.append("Meilleur moment : \(bestHour.hour)h (\(Int(bestHour.ratio))% ON)")
        }
        if worstHour.ratio < 0 {
            summary.append("Moment difficile : \(worstHour.hour)h (\(Int(abs(worstHour.ratio)))% OFF)")
        }
        if totalEntries > 0 {
            let averageOnTime = totalOnTime / Double(totalEntries)
            summary.append("Moyenne journalière : \(Int(averageOnTime))% ON")
        }
        
        return summary
    }
    
    // Fonction reprise de DailyStatsView pour les calculs
    private func calculateStats(for slot: String) -> (onOffValue: Double, dysCount: Int, tremCount: Int) {
        let components = slot.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return (0, 0, 0)
        }
        
        let calendar = Calendar.current
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        
        let slotEntries = symptomData.filter { entry in
            let entryHour = calendar.component(.hour, from: entry.date)
            let entryMinute = calendar.component(.minute, from: entry.date)
            
            let isInTimeRange = entry.date >= fourWeeksAgo
            let isInSlot = entryHour == hour && (
                minute == 0 ? (entryMinute < 30) : (entryMinute >= 30)
            )
            
            return isInTimeRange && isInSlot
        }
        
        let onCount = Double(slotEntries.filter { $0.state == .on }.count)
        let offCount = Double(slotEntries.filter { $0.state == .off }.count)
        let dysCount = slotEntries.filter { $0.state == .dys }.count
        let tremCount = slotEntries.filter { $0.state == .trem }.count
        
        let totalCount = onCount + offCount
        let onOffValue = totalCount > 0 ? ((onCount - offCount) / totalCount) * 100 : 0
        
        return (onOffValue, dysCount, tremCount)
    }
    
    // Nouvelles fonctions d'aide
    private func calculateDataPoints(for type: ChartDataType) -> [(x: Int, y: Double)] {
        return timeSlots.enumerated().map { index, slot in
            let stats = calculateStats(for: slot)
            switch type {
            case .onOff:
                return (index, stats.onOffValue)
            case .dyskinesia:
                return (index, Double(stats.dysCount))
            case .tremor:
                return (index, Double(stats.tremCount))
            }
        }
    }
    
    private func calculateBarHeight(value: Double, type: ChartDataType, maxHeight: CGFloat) -> CGFloat {
        switch type {
        case .onOff:
            let normalizedValue = (value + 100) / 200 // Convertir -100...100 en 0...1
            return CGFloat(normalizedValue) * maxHeight
        default:
            let maxValue = type == .dyskinesia ? 10.0 : 10.0 // Ajuster selon vos besoins
            let normalizedValue = min(value / maxValue, 1.0)
            return CGFloat(normalizedValue) * maxHeight
        }
    }
    
    private func getBarColor(for type: ChartDataType, value: Double) -> UIColor {
        switch type {
        case .onOff:
            return value >= 0 ? UIColor(AppTheme.secondary) : UIColor(AppTheme.warning)
        case .dyskinesia:
            return UIColor(AppTheme.accent)
        case .tremor:
            return UIColor(AppTheme.tremColor)
        }
    }
} 