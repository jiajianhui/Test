//
//  PickerStyle.swift
//  Test
//
//  Created by 贾建辉 on 2024/3/18.
//

import SwiftUI

struct PickerStyle: View {
    // 定义选项数组
    let options = ["Option 1", "Option 2", "Option 3"]
    
    // 定义选择的索引
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            // 显示Picker视图
            Picker("Options", selection: $selectedIndex) {
                ForEach(0 ..< options.count, id: \.self) { index in
                    Text(self.options[index])
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // 设置选择器的样式
            
            // 根据选择显示文本
            Text("Selected option: \(options[selectedIndex])")
        }
        .padding()
    }
}

#Preview {
    PickerStyle()
}
