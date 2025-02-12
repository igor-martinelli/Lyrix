import SwiftUI
struct TutorialView: View {
    @Binding var showTutorial: Bool
    @State private var currentPage = 0
    
    let tutorialPages = [
        TutorialPage(
            image: "tutorial_home",
            text: "Search for any song by clicking on the searchbar"
        ),
        TutorialPage(
            image: "tutorial_editor",
            text: "Click on the lyrics to select the lines you want"
        ),
        TutorialPage(
            image: "tutorial_save",
            text: "Press the checkmark on the bottom right to save the wallpaper"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<tutorialPages.count, id: \.self) { index in
                    VStack(spacing: 30) {
                        Image(tutorialPages[index].image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: UIScreen.main.bounds.height * 0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 10)
                        
                        Text(tutorialPages[index].text)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        if index == tutorialPages.count - 1 {
                            Button(action: {
                                UserDefaults.standard.set(true, forKey: "hasSeenTutorialKey")
                                showTutorial = false
                            }) {
                                Text("Get Started")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 200, height: 50)
                                    .background(Color.white)
                                    .cornerRadius(25)
                            }
                            .padding(.top, -10)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

struct TutorialPage {
    let image: String
    let text: String
} 
