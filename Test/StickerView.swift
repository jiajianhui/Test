//
//  StickerView.swift
//  Test
//
//  Created by 贾建辉 on 2025/9/30.
//

import SwiftUI
import PhotosUI
import Vision
import CoreImage

struct StickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var stickerImage: UIImage?

    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("选择照片")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            if let stickerImage {
                Image(uiImage: stickerImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .padding()
        .onChange(of: selectedItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    stickerImage = await extractSubject(from: image)
                }
            }
        }
    }

    func extractSubject(from image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNGenerateForegroundInstanceMaskRequest()
        guard VNGenerateForegroundInstanceMaskRequest.supportedRevisions.count > 0 else { return nil }

        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])

        guard let result = request.results?.first,
              let mask = try? result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
        else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let maskCI = CIImage(cvPixelBuffer: mask)
        let scaleX = ciImage.extent.width / maskCI.extent.width
        let scaleY = ciImage.extent.height / maskCI.extent.height
        let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let blend = CIFilter(name: "CIBlendWithMask") else { return nil }
        blend.setValue(ciImage, forKey: kCIInputImageKey)
        blend.setValue(scaledMask, forKey: kCIInputMaskImageKey)
        blend.setValue(CIImage.empty(), forKey: kCIInputBackgroundImageKey)

        guard let output = blend.outputImage,
              let cgOutput = CIContext().createCGImage(output, from: output.extent)
        else { return nil }

        return UIImage(cgImage: cgOutput)
    }
}

#Preview {
    StickerView()
}

