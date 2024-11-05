import SwiftUI
import Charts
import PDFKit
import UniformTypeIdentifiers

struct StatsView: View {
    @EnvironmentObject var viewModel: SymptomViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showingShareSheet = false
    @State private var pdfData: Data?
    @State private var activityViewController: UIActivityViewController?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                DailyStatsView(symptomData: viewModel.symptomEntries)
            }
            .background(AppTheme.background)
            .navigationTitle("Statistiques")
            .toolbar {
                Button {
                    generateAndSharePDF()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = pdfData {
                    ShareSheet(items: [pdfData])
                        .edgesIgnoringSafeArea(.bottom)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                UIApplication.shared.windows.first?.rootViewController?
                                    .present(activityViewController!, animated: true)
                            }
                        }
                }
            }
        }
    }
    
    private func generateAndSharePDF() {
        let pdfCreator = StatsPDFCreator(
            symptomData: viewModel.symptomEntries,
            medications: [], // TODO: Injecter les médicaments depuis MedicationViewModel
            userProfile: settingsViewModel.userProfile
        )
        if let data = pdfCreator.createPDF() {
            self.pdfData = data
            self.activityViewController = UIActivityViewController(
                activityItems: [data],
                applicationActivities: nil
            )
            self.showingShareSheet = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DailyStatsView: View {
    let symptomData: [SymptomEntry]
    
    // Créneaux de 30 minutes sur 24h (de 00:00 à 23:30)
    let timeSlots: [String] = {
        var slots: [String] = []
        for hour in 0..<24 {
            slots.append(String(format: "%02d:00", hour))
            slots.append(String(format: "%02d:30", hour))
        }
        return slots
    }()
    
    // Calcul des statistiques sur 4 semaines
    func calculateStats(for slot: String) -> (onOffValue: Double, dysCount: Int, tremCount: Int) {
        let components = slot.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return (0, 0, 0)
        }
        
        let calendar = Calendar.current
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        
        // Filtrer les entrées des 4 dernières semaines pour ce créneau horaire
        let slotEntries = symptomData.filter { entry in
            let entryHour = calendar.component(.hour, from: entry.date)
            let entryMinute = calendar.component(.minute, from: entry.date)
            
            let isInTimeRange = entry.date >= fourWeeksAgo
            let isInSlot = entryHour == hour && (
                minute == 0 ? (entryMinute < 30) : (entryMinute >= 30)
            )
            
            return isInTimeRange && isInSlot
        }
        
        // Compter les états ON/OFF
        let onCount = Double(slotEntries.filter { $0.state == .on }.count)
        let offCount = Double(slotEntries.filter { $0.state == .off }.count)
        let dysCount = slotEntries.filter { $0.state == .dys }.count
        let tremCount = slotEntries.filter { $0.state == .trem }.count
        
        // Calculer la valeur ON/OFF sur une échelle de -100 à +100
        let totalCount = onCount + offCount
        let onOffValue = totalCount > 0 ? ((onCount - offCount) / totalCount) * 100 : 0
        
        // Debug
        if totalCount > 0 {
            print("Créneau \(slot) - ON: \(onCount), OFF: \(offCount), Valeur: \(onOffValue)")
        }
        
        return (onOffValue, dysCount, tremCount)
    }
    
    // Nouvelles fonctions d'analyse
    func getDailySummary() -> [(text: String, color: Color)] {
        var summary: [(text: String, color: Color)] = []
        var bestHour = (hour: 0, ratio: -1.0)
        var worstHour = (hour: 0, ratio: 1.0)
        var totalOnTime = 0.0
        var totalEntries = 0
        
        // Analyser chaque créneau horaire
        for slot in timeSlots {
            let stats = calculateStats(for: slot)
            let components = slot.split(separator: ":")
            if let hour = Int(components[0]) {
                // Trouver la meilleure et la pire heure
                if stats.onOffValue > bestHour.ratio {
                    bestHour = (hour, stats.onOffValue)
                }
                if stats.onOffValue < worstHour.ratio && stats.onOffValue != 0 {
                    worstHour = (hour, stats.onOffValue)
                }
                
                // Calculer le temps total ON
                if stats.onOffValue > 0 {
                    totalOnTime += stats.onOffValue
                    totalEntries += 1
                }
            }
        }
        
        // Générer le résumé avec les couleurs appropriées
        if bestHour.ratio > 0 {
            summary.append((
                text: "Meilleur moment : \(bestHour.hour)h (\(Int(bestHour.ratio))% ON)",
                color: AppTheme.secondary // Vert pour les bonnes périodes
            ))
        }
        if worstHour.ratio < 0 {
            summary.append((
                text: "Moment difficile : \(worstHour.hour)h (\(Int(abs(worstHour.ratio)))% OFF)",
                color: AppTheme.warning // Rouge pour les périodes difficiles
            ))
        }
        
        // Calculer le pourcentage moyen de temps ON
        if totalEntries > 0 {
            let averageOnTime = totalOnTime / Double(totalEntries)
            summary.append((
                text: "Moyenne journalière : \(Int(averageOnTime))% ON",
                color: AppTheme.primary // Bleu pour la moyenne
            ))
        }
        
        return summary
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            // Nouvelle section résumé avec couleurs
            ChartCard(
                title: "Résumé",
                subtitle: "Analyse sur 4 semaines",
                icon: "chart.line.uptrend.xyaxis"
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(getDailySummary(), id: \.text) { insight in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(insight.color)
                                .frame(width: 6, height: 6)
                            Text(insight.text)
                                .font(AppTheme.bodyStyle)
                                .foregroundStyle(insight.color)
                        }
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Graphique ON/OFF
            ChartCard(
                title: "États ON/OFF",
                subtitle: "Moyenne sur 4 semaines",
                icon: "chart.bar.fill"
            ) {
                Chart {
                    ForEach(timeSlots, id: \.self) { slot in
                        let stats = calculateStats(for: slot)
                        BarMark(
                            x: .value("Heure", slot),
                            y: .value("État ON/OFF", stats.onOffValue),
                            width: .fixed(4)
                        )
                        .foregroundStyle(stats.onOffValue >= 0 ? AppTheme.secondary : AppTheme.warning)
                    }
                    
                    RuleMark(y: .value("Neutre", 0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(.gray)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: timeSlots) { value in
                        if let timeString = value.as(String.self),
                           timeString.hasSuffix(":00"),
                           let hour = Int(timeString.prefix(2)),
                           hour % 4 == 0 {
                            AxisValueLabel {
                                Text("\(hour)")
                            }
                            AxisGridLine()
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [-100, -50, 0, 50, 100]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text("\(Int(abs(val)))")
                            }
                        }
                    }
                }
            }
            
            // Graphique Dyskinésies
            ChartCard(
                title: "Dyskinésies",
                subtitle: "Occurrences sur 4 semaines",
                icon: "chart.bar.fill"
            ) {
                Chart {
                    ForEach(timeSlots, id: \.self) { slot in
                        let stats = calculateStats(for: slot)
                        BarMark(
                            x: .value("Heure", slot),
                            y: .value("Occurrences", stats.dysCount),
                            width: .fixed(4)
                        )
                        .foregroundStyle(AppTheme.accent)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: timeSlots) { value in
                        if let timeString = value.as(String.self),
                           timeString.hasSuffix(":00"),
                           let hour = Int(timeString.prefix(2)),
                           hour % 4 == 0 {
                            AxisValueLabel {
                                Text("\(hour)")
                            }
                            AxisGridLine()
                        }
                    }
                }
            }
            
            // Graphique Tremblements
            ChartCard(
                title: "Tremblements",
                subtitle: "Occurrences sur 4 semaines",
                icon: "chart.bar.fill"
            ) {
                Chart {
                    ForEach(timeSlots, id: \.self) { slot in
                        let stats = calculateStats(for: slot)
                        BarMark(
                            x: .value("Heure", slot),
                            y: .value("Occurrences", stats.tremCount),
                            width: .fixed(4)
                        )
                        .foregroundStyle(AppTheme.tremColor)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: timeSlots) { value in
                        if let timeString = value.as(String.self),
                           timeString.hasSuffix(":00"),
                           let hour = Int(timeString.prefix(2)),
                           hour % 4 == 0 {
                            AxisValueLabel {
                                Text("\(hour)")
                            }
                            AxisGridLine()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.cardPadding)
        .padding(.vertical, AppTheme.spacing)
    }
}

struct TrendStatsView: View {
    let symptomData: [SymptomEntry]
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            ChartCard(
                title: "États ON/OFF",
                subtitle: "30 derniers jours",
                icon: "chart.bar.fill"
            ) {
                Chart {
                    BarMark(
                        x: .value("Jour", "Lun"),
                        y: .value("Heures", 4)
                    )
                    .foregroundStyle(AppTheme.secondary.gradient)
                }
                .frame(height: 200)
            }
            
            ChartCard(
                title: "Dyskinésies",
                subtitle: "30 derniers jours",
                icon: "waveform.path"
            ) {
                Chart {
                    BarMark(
                        x: .value("Jour", "Lun"),
                        y: .value("Occurrences", 2)
                    )
                    .foregroundStyle(AppTheme.accent.gradient)
                }
                .frame(height: 200)
            }
            
            ChartCard(
                title: "Tremblements",
                subtitle: "30 derniers jours",
                icon: "waveform"
            ) {
                Chart {
                    BarMark(
                        x: .value("Jour", "Lun"),
                        y: .value("Occurrences", 3)
                    )
                    .foregroundStyle(AppTheme.tremColor.gradient)
                }
                .frame(height: 200)
            }
        }
        .padding()
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(AppTheme.captionStyle)
                .foregroundColor(AppTheme.primary)
        }
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(AppTheme.headlineStyle)
                        .foregroundColor(AppTheme.primary)
                    Text(subtitle)
                        .font(AppTheme.subheadlineStyle)
                        .foregroundStyle(AppTheme.primary.opacity(0.8))
                }
            }
            content()
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(
            color: AppTheme.shadowColor,
            radius: AppTheme.shadowRadius,
            x: 0,
            y: AppTheme.shadowY
        )
    }
}

#Preview {
    StatsView()
} 