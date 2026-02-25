import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    let onDismiss: (() -> Void)?

    init(onCapture: @escaping (UIImage) -> Void, onDismiss: (() -> Void)? = nil) {
        self.onCapture = onCapture
        self.onDismiss = onDismiss
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onCapture = onCapture
        controller.onDismiss = onDismiss
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

@MainActor
class CameraViewController: UIViewController {
    var onCapture: ((UIImage) -> Void)?
    var onDismiss: (() -> Void)?

    nonisolated(unsafe) private let captureSession = AVCaptureSession()
    nonisolated(unsafe) private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                Task.detached {
                    self.captureSession.startRunning()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                Task.detached {
                    self.captureSession.stopRunning()
                }
            }
        }
    }

    private func setupCamera() {
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            print("Failed to get camera device")
            return
        }

        // Configure camera for high quality
        do {
            try camera.lockForConfiguration()
            // Camera is configured for best quality by default in iOS 18+
            camera.unlockForConfiguration()
        } catch {
            print("Failed to configure camera: \(error)")
        }

        // Add input
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Failed to add camera input: \(error)")
            return
        }

        // Add output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        // Setup preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    private func setupUI() {
        view.addSubview(captureButton)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        // High quality is enabled by default in iOS 18+
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func close() {
        onDismiss?()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Failed to get image data")
            return
        }

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.onCapture?(image)
            // Don't dismiss here - let the parent view handle it via callback
        }
    }
}
