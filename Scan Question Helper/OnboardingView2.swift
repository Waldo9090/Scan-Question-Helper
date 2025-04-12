import SwiftUI
import UserNotifications

struct OnboardingView2: View {
    var body: some View {
        NavigationView {
            VStack {
                // Push all content downward.
                Spacer(minLength: 40)
                
                // Image and buttons block
                VStack(spacing: 16) {
                    Image("math") // Ensure "math" exists in assets.
                        .resizable()
                        .scaledToFit()
                        .frame(height: 350)  // Increased height for a larger image.
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    // Additional Buttons Under the Image
                    HStack(spacing: 40) {
                        Button(action: {
                            print("Image button tapped")
                        }) {
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            print("Scan button tapped")
                        }) {
                            Image(systemName: "viewfinder")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            print("Flash button tapped")
                        }) {
                            Image(systemName: "bolt")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Move text downward to be closer to the Continue button.
                VStack(spacing: 8) {
                    Text("Effortlessly scan tasks and\nlet AI handle the work")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("Easily scan your homework, and AI will analyze the problem, offering step-by-step explanations and in-depth answers.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                Spacer() // Push the text and Continue button together to the bottom.
                
                // Continue Button with Notification permission request
                ContinueNavigationButton(destination: OnboardingView3().navigationBarBackButtonHidden(true))
                    .simultaneousGesture(TapGesture().onEnded {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                            if let error = error {
                                print("Notification permission error: \(error.localizedDescription)")
                            } else {
                                print(granted ? "Notifications permission granted." : "Notifications permission denied.")
                            }
                        }
                    })
                    .padding(.bottom, 40) // Adds extra space at the bottom if needed.
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
}
