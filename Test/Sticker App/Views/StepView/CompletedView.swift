//
//  CompletedView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//
import SwiftUI

// MARK: - 【阶段4】完成视图（邮票卡片）
struct CompletedView: View {
    
    // 图片主体
    let image: UIImage
    let backgroundColor: Color
    
    // 动画相关的变量
    @State private var borderScale: CGFloat = 0    // 边框从小到大
    @State private var borderOpacity: Double = 0   // 边框淡入
    @State private var showContent = false          // 内容延迟显示
    
    var body: some View {
        VStack(spacing: 20) {
            // 成功提示
            if showContent {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("提取完成")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.3))
                .cornerRadius(20)
                .transition(.scale.combined(with: .opacity))
            }
            
            VStack {
                // 主体图片
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320)
                    .shadow(radius: 4)
                
                // 底部标签
                if showContent {
                    VStack(spacing: 5) {
                        Text("AI 生成贴纸")
                            .font(.headline)
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(width: 320, height: 430)
            .background(content: {
                ZStack {
                    backgroundColor
                    DotGridBackground()
                }
                .padding()
            })
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
        }
        .onAppear {
            
            // 内容延迟显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview {
    CompletedView(image: UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 200))!, backgroundColor: .green)
}
