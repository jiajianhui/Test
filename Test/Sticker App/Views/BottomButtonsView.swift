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
                    BottomButton(title: "重新制作", backgroundColor: .white.opacity(0.2), textColor: .white, action: onRetake)
                    BottomButton(title: "保存贴纸", backgroundColor: .white, textColor: .black, action: onSave)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // 选择照片按钮（初始状态显示）
            if state == .initial {
                BottomButton(title: "选择照片", backgroundColor: .white, textColor: .black, action: onSelectPhoto)
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            
        }
        .padding(.bottom, 40)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: state)
    }
}

#Preview {
    BottomButtonsView(state: .initial, onSelectPhoto: {}, onRetake: {}, onSave: {})
}
