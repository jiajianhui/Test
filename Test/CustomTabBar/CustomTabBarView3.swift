//
//  CustomTabBarView3.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/10.
//

import SwiftUI

//CaseIterable用于提供枚举中的集合
enum Tab: String, CaseIterable {
    case house
    case message
    case person
    case leaf
    case gearshape
}

struct CustomTabBarView3: View {
    
    @State var selectedTab: Tab = .house
    
    private var selectedIcon: String {
        selectedTab.rawValue + ".fill"
    }
    
    private var tabColor: Color {
        switch selectedTab {
        case .house:
            return .green
        case .message:
            return .blue
        case .person:
            return .orange
        case .leaf:
            return .pink
        case .gearshape:
            return .purple
        }
    }
    
    private let height: CGFloat = 80
    
    var body: some View {
        ZStack {
            
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.rawValue) { item in
                    HStack {
                        Image(systemName: item.rawValue)
                        Text(item.rawValue)
                    }
                    .tag(item)
                }
            }
            
            icons
        }
       
    }
}

#Preview {
    CustomTabBarView3()
}


//MARK: - 组件
extension CustomTabBarView3 {
    private var icons: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { item in
                    VStack {
                        Image(systemName: item == selectedTab ? selectedIcon : item.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(item == selectedTab ? tabColor : .gray )
                            .scaleEffect(item == selectedTab ? 1.1 : 1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background {
                        Color.white.opacity(0.00001)  //增大触控区域
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedTab = item
                        }
                        
                    }
                        
                }
            }
            .padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: height)
            }
            .padding()
            .padding(.bottom, 4)
        }
        .ignoresSafeArea()
    }
    
}
