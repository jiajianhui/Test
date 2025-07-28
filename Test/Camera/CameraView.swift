//
//  CameraView.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/28.
//

import SwiftUI

struct CameraView: View {
    @State private var image: UIImage?
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 20) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }

            Button("打开自定义相机") {
                showCamera = true
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CustomCameraView(image: $image)
                .ignoresSafeArea()
        }
    }
}


#Preview {
    CameraView()
}
