//
//  ContentView.swift
//  Test
//
//  Created by 贾建辉 on 2024/3/4.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
                
            Spacer()
                
            Button(action: {
                configuration.isOn.toggle()
            }) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(configuration.isOn ? Color.green : Color.red)
                    .frame(width: 50, height: 29)
                    .overlay(
                        Circle()
                            .fill(Color.blue) // 小圆点的颜色被改为蓝色
                            .padding(3)
                            .offset(x: configuration.isOn ? 10 : -10)
                    )
//                    .animation(.sp)
            }
        }
    }
}

struct ContentView: View {
    @State private var isChecked = false
    
    var body: some View {
        VStack {
            Toggle(isOn: $isChecked, label: {
                Text("Toggle")
            })
            .padding()
            .toggleStyle(CustomToggleStyle())
        }
    }
}



#Preview {
    ContentView()
}
