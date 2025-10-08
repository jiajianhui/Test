//
//  BottomButton.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/8.
//

import SwiftUI

struct BottomButton: View {
    
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let action: () -> Void
    
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(12)
        }
    }
}

#Preview {
    BottomButton(title: "hello", backgroundColor: .blue, textColor: .white, action: {})
}
