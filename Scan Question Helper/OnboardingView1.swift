import SwiftUI

struct OnboardingView1: View {
    var body: some View {
        NavigationView {
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
                        Image("SolvoLogo") // Replace with your app's logo
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
                
                // Title and Description
                Text("Scan Math Problems\nand Get Step-by-Step\nSolutions")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Page Indicator
                PageIndicator(currentPage: 0, totalPages: 3)
                
                // Navigation Button
                NavigationLink(destination: OnboardingView2().navigationBarBackButtonHidden(true)) {
                    HStack {
                        Text("Continue")
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
            .background(Color.black)
            .foregroundColor(.white)
        }
        .navigationBarHidden(true)
    }
}

struct OnboardingView1_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView1()
    }
} 