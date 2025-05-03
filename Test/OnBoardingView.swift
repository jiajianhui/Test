//
//  OnBoardingView.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/10.
//

import SwiftUI

struct ShowOnboardView: View {
    
    //仅在第一次启动时展示onboarding
    @AppStorage("showOnboarding") var showOnboarding: Bool = true
    
    var body: some View {
        Button {
            showOnboarding = true
        } label: {
            Text("showOnboarding")
        }
        .fullScreenCover(isPresented: $showOnboarding, content: {
            OnBoardingView(showOnboarding: $showOnboarding)
        })
    }
}

struct OnBoardingView: View {
    
    @Binding var showOnboarding: Bool
    @State private var selection: Int = 1
    
    var body: some View {
        TabView(selection:$selection) {
            TabViewItem(showOnboarding: $showOnboarding, selection: $selection, image: "heart", title: "欢迎", subTitle: "欢迎")
            .tag(1)
            
            TabViewItem(showOnboarding: $showOnboarding, selection: $selection, image: "pencil.circle", title: "你好", subTitle: "你好")
            .tag(2)
            
            TabViewItem(showOnboarding: $showOnboarding, selection: $selection, image: "pencil.and.outline", title: "开始", subTitle: "开始")
            .tag(3)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    ShowOnboardView()
}


struct TabViewItem: View {
    
    @Binding var showOnboarding: Bool
    @Binding var selection: Int
    
    var image: String
    var title: String
    var subTitle: String
    
    
    var body: some View {
        VStack {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundStyle(Color.blue)
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(subTitle)
                .font(.body)
                .foregroundStyle(.gray)
                .padding()
                .padding(.horizontal)
            Button {
                withAnimation(.spring()) {
                    if selection < 3 {
                        selection += 1
                    } else {
                        showOnboarding = false
                    }
                }
                
            } label: {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selection == 3 ? .blue : .blue.opacity(0.1))
                    .frame(width: 140, height: 50)
                    .overlay {
                        Text(selection == 3 ? "完成" : "继续")
                            .foregroundStyle(selection == 3 ? .white : .blue)
                            .fontWeight(.medium)
                    }
            }
            .padding(.top, 60)
        }
    }
}
