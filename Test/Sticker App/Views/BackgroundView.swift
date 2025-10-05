//
//  BackgroundView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//

import SwiftUI


// MARK: - 动态背景
struct BackgroundView: View {
    let state: ProcessingState
    
    var body: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                colors: backgroundColor,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 识别时的星空效果
            if state == .analyzing {
                StarsView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: state)
        .ignoresSafeArea()
    }
    
    var backgroundColor: [Color] {
        switch state {
        case .initial:
            return [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]
        case .analyzing, .extracting:
            return [Color(red: 0.1, green: 0.2, blue: 0.35), Color(red: 0.15, green: 0.25, blue: 0.45)]
        case .completed:
            return [Color.green.opacity(0.3), Color.blue.opacity(0.3)]
        }
    }
}

#Preview {
    BackgroundView(state: .initial)
}
