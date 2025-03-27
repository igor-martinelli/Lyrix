import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var dummyField = ""  // For keyboard pre-warming
    @State private var dummyTap = false  // For gesture pre-warming
    @State private var dummyScroll = 0.0  // For scroll pre-warming
    @State private var dummyNav = false   // For navigation pre-warming
    @State private var showTutorial = !UserDefaults.standard.bool(forKey: "hasSeenTutorialKey")
    
    var body: some View {
        if isActive {
            if showTutorial {
                TutorialView(showTutorial: $showTutorial)
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Hidden elements for pre-warming
                Group {
                    // Pre-warm keyboard
                    TextField("", text: $dummyField)
                    
                    // Pre-warm tap gesture
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dummyTap.toggle()
                        }
                    
                    // Pre-warm scroll view
                    ScrollView {
                        Color.clear
                            .frame(height: 1)
                    }
                    .scrollDisabled(true)
                    
                    // Pre-warm list
                    List {
                        Color.clear
                            .frame(height: 1)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    
                    // Pre-warm navigation
                    EmptyView()
                        .navigationDestination(isPresented: $dummyNav) {
                            Color.clear
                        }
                    
                    // Pre-warm image loading
                    AsyncImage(url: URL(string: "https://example.com")) { _ in
                        EmptyView()
                    }
                }
                .frame(width: 0, height: 0)
                .opacity(0)
                
                Text("Lyrix")
                    .font(ThemeManager.logoFont(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        // First animation phase
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 1.1
                            self.opacity = 1.0
                        }
                        
                        // Perform all initialization tasks
                        Task {
                            async let historyLoad = HistoryStorage.shared.loadHistory()
                            async let cachePrewarm: () = CacheManager.shared.prewarmCache()
                            async let apiPrewarm: () = SpotifyAPIManager.shared.prewarmConnection()
                            
                            // Pre-warm UI systems
                            DispatchQueue.main.async {
                                // Trigger gesture system
                                dummyTap.toggle()
                                
                                // Trigger scroll system
                                withAnimation {
                                    dummyScroll = 1.0
                                }
                                
                                // Trigger navigation
                                dummyNav = true
                                dummyNav = false
                                
                                // Trigger network system
                                URLSession.shared.dataTask(with: URL(string: "https://apple.com")!) { _, _, _ in }.resume()
                            }
                            
                            // Wait for all tasks to complete
                            _ = await (historyLoad, cachePrewarm, apiPrewarm)
                            
                            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5s
                            
                            // Final animation phase
                            withAnimation(.easeOut(duration: 0.3)) {
                                self.size = 1.3
                                self.opacity = 0
                                self.isActive = true
                            }
                        }
                    }
            }
        }
    }
} 
