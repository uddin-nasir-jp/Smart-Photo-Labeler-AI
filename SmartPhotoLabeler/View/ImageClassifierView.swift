//
//  ImageClassifierView.swift
//  SmartPhotoLabeler

import SwiftUI

@available(iOS 17.0, *)
struct ImageClassifierView: View {
    @State private var selectedImage: Image? = nil
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var uiImage: UIImage? = nil
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary

    @State var classifier = ImageClassifier()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let selectedImage = selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 5)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 300, height: 300)
                            .overlay(Text("No image selected"))
                    }

                    Text(classifier.classificationLabel)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()

                    if classifier.isClassifying {
                        ProgressView("Classifying...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }

                    HStack(spacing: 20) {
                        Button("Pick Photo") {
                            pickerSource = .photoLibrary
                            showImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Camera") {
                            pickerSource = .camera
                            showCamera = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    }

                    Button("Classify") {
                        Task {
                            if let img = selectedImage {
                                await classifier.classify(image: img)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectedImage == nil || classifier.isClassifying)

                    if !classifier.history.isEmpty {
                        Divider().padding(.vertical)
                        Text("Classification History")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(classifier.history, id: \ .self) { item in
                            Text("• \(item)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 2)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Smart Photo Labeler")
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(image: $selectedImage)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $selectedImage)
        }
    }
}
