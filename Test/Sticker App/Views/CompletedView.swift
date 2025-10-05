//
//  CompletedView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//
import SwiftUI

// MARK: - 【阶段4】完成视图（邮票卡片）
struct CompletedView: View {
    let image: UIImage
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
            
            // 邮票卡片
            ZStack {
                // 卡片内容
                VStack(spacing: 0) {
                    // 主体图片 + 白边
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(30)
                        .background(
                            // 白色描边
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 5)
                        )
                    
                    // 底部标签
                    if showContent {
                        VStack(spacing: 5) {
                            Text("AI 生成贴纸")
                                .font(.headline)
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(width: 320, height: 450)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // 邮票齿孔边框
                StampBorderShape()
                    .stroke(Color.white, lineWidth: 15)
                    .frame(width: 320, height: 450)
                    .scaleEffect(borderScale)
                    .opacity(borderOpacity)
            }
        }
        .onAppear {
            // 边框飞入动画
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                borderScale = 1.0
                borderOpacity = 1.0
            }
            
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
    CompletedView(image: UIImage(systemName: "heart")!)
}
