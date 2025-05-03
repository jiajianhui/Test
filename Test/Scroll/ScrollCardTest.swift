//
//  ScrollCardTest.swift
//  Test
//
//  Created by 贾建辉 on 2024/3/30.
//

import SwiftUI

struct ScrollCardTest: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<5) { _ in
                    card
                }
            }
            .scrollTargetLayout()
        }
        .safeAreaPadding(.horizontal, 20)
        .scrollTargetBehavior(.viewAligned)
    }
}

#Preview {
    ScrollCardTest()
}

extension ScrollCardTest {
    var card: some View {
        Rectangle()
            .fill(.green)
            .frame(width: UIScreen.main.bounds.width - 40, height: 300)
    }
    
}



