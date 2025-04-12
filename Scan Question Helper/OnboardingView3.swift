import SwiftUI

struct OnboardingView3: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Top Visual: Grid of Subject Icons with a radial glow background behind them.
                ZStack {
                    RadialGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.black.opacity(0)]),
                        center: .trailing,
                        startRadius: 10,
                        endRadius: 300
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ],
                        spacing: 20
                    ) {
                        ForEach(0..<9, id: \.self) { index in
                            SubjectIcon(iconName: subjectIcons[index], color: subjectColors[index])
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
                
                // Title and Subtitle Text
                VStack(spacing: 8) {
                    Text("Receive expert help across\nvarious subjects")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("Chat with AI to get precise answers that enhance your understanding and performance in every subject.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                }
                
                Spacer() // Pushes the continue button to the bottom.
                
                // Continue Button with same bottom padding as in OnboardingView2.
                ContinueNavigationButton(destination: AppRatingsView().navigationBarBackButtonHidden(true))
                    .padding(.bottom, 40)
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
}

// Subview for Subject Icons remains unchanged.
struct SubjectIcon: View {
    let iconName: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(color)
                .frame(width: 80, height: 80)
            
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
        }
    }
}

let subjectIcons = [
    "dna", "textformat", "pencil",
    "flask", "book", "music.note",
    "atom", "chart.bar", "sportscourt"
]

let subjectColors = [
    Color.green, Color.red, Color.orange,
    Color.purple, Color.blue, Color.yellow,
    Color.cyan, Color.indigo, Color.purple
]

struct OnboardingView3_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView3()
    }
}
