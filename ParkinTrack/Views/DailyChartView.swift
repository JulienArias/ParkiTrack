import SwiftUI
import Charts

struct DailyChartView: View {
    let title: String
    let data: [SymptomEntry]
    let type: ChartType
    
    enum ChartType {
        case onOff, dyskinesia, tremor
    }
    
    // Créneaux de 30 minutes sur 24h
    private let timeSlots: [String] = {
        var slots: [String] = []
        for hour in 0..<24 {
            slots.append(String(format: "%02d:00", hour))
            slots.append(String(format: "%02d:30", hour))
        }
        return slots
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.primary)
            
            Chart(timeSlots, id: \.self) { slot in
                let stats = calculateStats(for: slot)
                
                switch type {
                case .onOff:
                    BarMark(
                        x: .value("Heure", slot),
                        y: .value("État ON/OFF", stats.onOffValue),
                        width: .fixed(4)
                    )
                    .foregroundStyle(stats.onOffValue >= 0 ? AppTheme.secondary : AppTheme.warning)
                    
                case .dyskinesia:
                    BarMark(
                        x: .value("Heure", slot),
                        y: .value("Dyskinésies", Double(stats.dysCount)),
                        width: .fixed(4)
                    )
                    .foregroundStyle(AppTheme.accent)
                    
                case .tremor:
                    BarMark(
                        x: .value("Heure", slot),
                        y: .value("Tremblements", Double(stats.tremCount)),
                        width: .fixed(4)
                    )
                    .foregroundStyle(AppTheme.tremColor)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(radius: AppTheme.shadowRadius)
    }
    
    // Fonction de calcul des statistiques
    private func calculateStats(for slot: String) -> (onOffValue: Double, dysCount: Int, tremCount: Int) {
        let components = slot.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return (0, 0, 0)
        }
        
        let calendar = Calendar.current
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        
        let slotEntries = data.filter { entry in
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
} 