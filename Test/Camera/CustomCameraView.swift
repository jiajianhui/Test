//
//  CustomCameraView.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/28.
//

import SwiftUI
import AVFoundation

struct CustomCameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CustomCameraView
        init(_ parent: CustomCameraView) {
            self.parent = parent
        }

        func didCapturePhoto(_ image: UIImage) {
            parent.image = image
            parent.dismiss()
        }
    }
}
