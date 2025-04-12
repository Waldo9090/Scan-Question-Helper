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
    @State private var showCameraView = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Discover Tab
                NavigationStack {
                    DiscoverView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "square.stack.fill" : "square.stack")
                        Text("Discover")
                    }
                }
                .tag(0)
                
                // Chat Tab
                NavigationStack {
                    ChatListView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                        Text("Chat")
                    }
                }
                .tag(1)
                
                // History Tab
                NavigationStack {
                    HistoryView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "clock.fill" : "clock")
                        Text("History")
                    }
                }
                .tag(2)
                
                // Profile Tab
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        Text("Profile")
                    }
                }
                .tag(3)
            }
            .accentColor(.purple)
            .onAppear {
                // Register Superwall event
                Superwall.shared.register(placement: "campaign_trigger")
                
                // Customize tab bar appearance
                let appearance = UITabBarAppearance()
                appearance.backgroundColor = .black
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Custom center scan button overlay
            Button(action: {
                showCameraView = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 2)
                    
                    Image(systemName: "viewfinder")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -30)
            .fullScreenCover(isPresented: $showCameraView) {
                CustomCameraView()
            }
        }
    }
}

// Discover View
struct DiscoverView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Study Tools Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Study Tools", subtitle: "Essential tools for your learning journey")
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ToolItem(icon: "viewfinder", title: "Scanner", subtitle: "Solve tasks\nby photo")
                        ToolItem(icon: "bubble.left.and.bubble.right", title: "Chat", subtitle: "Tackle writing\nand more")
                        ToolItem(icon: "plus.minus", title: "Calculator", subtitle: "Do math\nmanually")
                    }
                }
                .padding(.horizontal)
                
                // Scan to Solve Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Scan to Solve", subtitle: "Take a photo of your problem to get instant solutions")
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        SubjectItem(title: "Math Problems", icon: "function", color: Color(hex: "#FF6B6B"))
                        SubjectItem(title: "Quizzes & Tests", icon: "checkmark.square.fill", color: Color(hex: "#4ECDC4"))
                        SubjectItem(title: "Physics", icon: "atom", color: Color(hex: "#45B7D1"))
                        SubjectItem(title: "Biology", icon: "leaf.fill", color: Color(hex: "#96CEB4"))
                        SubjectItem(title: "Chemistry", icon: "flask.fill", color: Color(hex: "#FFBE0B"))
                        SubjectItem(title: "Other Tasks", icon: "square.stack.3d.up.fill", color: Color(hex: "#9B5DE5"))
                    }
                }
                .padding(.horizontal)
                
                // Chat to Solve Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Chat to Solve", subtitle: "Get help with writing and complex problems")
                    
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
                        ChatSolveItem(title: "Create Essay", icon: "pencil.and.outline", color: Color(hex: "#FF9F1C"))
                        ChatSolveItem(title: "Compose Text", icon: "text.bubble.fill", color: Color(hex: "#2EC4B6"))
                        ChatSolveItem(title: "Generate Summary", icon: "doc.text.fill", color: Color(hex: "#E71D36"))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .navigationTitle("Discover")
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

// History View


// Profile View


// Helper Views
struct ToolItem: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct SubjectItem: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(color.opacity(0.8))
        .cornerRadius(15)
    }
}

struct ChatSolveItem: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(color.opacity(0.8))
            .cornerRadius(15)
        }
    }
}

// Color Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
