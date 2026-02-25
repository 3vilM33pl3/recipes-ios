import SwiftUI

struct ZoomableImageView: View {
    let url: URL?
    @State private var showFullScreen = false

    var body: some View {
        Button {
            showFullScreen = true
        } label: {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .empty:
                    ProgressView()
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenZoomableImage(url: url, isPresented: $showFullScreen)
        }
    }
}

struct FullScreenZoomableImage: View {
    let url: URL?
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    // Limit zoom
                                    if scale < 1 {
                                        withAnimation {
                                            scale = 1
                                            lastScale = 1
                                        }
                                    } else if scale > 5 {
                                        withAnimation {
                                            scale = 5
                                            lastScale = 5
                                        }
                                    }
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1 {
                                    // Reset zoom
                                    scale = 1
                                    lastScale = 1
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    // Zoom in 2x
                                    scale = 2
                                    lastScale = 2
                                }
                            }
                        }

                case .empty:
                    ProgressView()
                        .tint(.white)

                case .failure:
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                        Text("Failed to load image")
                    }
                    .foregroundStyle(.white)

                @unknown default:
                    EmptyView()
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }

            // Instructions overlay (fades after 3 seconds)
            InstructionsOverlay()
        }
        .statusBar(hidden: true)
        .onAppear {
            // Reset state when view appears
            scale = 1
            lastScale = 1
            offset = .zero
            lastOffset = .zero
        }
    }
}

struct InstructionsOverlay: View {
    @State private var opacity: Double = 1.0

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Text("Pinch to zoom • Drag to pan")
                    .font(.caption)
                Text("Double tap to zoom in/out")
                    .font(.caption)
            }
            .foregroundStyle(.white)
            .padding()
            .background(.black.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.bottom, 40)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(2.5)) {
                opacity = 0
            }
        }
    }
}

#Preview {
    ZoomableImageView(url: URL(string: "https://picsum.photos/800/1200"))
}
