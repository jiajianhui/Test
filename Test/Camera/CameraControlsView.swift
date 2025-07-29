//
//  CameraControlsView.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/28.
//

import SwiftUI
import PhotosUI

// 相机界面按钮
struct CameraControlsView: View {
    
    // 按钮函数
    var onCapture: () -> Void
    var onBack: () -> Void
    var onGallery: (UIImage) -> Void
    
    
    var btnBG: Color = .red
    var iconColor: Color = .primary
    
    // 图库相关
    @State private var selectedImage: PhotosPickerItem? = nil
    
    
    var body: some View {
        HStack {
            
            // 返回按钮
            Button {
                onBack()
            } label: {
                ZStack {
                    Circle()
                        .fill(btnBG)
                        .frame(width: 50)
                    Image(systemName: "chevron.backward")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                }
                
            }
            Spacer()
            
            // 拍照按钮
            Button (action: onCapture) {
                ZStack {
                    Circle()
                        .fill(btnBG)
                        .frame(width: 80)
                    Image(systemName: "camera.fill")
                    
                }
                
            }
            
            Spacer()
            
            // 相册按钮
            PhotosPicker(selection: $selectedImage, photoLibrary: .shared()) {
                ZStack {
                    Circle()
                        .fill(btnBG)
                        .frame(width: 50)
                    Image(systemName: "photo")
                    
                }
            }

        }
        .foregroundStyle(iconColor)
        .padding()
        .background(.regularMaterial)
        
        // 监测图库选择的照片
        .onChange(of: selectedImage) { _, newItem in
            if let newItem {
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        onGallery(uiImage) // ✅ 回调
                    }
                }
            }
        }

    }
}

#Preview {
    ZStack {
        Color.green
        CameraControlsView(onCapture: {}, onBack: {}, onGallery: {_ in })
    }
}
