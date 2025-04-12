//
//  TabBarView.swift
//  AI Homework Helper
//
//  Created by Ayush Mahna on 2/2/25.
//

import SwiftUI
import SuperwallKit

struct TabBarView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ChatsView()
            }
            .tabItem {
                Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(0)
            
            NavigationStack {
                ScanView()
            }
            .tabItem {
                Label("Scan", systemImage: "viewfinder")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .accentColor(.purple)
        .onAppear {
            // This code runs once when the TabView appears.
            // For example, register an event to display the paywall.
            Superwall.shared.register(placement: "campaign_trigger")
        }
    }
}



struct ChatIconView: View {
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(color)
                .frame(width: 80, height: 80)
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
        }
    }
}


struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
