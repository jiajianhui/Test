//
//  LoadImage.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/18.
//

import SwiftUI

struct LoadImage: View {
    var body: some View {
        VStack {
            
            // 1、常规显示图片
            AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/78072865?v=4")) { image in
                image
                    .resizable()  // 在这里才能控制图片的大小
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 300, height: 300)
            
            // 2、图片加载过程的三个状态：成功、失败、进行中
            AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/78072865?v=4")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    Text("加载图片时出错")
                } else {
                    ProgressView()
                        .tint(.green)
                }
            }
            .frame(width: 200, height: 200)
        }
    }
}

#Preview {
    LoadImage()
}
