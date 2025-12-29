//
//  WaveEffectView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/30.
//

import SwiftUI

struct NameDropWaveEffect: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.3, green: 0.1, blue: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 多层波浪
            ForEach(0..<5, id: \.self) { index in
                WaveCircle(delay: Double(index) * 0.2)
                    .opacity(isActive ? 1 : 0)
            }
            
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isActive = true
            }
        }
        .onTapGesture {
            isActive.toggle()
        }
    }
}

// 单个波浪圆圈
struct WaveCircle: View {
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        Circle()
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.8),
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 3
            )
            .frame(width: 100, height: 100)
            .scaleEffect(animate ? 3.5 : 1)
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    NameDropWaveEffect()
}
