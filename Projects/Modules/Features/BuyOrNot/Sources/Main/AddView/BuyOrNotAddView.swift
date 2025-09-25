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
import Utils
import Data
import FeatureCommon

struct ImageIdentifier: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct BuyOrNotAddView: View {
    
    @Perception.Bindable var store: StoreOf<BuyOrNotAddViewFeature>
    @Dependency(\.cameraManager) var cameraManager
    
    @State private var precentImageMode: Bool = false
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    @State private var imageItem: PhotosPickerItem?
    @State private var image: ImageIdentifier? = nil
    @State private var viewImage: UIImage? = nil
    @State private var keyboardHeight: CGFloat = 0
    @State private var focusedField: Int? = nil
    
    @Environment(\.imageCompressionManager) var imageCompressionManager
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    var body: some View {
        WithPerceptionTracking {
            content
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
                .popup(
                    item: $store.alertComponents.sending(\.bindingAlertComponents)) { item in
                        GBAlertView(
                            model: item)
                        {
                            store.send(.bindingAlertComponents(nil))
                        }
                        okTouch: {
                            store.send(.viewEvent(.alertOkTap(item)))
                        }
                    } customize: {
                        $0
                            .animation(.easeInOut)
                            .type(.default)
                            .displayMode(.sheet)
                            .appearFrom(.centerScale)
                            .closeOnTap(false)
                            .closeOnTapOutside(false)
                            .backgroundColor(Color.black.opacity(0.5))
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
                            case .failure(_):
                                let alertComponents = GBAlertViewComponents(
                                    title: "이미지 파일 형식 오류",
                                    message: "지원되지 않는 이미지 파일 형식입니다.",
                                    cancelTitle: nil,
                                    okTitle: "확인",
                                    alertStyle: .warningWithWarning
                                )
                                self.imageItem = nil
                                self.image = nil
                                
                                store.send(.bindingAlertComponents(alertComponents))
                            }
                        }
                    }
                    .onChange(of: viewImage) { image in
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
                    .fullScreenCover(isPresented: $showCameraPicker) {
                        CameraView(image: $viewImage)
                    }
                    .fullScreenCover(item: $image) { imageModel in
                        ImageCropView(
                            image: imageModel.image
                        ) { image in
                            self.image = nil
                            viewImage = image
                        }
                        .navigationBarBackButtonHidden()
                    }
                    .overlay {
                        Group {
                            if store.loading {
                                GBLoadingView()
                            }
                        }
                    }
                    .confirmationDialog("종류 선택", isPresented: $precentImageMode) {
                        Text("앨범")
                            .asButton {
                                showImagePicker = true
                            }
                        Text("카메라")
                            .asButton {
                                if cameraManager.isAuthorized() {
                                    showCameraPicker = true
                                }
                                else {
                                    let alertComponents = GBAlertViewComponents(
                                        title: "카메라 권한을 허용하세요",
                                        message: "카메라 권환을 허용하여야 카메라를 통해 이미지를 업로드 할 수 있습니다.",
                                        cancelTitle: nil,
                                        okTitle: "확인",
                                        alertStyle: .warningWithWarning
                                    )
                                    self.imageItem = nil
                                    self.image = nil
                                    
                                    store.send(.bindingAlertComponents(alertComponents))
                                }
                            }
                    }
            
        }
    }
}

