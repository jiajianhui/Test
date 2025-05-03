//
//  ScrollEffectView.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/7.
//

import SwiftUI

struct ScrollEffectView: View {
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 14) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .stroke(.white.opacity(0.5), lineWidth: 2)
                    
                        .frame(height: 300)
                    
                        //用于获取视图在其容器内的相对框架，.horizontal表示水平方向的值
                        .containerRelativeFrame(.horizontal)
                    
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                .rotation3DEffect(.degrees(phase.value * 20), axis: (x: 0, y: 1, z: 0))
                        }
                    
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(20)  //为视图内容添加边距
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .background (
            LinearGradient(colors: [.green, .white], startPoint: .top, endPoint: .bottom)
        )
//        .ignoresSafeArea()
    }
}

#Preview {
    ScrollEffectView()
}
