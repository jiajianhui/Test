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
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1.0秒
                
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
        let withBorder = addWhiteBorder(to: cropped, borderWidth: 16)
        extractedSubject = withBorder
        
        // 【动画阶段2】切换到跳出动画
        withAnimation(.easeOut(duration: 0.3)) {
            currentState = .extracting
        }
        
        // 🎨 提取主色
        dominantColor = extractRefinedColor(from: cropped)

        
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

        let scaleFactor: CGFloat = 0.2 // 降低分辨率到20%
        let width = Int(CGFloat(cgImage.width) * scaleFactor)
        let height = Int(CGFloat(cgImage.height) * scaleFactor)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.interpolationQuality = .low
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else { return nil }
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)

        var minX = width, maxX = 0
        var minY = height, maxY = 0

        for y in 0..<height {
            for x in 0..<width {
                let alpha = buffer[(y * width + x) * 4 + 3]
                if alpha > 10 {
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                    minY = min(minY, y)
                    maxY = max(maxY, y)
                }
            }
        }

        guard maxX > minX, maxY > minY else { return nil }

        // 转换回原始坐标
        let factorX = CGFloat(cgImage.width) / CGFloat(width)
        let factorY = CGFloat(cgImage.height) / CGFloat(height)
        let cropRect = CGRect(
            x: CGFloat(minX) * factorX,
            y: CGFloat(minY) * factorY,
            width: CGFloat(maxX - minX + 1) * factorX,
            height: CGFloat(maxY - minY + 1) * factorY
        )

        guard let croppedCG = cgImage.cropping(to: cropRect) else { return nil }
        let croppedImage = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)

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
        format.scale = 2.0 // 🎯 3x 分辨率（清晰）
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetSize, height: targetSize), format: format)
        
        return renderer.image { context in
            // 高质量插值
            context.cgContext.interpolationQuality = .medium
            
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


/**
 从图片中提取平均色，并调整饱和度和亮度，生成“高级”背景色。

 @param image 要处理的 UIImage。
 @param saturationFactor 饱和度乘数 (0.0 - 1.0)。例如，0.3 会使颜色更“灰”。
 @param brightnessFactor 亮度乘数 (0.0 - 1.0)。例如，0.9 会使颜色更“亮”。
 @return 调整后的 SwiftUI Color。
 */
private func extractRefinedColor(from image: UIImage,
                                 saturation: CGFloat = 0.3,
                                 brightness: CGFloat = 0.95) -> Color {
    
    // --- 第 1 步：提取平均色 (使用 UIGraphicsImageRenderer 更简洁) ---
    let size = CGSize(width: 1, height: 1)
    let renderer = UIGraphicsImageRenderer(size: size)
    
    let uiColor = renderer.image { context in
        image.draw(in: CGRect(origin: .zero, size: size))
    }.averageColor // 使用 UIImage 的 averageColor 扩展（见下方）
    
    guard let baseColor = uiColor else { return .gray }

    // --- 第 2 步：转换为 HSB 并调整 ---
    var hue: CGFloat = 0
    var currentSaturation: CGFloat = 0
    var currentBrightness: CGFloat = 0
    var alpha: CGFloat = 0

    // 将 UIColor 转换为 HSB 空间
    baseColor.getHue(&hue, saturation: &currentSaturation, brightness: &currentBrightness, alpha: &alpha)

    // --- 第 3 步：应用自定义饱和度和亮度 ---
    
    // 强制使用自定义饱和度和亮度。
    // 例如，您的蓝色瓶子颜色 (低饱和度、高亮度) 变为：
    // 新的饱和度 = 0.3 (变灰)
    // 新的亮度   = 0.9 (变亮)
    let newSaturation = min(currentSaturation * saturation, 1.0)
    let newBrightness = min(brightness, 1.0) // 直接使用您想要的高亮度值

    // --- 第 4 步：创建新的 UIColor ---
    let finalUIColor = UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: 1.0)

    // --- 第 5 步：返回 SwiftUI Color ---
    return Color(finalUIColor)
}


// 辅助扩展：获取 UIImage 的平均色（基于 Core Image 或 UIGraphics）
// 为了代码完整性，这里使用我第一个回答中介绍的 Core Image 方法
extension UIImage {
    var averageColor: UIColor? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(cgRect: ciImage.extent)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        let r = CGFloat(bitmap[0]) / 255.0
        let g = CGFloat(bitmap[1]) / 255.0
        let b = CGFloat(bitmap[2]) / 255.0
        let a = CGFloat(bitmap[3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
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