extension BuyOrNotAddView {
    private var content: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, SpacingHelper.md.pixel)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: SpacingHelper.lg.pixel) {
                            imageAddSectionView
                            
                            itemNameSectionView
                                .id(1)
                            priceSectionView
                                .id(2)
                            whyBuySectionView
                                .id(3)
                            whyNotBuySectionView
                                .padding(.bottom, safeAreaInsets.bottom)
                                .id(4)
                        }
                        .padding(.horizontal, SpacingHelper.md.pixel + 8)
                        
                    }
                    .padding(.bottom, keyboardHeight - safeAreaInsets.bottom)
                    .onChange(of: keyboardHeight) { newValue in
                        scrollToFocusedField(proxy)
                    }
                    .onChange(of: focusedField) { newValue in
                        scrollToFocusedField(proxy)
                    }
                }
            }
            if store.currentOkButtonState {
                GBButtonV2(title: store.stateMode.endTitle) {
                    store.send(.viewEvent(.okButtonTapped))
                }
                .padding(.horizontal, 10)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .ignoreAreaBackgroundColor(GBColor.background1.asColor)
        .subscribeKeyboardHeight { height in
            keyboardHeight = height
        }
    }
    
    private var navigationBar: some View {
        ZStack(alignment: .center) {
            Text(store.stateMode.navigationTitle)
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
            sectionTopTextView(text: TextHelper.buyOrNotAddPhotoTitle, required: true)
            
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
                                    precentImageMode.toggle()
                                }
                        }
                        else if let url = store.ifImageURL {
                            DownImageView(
                                url: url,
                                option: .mid,
                                fallBackImg: ImageHelper.appLogo.image
                            )
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(GBColor.grey500.asColor)
                            }
                            .asButton {
                                precentImageMode.toggle()
                            }
                        }
                        else {
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
                                precentImageMode.toggle()
                            }
                        }
                    }
                    
                    if viewImage != nil {
                        Circle()
                            .foregroundStyle(GBColor.grey400.asColor)
                            .overlay {
                                ImageHelper.xSmall.asImage
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
    private var itemNameSectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(text: TextHelper.buyOrNotItemNameTitle, required: true)
            
            DisablePasteTextField(
                text: $store.itemText.sending(\.bindingItemText),
                placeholder: TextHelper.buyOrNotItemNamePlaceHolder,
                placeholderColor: GBColor.grey500.asColor,
                edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                keyboardType: .default) {
                    
                }
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
        }
        .onTapGesture {
            self.focusedField = 1
        }
    }
    
    private var priceSectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(text: TextHelper.buyOrNotPriceTitle, required: true)
            
            ZStack(alignment: .leading) {
                DisablePasteTextField(
                    text: $store.priceText.sending(\.bindingPriceText),
                    placeholder: TextHelper.buyOrNotPricePlaceHolder,
                    placeholderColor: GBColor.grey500.asColor,
                    edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                    keyboardType: .numberPad,
                    ifLeadingEdge: 20,
                    items: [.keyboardDown]
                ) {
                    
                }
                .background(GBColor.grey600.asColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
                )
                
                if !store.priceText.isEmpty {
                    Text("₩")
                        .foregroundStyle(GBColor.white.asColor)
                        .padding(.leading, 20)
                }
            }
        }
        .onTapGesture {
            self.focusedField = 2
        }
    }
    
    private var whyBuySectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(text: TextHelper.buyOrNotWhyBuyTitle, required: true)
            
            DisablePasteTextField(
                text: $store.buyText.sending(\.bindingBuyText),
                placeholder: TextHelper.buyOrNotWhyBuyPlaceHolder,
                placeholderColor: GBColor.grey500.asColor,
                edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                keyboardType: .default
            ) {
                
            }
            .background(GBColor.grey600.asColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
            )
            .onTapGesture {
                self.focusedField = 3
            }
        }
    }
    
    private var whyNotBuySectionView: some View {
        VStack(spacing: SpacingHelper.sm.pixel) {
            sectionTopTextView(text: TextHelper.buyOrNotWhyNotBuyTitle, required: true)
            
            DisablePasteTextField(
                text: $store.notBuyText.sending(\.bindingBuyNotText),
                placeholder: TextHelper.buyOrNotWhyNotBuyPlaceHolder,
                placeholderColor: GBColor.grey500.asColor,
                edge: UIEdgeInsets(top: 17, left: 18, bottom: 17, right: 18),
                keyboardType: .default
            ) {
                
            }
            .background(GBColor.grey600.asColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(GBColor.grey500.asColor.opacity(0.5), lineWidth: 1)
            )
            .onTapGesture {
                self.focusedField = 4
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
    
    private func scrollToFocusedField(_ proxy: ScrollViewProxy) {
        guard let field = focusedField else { return }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation {
                proxy.scrollTo(field, anchor: .top)
            }
        }
    }
}

#if DEBUG
#Preview {
    BuyOrNotAddView(store: Store(initialState: BuyOrNotAddViewFeature.State(stateMode: .add), reducer: {
        BuyOrNotAddViewFeature()
    }))
}
#endif
