//
//  SymbolAnimationView.swift
//  Test
//
//  Created by 贾建辉 on 2024/5/3.
//

import SwiftUI

struct SymbolAnimationView: View {
    
    @State var isPresse: Bool = false
    
    var body: some View {
        Image(systemName: "play.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100)
            .foregroundStyle(.blue)
        
            .symbolEffect(.bounce, value: isPresse)
        
            .onTapGesture {
                isPresse.toggle()
            }

    }
}

#Preview {
    SymbolAnimationView()
}
