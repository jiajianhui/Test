//
//  ScrollTest.swift
//  Test
//
//  Created by 贾建辉 on 2024/3/28.
//

import SwiftUI

struct ScrollTest: View {
    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                let scrollY = proxy.frame(in: .named("detail")).minY
                let height = UIScreen.main.bounds.width + 80 + (scrollY > 0 ? scrollY  : 0)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: UIScreen.main.bounds.width, height: height)
                    .offset(y: scrollY > 0 ? -scrollY : 0)
            }
            
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ScrollTest()
}
