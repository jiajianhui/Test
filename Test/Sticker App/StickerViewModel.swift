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

@MainActor
class StickerViewModel: ObservableObject {
    // ===== 状态管理 =====
    @Published var currentState: ProcessingState = .initial
    
    // ===== 数据 =====
    @Published var capturedImage: UIImage?
    @Published var extractedSubject: UIImage?
    
    // ===== UI 控制 =====
    @Published var showPhotoPicker = false
    @Published var showSaveAlert = false
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            if selectedPhoto != nil {
                loadPhoto()
            }
        }
    }
    
    // ===== 流程1: 加载照片 =====
    private func loadPhoto() {
        guard let item = selectedPhoto else { return }
        
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                
                capturedImage = image
                
                // 【动画阶段1】切换到识别状态
                withAnimation(.easeIn(duration: 0.3)) {
                    currentState = .analyzing
                }
                
                // 开始识别（模拟延迟以展示动画）
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
                
                // 执行实际识别
                await performExtraction(image)
                
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
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: newSize))
        
        image.draw(in: CGRect(
            x: borderWidth,
            y: borderWidth,
            width: image.size.width,
            height: image.size.height
        ))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
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
