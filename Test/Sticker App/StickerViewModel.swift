//
//  StickerViewModel.swift
//  Test
//
//  Created by 贾建辉 on 2025/10/5.
//

import SwiftUI
import PhotosUI
import Vision
import CoreImage

// MARK: - 处理状态枚举（状态机）
enum ProcessingState {
    case initial      // 初始状态
    case analyzing    // 识别中（全屏显示原图）
    case extracting   // 主体跳出动画
    case completed    // 完成（显示卡片）
}


// MARK: - vm

@MainActor
class StickerViewModel: ObservableObject {
    // ===== 状态管理 =====
    @Published var currentState: ProcessingState = .initial
    
    // ===== 数据，选择的图片、识别的主体图片（带白色描边） =====
    @Published var capturedImage: UIImage?
    @Published var extractedSubject: UIImage?
    @Published var dominantColor: Color = .blue

    
    // ===== UI 弹窗控制 =====
    @Published var showPhotoPicker = false
    @Published var showSaveAlert = false
    
    // ===== 计算属性，当选择一个图片后，自动调用函数 loadPhoto =====
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            if selectedPhoto != nil {
                loadPhoto()
            }
        }
    }
    
    // ===== 流程1: 加载照片 =====
    private func loadPhoto() {
        
        // 用户没有选择图片，直接返回
        guard let item = selectedPhoto else { return }
        
        
        // 异步方式加载图片
        Task {
            do {
                
                // 获取图片的二进制数据；
                guard let data = try await item.loadTransferable(type: Data.self),
                      // 把二进制数据转换成图片
                      let image = UIImage(data: data)
                else { return }
                
                // 修正图片方向
                let fixedImage = image.fixedOrientation()
                capturedImage = fixedImage
                
                // 【动画阶段1】切换到识别状态
                withAnimation(.easeIn(duration: 0.3)) {
                    currentState = .analyzing
                }
                
                // 开始识别（模拟延迟以展示动画）
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
                
                // 执行实际识别
                await performExtraction(fixedImage)
                
            } catch {
                print("❌ 错误: \(error)")
            }
        }
    }
    
    // ===== 流程2: 执行提取 =====
    private func performExtraction(_ image: UIImage) async {
        // Vision 提取主体
        guard let extracted = await extractSubject(from: image) else {
            reset()
            return
        }
        
        // 添加白边
        let withBorder = addWhiteBorder(to: extracted, borderWidth: 10)
        extractedSubject = withBorder
        
        // 【动画阶段2】切换到跳出动画
        withAnimation(.easeOut(duration: 0.3)) {
            currentState = .extracting
        }
        
        // 🎨 提取主色
        dominantColor = extractDominantColor(from: image)

        
        // 等待跳出动画完成
        try? await Task.sleep(nanoseconds: 1_600_000_000) // 1.6秒
        
        // 【动画阶段3】切换到完成状态
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentState = .completed
        }
    }
    
    // ===== Vision AI 提取主体 =====
    private func extractSubject(from image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        do {
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage)
            try handler.perform([request])
            
            guard let result = request.results?.first else { return nil }
            
            let mask = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )
            
            return applyMask(mask, to: image)
            
        } catch {
            print("❌ Vision 错误: \(error)")
            return nil
        }
    }
    
    // ===== 应用蒙版 =====
    private func applyMask(_ mask: CVPixelBuffer, to image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let maskCIImage = CIImage(cvPixelBuffer: mask)
        
        let scaleX = ciImage.extent.width / maskCIImage.extent.width
        let scaleY = ciImage.extent.height / maskCIImage.extent.height
        let scaledMask = maskCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let filter = CIFilter(name: "CIBlendWithMask") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(scaledMask, forKey: kCIInputMaskImageKey)
        filter.setValue(CIImage.empty(), forKey: kCIInputBackgroundImageKey)
        
        guard let output = filter.outputImage else { return nil }
        
        let context = CIContext()
        guard let cgOutput = context.createCGImage(output, from: output.extent) else { return nil }
        
        return UIImage(cgImage: cgOutput)
    }
    
    // ===== 添加白边 =====
    private func addWhiteBorder(to image: UIImage, borderWidth: CGFloat) -> UIImage {
        let newSize = CGSize(
            width: image.size.width + borderWidth * 2,
            height: image.size.height + borderWidth * 2
        )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return image }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: newSize))
        
        image.draw(in: CGRect(
            x: borderWidth,
            y: borderWidth,
            width: image.size.width,
            height: image.size.height
        ))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    
    // 提取主色
    private func extractDominantColor(from image: UIImage, brightnessFactor: CGFloat = 1.6) -> Color {
        guard let cgImage = image.cgImage else { return .gray }
        
        let size = CGSize(width: 1, height: 1) // 缩小为 1x1 图像取平均色
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return .gray }
        
        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        guard let pixelData = context.data else {
            UIGraphicsEndImageContext()
            return .gray
        }
        
        let data = pixelData.bindMemory(to: UInt8.self, capacity: 4)
        var r = CGFloat(data[2]) / 255.0
        var g = CGFloat(data[1]) / 255.0
        var b = CGFloat(data[0]) / 255.0
        
        UIGraphicsEndImageContext()
        
        // 提升亮度
        r = min(r * brightnessFactor, 1.0)
        g = min(g * brightnessFactor, 1.0)
        b = min(b * brightnessFactor, 1.0)
        
        return Color(red: r, green: g, blue: b)
    }


    
    // ===== 保存 =====
    func saveSticker() {
        guard let image = extractedSubject else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveAlert = true
    }
    
    // ===== 重置 =====
    func reset() {
        withAnimation(.easeOut(duration: 0.3)) {
            currentState = .initial
        }
        capturedImage = nil
        extractedSubject = nil
        selectedPhoto = nil
    }
}


extension UIImage {
    func fixedOrientation() -> UIImage {
        // 如果方向已经正确，直接返回
        if imageOrientation == .up {
            return self
        }
        
        // 重新绘制图片
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
