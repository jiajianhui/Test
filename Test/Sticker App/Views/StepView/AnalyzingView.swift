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
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            
            
        }
        .overlay(alignment: .bottom) {
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
            .offset(y:60)
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
