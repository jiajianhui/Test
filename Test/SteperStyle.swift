//
//  SteperStyle.swift
//  Test
//
//  Created by 贾建辉 on 2024/3/18.
//

import SwiftUI

struct CustomStepperView: View {
    @State private var value = 0
    
    var body: some View {
        HStack {
            Button(action: {
                self.value -= 1
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width: 60, height: 50)
                    .overlay {
                        Image(systemName: "minus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                            .foregroundStyle(Color.primary)
                            .fontWeight(.regular)
                    }
            }
            
            Text("\(value)")
                .padding()
                .frame(width: 50)
            
            Button(action: {
                self.value += 1
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width: 60, height: 50)
                    .overlay {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                            .foregroundStyle(Color.primary)
                            .fontWeight(.regular)
                    }
            }
        }
        .foregroundColor(.blue) // 设置按钮颜色
        .padding() // 添加填充
    }
}

struct SteperStyle: View {
    var body: some View {
        VStack {
            Text("Custom Stepper")
                .font(.title)
                .padding()
            
            CustomStepperView()
                .padding()
        }
    }
}

#Preview {
    SteperStyle()
}
