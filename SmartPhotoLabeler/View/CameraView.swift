//
//  CameraView.swift
//  SmartPhotoLabeler

import SwiftUI

@available(iOS 17.0, *)
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: Image?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let cameraView: CameraView

        init(_ parent: CameraView) {
            self.cameraView = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            if let uiImage = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    self.cameraView.image = Image(uiImage: uiImage)
                }
            }
        }
    }
}
