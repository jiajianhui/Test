//
//  BottomButtonsView.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//
import SwiftUI

// MARK: - 底部按钮区域
struct BottomButtonsView: View {
    let state: ProcessingState
    let onSelectPhoto: () -> Void
    let onRetake: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // 完成后的操作按钮
            if state == .completed {
                HStack(spacing: 15) {
                    Button(action: onRetake) {
                        Text("重新制作")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onSave) {
                        Text("保存贴纸")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // 选择照片按钮（初始状态显示）
            if state == .initial {
                Button(action: onSelectPhoto) {
                    Label("选择照片", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom))
            }
        }
        .padding(.bottom, 40)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: state)
    }
}

#Preview {
    BottomButtonsView(state: .initial, onSelectPhoto: {}, onRetake: {}, onSave: {})
}
