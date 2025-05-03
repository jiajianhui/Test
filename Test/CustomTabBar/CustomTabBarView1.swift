//
//  CustomTabBarView.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/8.
//

import SwiftUI

struct TapItem: Identifiable {
    let id = UUID()
    let icon: String
    let tap: Tap
    
}

let tapItems: [TapItem] = [
    TapItem(icon: "house", tap: .home),
    TapItem(icon: "magnifyingglass", tap: .magnify),
    TapItem(icon: "bell", tap: .bell),
    TapItem(icon: "rectangle.stack", tap: .rect)
]


enum Tap: String {
    case home, magnify, bell, rect
}

struct CustomTabBarView1: View {
    
    @State var selectedTap: Tap = .home
    
    var body: some View {
        
        HStack {
            icons
        }
        .frame(width: 360, height: 90)
        .background {
            bg
        }
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        
    }
}

#Preview {
    CustomTabBarView1()
}


extension CustomTabBarView1 {
    private var icons: some View {
        ForEach(tapItems) { item in
            Button {
                withAnimation(.default) {
                    selectedTap = item.tap
                }
            } label: {
                VStack {
                    Image(systemName: item.icon)
                        .symbolVariant(.fill)
                    Circle()
                        .frame(width: 6)
                        .offset(y: 4)
                        .opacity(selectedTap == item.tap ? 1 : 0)
                }
                .foregroundStyle(selectedTap == item.tap ? .green : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var bg: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color(uiColor: .systemGray6), .white], startPoint: .top, endPoint: .bottom)
                )
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white, lineWidth: 1)
        }
    }
}
