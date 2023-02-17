import SwiftUI
import CoreML
import Vision
import PhotosUI


struct SnapGalleryView: View {
  @State private var selectedImages: [UIImage] = []
  @State var showImagePicker = false

  var body: some View {
    VStack {
      if !selectedImages.isEmpty {
        ScrollView(.horizontal) {
          HStack {
            ForEach(selectedImages, id: \.self) { image in
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width: 300.0, height: 300.0)
              
            }
          }
        }
      } else {
        Text("No images selected")
      }
      Button("Select Images") {
        showImagePicker = true
      }
      .padding(.all)
      .buttonStyle(.borderedProminent)

      Button("Classify Image") {
        classifyImage(selectedImages)
      }
      .padding(.all)
      .buttonStyle(.borderedProminent)
    }
    .sheet(isPresented: $showImagePicker) {
      ImagePicker(selectedImages: $selectedImages)
    }
  }

  private func classifyImage(_ images: [UIImage]) {
    images.forEach { image in
      guard let ciImage = CIImage(image: image) else { return }

      do {
        let model = try VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model)
        let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
          guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else { return }
          print(topResult)
        })

        let handler = VNImageRequestHandler(ciImage: ciImage)
        try handler.perform([request])
      } catch {
        print(error)
      }
    }
  }
}

struct SnapGalleryView_Previews: PreviewProvider {
  static var previews: some View {
    SnapGalleryView()
  }
}


struct ImagePicker: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode
  @Binding var selectedImages: [UIImage]

  class Coordinator: NSObject, PHPickerViewControllerDelegate {
    var parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      for result in results {
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
          result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
              DispatchQueue.main.async {
                self.parent.selectedImages.append(image)
              }
            }
          }
        }
      }
      parent.presentationMode.wrappedValue.dismiss()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
    var configuration = PHPickerConfiguration()
    configuration.filter = .images
    configuration.selectionLimit = 0 // Set to 0 to allow unlimited selection
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    // Update UI if needed
  }
}

