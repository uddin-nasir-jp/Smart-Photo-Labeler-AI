//
//  ImageClassifier.swift
//  SmartPhotoLabeler

import CoreML
import Vision
import SwiftUI
import Observation

@Observable
class ImageClassifier {
    var classificationLabel: String = "Awaiting Image..."
    var isClassifying: Bool = false
    var history: [String] = []

    private var model: VNCoreMLModel?

    init() {
        Task {
            await loadModel()
        }
    }

    private func loadModel() async {
        do {
            let config = MLModelConfiguration()
            let fastViTModel = try FastViTMA36F16(configuration: MLModelConfiguration())
            self.model = try VNCoreMLModel(for: fastViTModel.model)
        } catch {
            print("Failed to load model: \(error.localizedDescription)")
        }
    }

    func classify(image: Image) async {
        guard let model = model else {
            classificationLabel = "Model not loaded."
            return
        }

        guard let uiImage = await image.asUIImage(),
              let ciImage = CIImage(image: uiImage) else {
            classificationLabel = "Invalid image."
            return
        }

        isClassifying = true
        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                Task { @MainActor in
                    let resultText = "\(topResult.identifier) (\(Int(topResult.confidence * 100))% confidence)"
                    self?.classificationLabel = resultText
                    self?.history.insert(resultText, at: 0)
                    self?.isClassifying = false
                }
            } else {
                Task { @MainActor in
                    self?.classificationLabel = "Unable to classify image."
                    self?.isClassifying = false
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            await MainActor.run {
                self.classificationLabel = "Failed to perform classification."
                self.isClassifying = false
            }
        }
    }
}

extension View {
    func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
