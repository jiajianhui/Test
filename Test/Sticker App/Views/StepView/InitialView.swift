//
//  InitialView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//
import SwiftUI

// MARK: - 【阶段1】初始欢迎界面
struct InitialView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 100))
                .shadow(color: .white.opacity(0.5), radius: 20)
            
            VStack(spacing: 12) {
                Text("AI 贴纸制作器")
                    .font(.system(size: 36, weight: .bold))
                
                Text("选择照片，AI 自动提取主体")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .foregroundStyle(.primary)
    }
}


#Preview {
    InitialView()
}
