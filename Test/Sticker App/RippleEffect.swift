//
//  RippleEffect.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/8.
//
import SwiftUI

struct RippleEffect: ViewModifier {
    var color: Color = .blue
    
    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(color.opacity(0.4), lineWidth: 3)
                            .scaleEffect(animate ? 2.5 : 0.1)
                            .opacity(animate ? 0.0 : 1.0)
                            .animation(
                                .easeOut(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(i) * 0.5),
                                value: animate
                            )
                    }
                }
            )
            .onAppear { animate = true }
    }
}

extension View {
    func rippleEffect(color: Color = .blue) -> some View {
        modifier(RippleEffect(color: color))
    }
}


struct ContentVieww: View {
    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 80, height: 80)
            .rippleEffect(color: .brown)
    }
}


#Preview {
    ContentVieww()
}
