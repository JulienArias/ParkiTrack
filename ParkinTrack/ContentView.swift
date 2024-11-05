//
//  ContentView.swift
//  ParkinTrack
//
//  Created by JULIEN ARIAS on 04/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var symptomViewModel = SymptomViewModel()
    
    var body: some View {
        TabView {
            StateView()
                .environmentObject(symptomViewModel)
                .tabItem {
                    Label("État", systemImage: "heart.fill")
                }
            
            StatsView()
                .environmentObject(symptomViewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            MedicationView()
                .tabItem {
                    Label("Médicaments", systemImage: "pills.fill")
                }
            
            SettingsView()
                .environmentObject(symptomViewModel)
                .tabItem {
                    Label("Paramètres", systemImage: "gear")
                }
        }
        .tint(AppTheme.primary)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
