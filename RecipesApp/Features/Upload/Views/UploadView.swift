import SwiftUI
import PhotosUI
import SwiftData
import UIKit

struct UploadView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: UploadViewModel?
    @State private var showCamera = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let viewModel = viewModel {
                    if let previewImage = viewModel.previewImage {
                        // Preview section
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: Configuration.cornerRadius))

                        if viewModel.isUploading {
                            ProgressView("Processing recipe...")
                                .progressViewStyle(.circular)
                        } else {
                            Button {
                                Task {
                                    await viewModel.uploadImage()
                                }
                            } label: {
                                Label("Upload Recipe", systemImage: "arrow.up.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)

                            Button("Choose Different Photo") {
                                viewModel.reset()
                            }
                            .buttonStyle(.bordered)
                        }

                        if let error = viewModel.error {
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                    } else {
                        // Selection section
                        ContentUnavailableView(
                            "No Photo Selected",
                            systemImage: "photo.on.rectangle",
                            description: Text("Take a photo or choose from your library")
                        )

                        VStack(spacing: 16) {
                            Button {
                                showCamera = true
                            } label: {
                                Label("Take Photo", systemImage: "camera.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)

                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Label("Choose from Library", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .padding()
            .navigationTitle("Upload Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(
                    onCapture: { image in
                        viewModel?.setImage(image)
                        showCamera = false
                    },
                    onDismiss: {
                        showCamera = false
                    }
                )
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel?.setImage(image)
                    }
                }
            }
            .onChange(of: viewModel?.uploadSuccess ?? false) { _, success in
                if success {
                    dismiss()
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = UploadViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

#Preview {
    UploadView()
        .modelContainer(PersistenceController.preview.container)
}
