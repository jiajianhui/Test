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
        
        // 🆕 裁剪到主体边界
        let cropped = cropToSubject(extracted) ?? extracted
        
        // 添加白边
        let withBorder = addWhiteBorder(to: cropped, borderWidth: 10)
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
    
    
    // ===== 裁剪到主体边界 =====
    private func cropToSubject(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        // 找到非透明像素的边界
        let width = cgImage.width
        let height = cgImage.height
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return nil }
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var minX = width, maxX = 0
        var minY = height, maxY = 0
        
        // 扫描找到非透明区域
        for y in 0..<height {
            for x in 0..<width {
                let alpha = buffer[(y * width + x) * 4 + 3]
                if alpha > 10 { // 有内容
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                    minY = min(minY, y)
                    maxY = max(maxY, y)
                }
            }
        }
        
        guard maxX > minX, maxY > minY else { return nil }
        
        // 裁剪
        let cropRect = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        guard let croppedCG = cgImage.cropping(to: cropRect) else { return nil }
        let croppedImage = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
        
        // 🆕 统一缩放到固定尺寸（关键！）
        return resizeToSquare(croppedImage, targetSize: 800)
    }

    // 🆕 缩放到正方形画布（保持主体居中）
    private func resizeToSquare(_ image: UIImage, targetSize: CGFloat) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        // 计算主体尺寸（占画布的80%）
        let contentRatio: CGFloat = 0.8
        let contentSize = targetSize * contentRatio
        
        var drawSize: CGSize
        if aspectRatio > 1 {
            // 横向图
            drawSize = CGSize(width: contentSize, height: contentSize / aspectRatio)
        } else {
            // 纵向图
            drawSize = CGSize(width: contentSize * aspectRatio, height: contentSize)
        }
        
        // 计算居中位置
        let x = (targetSize - drawSize.width) / 2
        let y = (targetSize - drawSize.height) / 2
        
        // 使用高质量渲染
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0 // 🎯 3x 分辨率（清晰）
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetSize, height: targetSize), format: format)
        
        return renderer.image { context in
            // 高质量插值
            context.cgContext.interpolationQuality = .high
            
            // 透明背景
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: targetSize, height: targetSize)))
            
            // 绘制图片
            image.draw(in: CGRect(x: x, y: y, width: drawSize.width, height: drawSize.height))
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
    
    
    // ===== 添加白色描边（固定像素宽度） =====
    private func addWhiteBorder(to image: UIImage, borderWidth: CGFloat) -> UIImage {
        let scale: CGFloat = 3.0 // 匹配上面的scale
        let size = image.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            let ctx = context.cgContext
            
            // 高质量渲染
            ctx.interpolationQuality = .high
            ctx.setShouldAntialias(true)
            
            let rect = CGRect(origin: .zero, size: size)
            
            // 1. 绘制白色描边层
            let offset = borderWidth
            let directions: [(CGFloat, CGFloat)] = [
                (-offset, -offset), (0, -offset), (offset, -offset),
                (-offset, 0),                      (offset, 0),
                (-offset, offset),  (0, offset),  (offset, offset)
            ]
            
            for (dx, dy) in directions {
                ctx.saveGState()
                ctx.translateBy(x: dx, y: dy)
                
                // 绘制图片
                image.draw(in: rect)
                
                // 用白色填充
                ctx.setBlendMode(.sourceIn)
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fill(rect)
                ctx.setBlendMode(.normal)
                
                ctx.restoreGState()
            }
            
            // 2. 绘制原图
            image.draw(in: rect)
        }
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
