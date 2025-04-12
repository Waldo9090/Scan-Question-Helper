import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let content: AnyView
}

struct UnifiedOnboardingView: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    @AppStorage("isOnboardingComplete") var isOnboardingCompleteStorage: Bool = false
    
    // Create the onboarding pages
    private let onboardingPages: [OnboardingPage] = [
        OnboardingPage(content: AnyView(FirstOnboardingPage())),
        OnboardingPage(content: AnyView(SecondOnboardingPage())),
        OnboardingPage(content: AnyView(ThirdOnboardingPage()))
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            onboardingPages[index].content
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Bottom controls
                    VStack(spacing: 20) {
                        // Page Indicator
                        PageIndicator(currentPage: currentPage, totalPages: onboardingPages.count)
                        
                        // Continue button
                        Button(action: {
                            if currentPage < onboardingPages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                isOnboardingComplete = true
                                isOnboardingCompleteStorage = true
                            }
                        }) {
                            HStack {
                                Text(currentPage < onboardingPages.count - 1 ? "Continue" : "Get Started")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.opacity(0.8))
                            .cornerRadius(30)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
                
                NavigationLink(destination: TabBarView().navigationBarBackButtonHidden(true), isActive: $isOnboardingComplete) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// First Onboarding Page
struct FirstOnboardingPage: View {
    var body: some View {
        VStack(spacing: 20) {
            // Example Math Problem Card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. What is the solution of 3x^2 - 2x + 1 = 0")
                    Text("2. If a and b are the solutions to the equation\n(2x + 3)(3x - 1) = 7, find |a| + |b|.")
                    Text("3. Determine the solution to the equation\n-4x^2 + 28x = 49")
                        .padding(.vertical, 5)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(8)
                    Text("4. Construct a formula for the cost of any number\nof eggs at 30 cents per dozen.")
                    Text("5. What is the difference in meaning between 10\nn and n+10?\nDoes 4w mean the same as 4 + w?")
                }
                .padding(20)
                .font(.system(size: 16))
            }
            
            // Solution Popup
            ZStack {
                HStack {
                    Image("SolvoLogo")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .background(Color.black)
                        .clipShape(Circle())
                    
                    Text("Solution")
                        .fontWeight(.semibold)
                    
                    Text("x = 7/2")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
            }
            
            Spacer()
            
            Text("Scan Math Problems\nand Get Step-by-Step\nSolutions")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .foregroundColor(.white)
    }
}

// Second Onboarding Page
struct SecondOnboardingPage: View {
    let subjects = [
        ("Math Problems", "function", Color.red.opacity(0.8)),
        ("Quizzes & Tests", "checkmark.square.fill", Color.blue.opacity(0.8)),
        ("Physics", "atom", Color.green.opacity(0.8)),
        ("Biology", "leaf.fill", Color.purple.opacity(0.8)),
        ("Chemistry", "flask.fill", Color.orange.opacity(0.8))
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Top Tools Section
            VStack(spacing: 15) {
                Text("Essential Tools")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Scanner and Chat
                HStack(spacing: 15) {
                    ToolButton(
                        icon: "viewfinder.circle.fill",
                        title: "Scanner",
                        subtitle: "Snap your task\nfor answers",
                        color: Color.purple.opacity(0.8)
                    )
                    ToolButton(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Chat",
                        subtitle: "Tackle writing\nand other tasks",
                        color: Color.blue.opacity(0.8)
                    )
                }
                .padding(.horizontal)
            }
            
            // Subjects Section
            VStack(spacing: 15) {
                Text("Study Subjects")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 15) {
                    ForEach(subjects, id: \.0) { subject in
                        SubjectButton(
                            icon: subject.1,
                            title: subject.0,
                            color: subject.2
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Conquer Any Task\nwith Powerful\nStudy Tools")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .foregroundColor(.white)
    }
}

// Third Onboarding Page
struct ThirdOnboardingPage: View {
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(spacing: 15) {
                    ReviewCard(
                        text: "This helped me help my daughter with her homework !!! We went thru all the steps and got her home work done in no time",
                        rating: 5
                    )
                    
                    ReviewCard(
                        title: "Thanks!",
                        author: "Margot 🐷",
                        date: "09/27/2023",
                        text: "It helped me really well not only with giving answers but explaining how to find the answer.",
                        rating: 5
                    )
                    
                    ReviewCard(
                        title: "Definitely a must",
                        author: "MeloMamba",
                        date: "10/23/2023",
                        text: "Definitely does what it says. Awesome app fast results. Checking work a super breeze now!!!",
                        rating: 5
                    )
                    
                    ReviewCard(
                        title: "Classwork",
                        author: "El_pero_dotty",
                        date: "10/26/2023",
                        text: "I was not doing anything for 2 months and somehow bounced back, thank you Solvo.",
                        rating: 5
                    )
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Join 1M\nHappy Users")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .foregroundColor(.white)
    }
}

struct UnifiedOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        UnifiedOnboardingView()
    }
} 