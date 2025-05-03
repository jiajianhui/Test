//
//  CustomDialogView.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/6.
//

import SwiftUI

struct CustomDialogView: View {
    
    let title: String
    let description: String
    let btnTitle: String
    let cornerRadius: CGFloat
    
    //函数
    let action: () -> ()
    
    @State private var offsetValue: CGFloat = 1000
    
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .onTapGesture {
                    close()
                }
            
            VStack {
                dialogTitle
                Text(description)
                btn
            }
            //控制视图大小；true表示固定为内容大小，false表示根据内容自动调整大小
            .fixedSize(horizontal: false, vertical: true)
            
            .padding()
            .background {
                bg
            }
            .overlay(alignment: .topTrailing) {
                closeBtn
            }
            .padding(20)
            
            .offset(y: offsetValue)
            
            
            .onAppear {
                withAnimation(.spring()) {
                    offsetValue = 0
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CustomDialogView(
        title: "hello",
        description: "hello",
        btnTitle: "Get",
        cornerRadius: 20,
        action: {},
        isActive: .constant(false)
    )
}


extension CustomDialogView {
    
    var dialogTitle: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .padding()
    }
    
    var btn: some View {
        Button {
            action()
            close()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius / 2, style: .continuous)
                Text(btnTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.white)
                    .padding()
            }
            .padding()
            
        }
    }
    
    var bg: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white)
            .shadow(radius: 20 )
    }
    
    var closeBtn: some View {
        Button {
            close()
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(Color.secondary)
                .padding()
        }
    }
    
    //关闭函数
    func close() {
        
        //不要将其放在 withAnimation 中，否则快速点击时，会有BUG，但是动画效果也没了
//        isActive = false
        
        withAnimation(.spring()) {
            offsetValue = 1000
            
            //加上延时，否则快速点击时，会有BUG（只有遮罩没有主体）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isActive = false
            }
            
        }
    }
    
}
