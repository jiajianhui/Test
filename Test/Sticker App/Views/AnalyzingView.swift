//
//  AnalyzingView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//
import SwiftUI

// MARK: - 【阶段2】识别中视图（全屏图片 + 发光动画）
struct AnalyzingView: View {
    
    let image: UIImage
    @State private var glowIntensity: CGFloat = 0.3
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 【背景层】模糊的原图
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .blur(radius: 30)
                    .opacity(0.3)
                
                // 【主图层】清晰的原图 + 发光效果
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: geometry.size.height * 0.7)
                        .scaleEffect(scale)
                        .shadow(
                            color: .white.opacity(glowIntensity),
                            radius: 30
                        )
                        .overlay(
                            // 白色描边动画
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 4)
                                .shadow(
                                    color: .white.opacity(glowIntensity),
                                    radius: 20
                                )
                                .padding(10)
                        )
                    
                    // 提示文字
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(.white)
                        Text("AI 正在识别主体...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                    .padding(.top, 30)
                }
            }
        }
        .onAppear {
            // 启动动画
            // 1. 发光呼吸动画
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                glowIntensity = 1.0
            }
            
            // 2. 轻微脉动动画
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.05
            }
        }
    }
}


#Preview {
    AnalyzingView(
        image: UIImage(
            systemName: "heart",
            
            // 预览清晰
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 200)
        )!
    )
}
