//
//  RenderView.swift
//  Test
//
//  Created by 贾建辉 on 2024/8/26.
//

import SwiftUI

struct RenderView: View {
    
    @State var image: UIImage?
    
    var body: some View {
        VStack {
            mainView()
            
            // 按钮
            if let image {
                HStack(spacing: 80) {
                    
                    //保存图片到相册
                    Button(action: {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }, label: {
                        Circle()
                            .frame(width: 60, height: 60, alignment: .center)
                            .foregroundStyle(Color.primary.opacity(0.1))
                            .overlay {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 20, weight: .medium))
                            }
                    })
                    
                    
                    
                    // 分享视图
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("分享图片")) {
                        Circle()
                            .frame(width: 60, height: 60, alignment: .center)
                            .foregroundStyle(Color.primary.opacity(0.1))
                            .overlay {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20, weight: .medium))
                            }
                    }
                    
                }
                .frame(height: 100, alignment: .bottom)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.primary)
                .padding(.bottom)
            }
            
        }
        .onAppear(perform: {
            renderImage()
        })
        
    }
    
    
    // 渲染视图为图片
    @MainActor func renderImage() {
        if let image = ImageRenderer(content: mainView()).uiImage {
            self.image = image
        }
    }
    
    
    // 视图
    func mainView() -> some View {
        VStack(spacing: 80) {
            Text("happy new year")
                .font(.title)
                .fontWeight(.bold)
            Image(systemName: "fireworks")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }
        .padding(20)
        .padding(.vertical, 20)
        .foregroundStyle(Color.orange)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
        .padding()
    }
}

#Preview {
    RenderView()
}
