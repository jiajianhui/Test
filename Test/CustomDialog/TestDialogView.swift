//
//  TestDialogView.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/6.
//

import SwiftUI

struct TestDialogView: View {
    
    @State var isActive: Bool = false
    
    
    var body: some View {
        ZStack {
            Button("showDialog") {
                isActive = true
            }
            
            if isActive {
                CustomDialogView(title: "hello", description: "hello", btnTitle: "Get", cornerRadius: 30, action: {
                    print("hello")
                }, isActive: $isActive)
            }
        }
    }
}

#Preview {
    TestDialogView()
}
