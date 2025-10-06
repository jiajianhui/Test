//
//  ExtractingView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//

import SwiftUI

// MARK: - 【阶段3】主体跳出动画
struct ExtractingView: View {
    
    // 原图、识别后的主体
    let originalImage: UIImage
    let extractedImage: UIImage
    
    // 动画相关的变量
    @State private var originalOpacity: Double = 1.0  // 原图逐渐消失
    @State private var subjectScale: CGFloat = 0.8    // 主体放大
    @State private var subjectOffset: CGFloat = 0     // 主体移动
    @State private var showSubject = false            // 控制主体显示
    
    var body: some View {
        ZStack {
            // 【背景】原图淡出
            Image(uiImage: originalImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(originalOpacity)
            
            // 【前景】主体跳出
            if showSubject {
                Image(uiImage: extractedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .scaleEffect(subjectScale)
                    .offset(y: subjectOffset)
                    // 白色光晕效果
                    .shadow(color: .white.opacity(0.8), radius: 30)
            }
        }
        .onAppear {
            // 延迟0.2秒后开始动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showSubject = true
                
                // 动画序列
                withAnimation(.easeOut(duration: 0.8)) {
                    // 1. 原图淡出
                    originalOpacity = 0
                    
                    // 2. 主体放大
                    subjectScale = 1.2
                    
                    // 3. 主体向上移动
                    subjectOffset = -50
                }
                
                // 0.4秒后回弹
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        subjectScale = 1.0
                        subjectOffset = 0
                    }
                }
            }
        }
    }
}


#Preview {
    ExtractingView(
        originalImage: UIImage(systemName: "plus")!,
        extractedImage: UIImage(systemName: "heart")!
    )
}
