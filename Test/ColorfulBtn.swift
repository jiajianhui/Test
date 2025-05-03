//
//  ColorfulBtn.swift
//  Test
//
//  Created by 贾建辉 on 2024/3/4.
//

import SwiftUI

struct ColorfulBtn: View {
    var body: some View {
        VStack {
            Text("hello")
                .background {
                    GeometryReader { geometry in
                                Image("btnBg02") // 替换成您的图像名称
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            }
                }
            
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 300, height: 64)
                    .overlay {
                        Image("btnBg02")
                            .resizable()
                        
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        VStack(spacing: 4) {
                            Text("立即解锁")
                                .fontWeight(.bold)
                            Text(" 一次购买，永久持有")
                                .font(.system(size: 12))
                                .opacity(0.8)
                        }
                        .foregroundStyle(Color.white)
                    }
            }
        }
    }
}

#Preview {
    ColorfulBtn()
}
