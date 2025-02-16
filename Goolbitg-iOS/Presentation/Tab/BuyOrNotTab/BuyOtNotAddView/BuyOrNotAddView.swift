//
//  BuyOrNotAddView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import PopupView

struct ImageIdentifier: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct BuyOrNotAddView: View {
    
    @Perception.Bindable var store: StoreOf<BuyOrNotAddViewFeature>
    
    @State var showImagePicker = false
    @State var imageItem: PhotosPickerItem?
    @State var image: ImageIdentifier? = nil
    @State var viewImage: UIImage? = nil
    
    @Environment(\.imageCompressionManager) var imageCompressionManager
    
    var body: some View {
        WithPerceptionTracking {
            content
                .popup(
                    item: $store.alertComponents.sending(\.bindingAlertComponents)) { item in
                        GBAlertView(
                            model: item) {}
                        okTouch: {
                            store.send(.bindingAlertComponents(nil))
                        }
                    } customize: {
                        $0
                            .animation(.easeInOut)
                            .type(.default)
                            .appearFrom(.centerScale)
                            .closeOnTap(false)
                            .closeOnTapOutside(false)
                            .backgroundView {
                                Color.black.opacity(0.5)
                            }
                    }
                    .onTapGesture {
                        endTextEditing()
                    }
                    .photosPicker(
                        isPresented: $showImagePicker,
                        selection: $imageItem,
                        matching: .images
                    )
                    .onChange(of: imageItem) { newValue in
                        guard let newValue else { return }
                        Task {
                            let imageDataResult = await imageCompressionManager.checkImageMimeType(
                                item: newValue
                            )
                            
                            try? await Task.sleep(for: .milliseconds(100))
                            
                            switch imageDataResult {
                            case let .success(image):
                                await MainActor.run {
                                    self.image = ImageIdentifier(image: image)
                                }
                            case let .failure(error):
                                let alertComponents = GBAlertViewComponents(
                                    title: "이미지 파일 형식 오류",
                                    message: "지원되지 않는 이미지 파일 형식입니다.",
                                    cancelTitle: nil,
                                    okTitle: "확인",
                                    alertStyle: .warningWithWarning
                                )
                                self.imageItem = nil
                                self.imageItem = nil
                                
                                store.send(.bindingAlertComponents(alertComponents))
                            }
                        }
                    }
                    .fullScreenCover(item: $image) { imageModel in
                        ImageCropView(
                            image: imageModel.image
                        ) { image in
                            self.image = nil
                            viewImage = image
                            if let image {
                                Task {
                                    let imageData = await imageCompressionManager.compressImageAsync(
                                        image,
                                        zipRate: 9.9
                                    )
                                    
                                    store.send(.viewEvent(.imageResults(imageData)))
                                }
                            } else {
                                store.send(.viewEvent(.imageResults(nil)))
                            }
                        }
                    }
            
        }
    }
}

extension BuyOrNotAddView {
    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, SpacingHelper.md.pixel)
                .padding(.top, 4)
                .padding(.bottom, 16)
            ScrollView {
                imageAddSectionView
                    .padding(.horizontal, SpacingHelper.md.pixel + 8)
            }
        }
        .background(GBColor.background1.asColor)
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text(TextHelper.buyOrNotAddTitle)
                .font(FontHelper.h3.font)
                .foregroundStyle(GBColor.white.asColor)
            
            HStack {
                ImageHelper.back.asImage
                    .resizable()
                    .frame(width: 32, height: 32)
                    .asButton {
                        store.send(.viewEvent(.dismiss))
                    }
                Spacer()
            }
        }
    }
}

extension BuyOrNotAddView {
    private var imageAddSectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(text: "사진첨부", required: true)
            
            HStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let viewImage {
                            Image(uiImage: viewImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(GBColor.grey500.asColor)
                                }
                                .asButton {
                                    showImagePicker.toggle()
                                }
                        } else {
                            VStack(spacing: 0) {
                                Spacer()
                                Image(systemName: "photo")
                                    .resizable()
                                    .foregroundStyle(GBColor.grey300.asColor)
                                    .frame(width: 24, height: 20)
                                    .padding(.bottom, SpacingHelper.sm.pixel)
                                
                                Text("사진 추가")
                                    .font(FontHelper.body3.font)
                                    .foregroundStyle(GBColor.grey300.asColor)
                                    .padding(.bottom, SpacingHelper.xs.pixel)
                                
                                Text("(png, jpg, jpeg)")
                                    .font(FontHelper.body5.font)
                                    .foregroundStyle(GBColor.grey300.asColor)
                                Spacer()
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundStyle(GBColor.grey500.asColor)
                            }
                            .asButton {
                                showImagePicker.toggle()
                            }
                        }
                    }
                    
                    if viewImage != nil {
                        Circle()
                            .foregroundStyle(GBColor.grey400.asColor)
                            .overlay {
                                Image(.xSmall)
                                    .resizable()
                                    .frame(width: 8.39, height: 8.39)
                            }
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(GBColor.grey300.asColor)
                            }
                            .frame(width: 20, height: 20)
                            .offset(x: 5, y: -5)
                            .asButton {
                                self.viewImage = nil
                                self.imageItem = nil
                                store.send(.viewEvent(.imageResults(nil)))
                                
                            }
                    }
                }
                Spacer()
            }
        }
    }
}

extension BuyOrNotAddView {
    private func sectionTopTextView(text: String, required: Bool) -> some View {
        HStack(spacing: 3) {
            Text(text)
                .font(FontHelper.caption1.font)
                .foregroundStyle(GBColor.white.asColor)
            if required {
                Text("*")
                    .font(FontHelper.caption1.font)
                    .foregroundStyle(GBColor.error.asColor)
            }
            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    BuyOrNotAddView(store: Store(initialState: BuyOrNotAddViewFeature.State(), reducer: {
        BuyOrNotAddViewFeature()
    }))
}
#endif
