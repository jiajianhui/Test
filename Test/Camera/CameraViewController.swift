//
//  CameraViewController.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/28.
//

import UIKit
import AVFoundation

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

        session.startRunning()
    }

    
    // 拍摄界面功能区
    private func setupUI() {
        // 1️⃣ 底部背景容器（毛玻璃）
        let blurEffect = UIBlurEffect(style: .systemMaterialLight)
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.masksToBounds = true
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        
        // 2️⃣ 拍照按钮
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("📸", for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        captureButton.backgroundColor = UIColor.white
        captureButton.tintColor = .black
        captureButton.layer.cornerRadius = 35
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        backgroundView.contentView.addSubview(captureButton) // ✅ 添加到 contentView
        
        // 3️⃣ 返回按钮
        let backButton = UIButton(type: .system)
        backButton.setTitle("←", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backgroundView.contentView.addSubview(backButton) // ✅ 添加到 contentView
        
        // 4️⃣ 图库按钮
        let galleryButton = UIButton(type: .system)
        galleryButton.setTitle("📁", for: .normal)
        galleryButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        galleryButton.tintColor = .black
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.addTarget(self, action: #selector(didTapGallery), for: .touchUpInside)
        backgroundView.contentView.addSubview(galleryButton) // ✅ 添加到 contentView

        // 5️⃣ 约束
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 180),

            captureButton.centerXAnchor.constraint(equalTo: backgroundView.contentView.centerXAnchor),
            captureButton.centerYAnchor.constraint(equalTo: backgroundView.contentView.centerYAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            backButton.leadingAnchor.constraint(equalTo: backgroundView.contentView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: backgroundView.contentView.centerYAnchor),

            galleryButton.trailingAnchor.constraint(equalTo: backgroundView.contentView.trailingAnchor, constant: -20),
            galleryButton.centerYAnchor.constraint(equalTo: backgroundView.contentView.centerYAnchor),
        ])
    }



    // 关闭相机界面
    @objc private func didTapBack() {
        dismiss(animated: true)
    }

    @objc private func didTapGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            delegate?.didCapturePhoto(image)
        }
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

