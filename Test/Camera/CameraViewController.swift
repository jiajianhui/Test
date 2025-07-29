//
//  CameraViewController.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/28.
//

import UIKit
import AVFoundation
import SwiftUI

protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(_ image: UIImage)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: CameraViewControllerDelegate?

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // 设置默认背景为黑色
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }

        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }

    }

    
    // 拍摄界面功能区
    private func setupUI() {
        // 直接创建 SwiftUI 的控制按钮视图
        let controlsView = CameraControlsView(
            onCapture: { [weak self] in self?.capturePhoto() },
            onBack: { [weak self] in self?.didTapBack() },
            onGallery: { [weak self] image in
                self?.delegate?.didCapturePhoto(image)
            },
            btnBG: .white
        )

        let hostingController = UIHostingController(rootView: controlsView)
        
        // 默认 UIKit 的 UIView 背景是白色，需要手动清除
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            hostingController.view.heightAnchor.constraint(equalToConstant: 180) // 设置高度
        ])
        hostingController.didMove(toParent: self)
    }




    // 关闭相机界面
    @objc private func didTapBack() {
        dismiss(animated: true)
    }



    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    // 📸 获取拍照图像
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        delegate?.didCapturePhoto(image)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }
}

