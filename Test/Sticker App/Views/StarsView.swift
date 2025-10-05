//
//  StarsView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//

import SwiftUI

// MARK: - 星空效果
struct StarsView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<40, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .opacity(Double.random(in: 0.3...0.9))
            }
        }
    }
}

#Preview {
    StarsView()
}
