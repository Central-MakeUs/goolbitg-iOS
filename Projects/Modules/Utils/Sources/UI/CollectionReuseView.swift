import SwiftUI
import UIKit

public enum CollectionReuseEvent<ItemID: Hashable> {
    case willDisplay(ItemID)
    case didEndDisplay(ItemID)
    case prepareForReuse(ItemID?)
    case deinitCell
}

public enum CollectionReuseSizing {
    case fixed(CGSize)
    case estimated(CGSize)
}

public struct CollectionReuseView<Item: Identifiable, CellContent: View>: View where Item.ID: Hashable {

    private let items: [Item]
    private let sizing: CollectionReuseSizing
    private let lineSpacing: CGFloat
    private let contentInset: EdgeInsets
    private let onEvent: ((CollectionReuseEvent<Item.ID>) -> Void)?
    private let cellContent: (Item) -> CellContent
    @State private var measuredEstimatedHeight: CGFloat = 1

    public init(
        items: [Item],
        sizing: CollectionReuseSizing,
        lineSpacing: CGFloat = 0,
        contentInset: EdgeInsets = EdgeInsets(),
        onEvent: ((CollectionReuseEvent<Item.ID>) -> Void)? = nil,
        @ViewBuilder cellContent: @escaping (Item) -> CellContent
    ) {
        self.items = items
        self.sizing = sizing
        self.lineSpacing = lineSpacing
        self.contentInset = contentInset
        self.onEvent = onEvent
        self.cellContent = cellContent
    }

    public init(
        items: [Item],
        itemSize: CGSize,
        lineSpacing: CGFloat = 0,
        contentInset: EdgeInsets = EdgeInsets(),
        onEvent: ((CollectionReuseEvent<Item.ID>) -> Void)? = nil,
        @ViewBuilder cellContent: @escaping (Item) -> CellContent
    ) {
        self.init(
            items: items,
            sizing: .fixed(itemSize),
            lineSpacing: lineSpacing,
            contentInset: contentInset,
            onEvent: onEvent,
            cellContent: cellContent
        )
    }

    public var body: some View {
        switch sizing {
        case let .fixed(size):
            CollectionReuseRepresentable(
                items: items,
                sizing: sizing,
                lineSpacing: lineSpacing,
                contentInset: contentInset,
                containerSize: size,
                onMeasuredContentHeight: nil,
                onEvent: onEvent,
                cellContent: { AnyView(cellContent($0)) }
            )
            .frame(height: size.height + contentInset.top + contentInset.bottom)
        case let .estimated(size):
            GeometryReader { proxy in
                CollectionReuseRepresentable(
                    items: items,
                    sizing: sizing,
                    lineSpacing: lineSpacing,
                    contentInset: contentInset,
                    containerSize: proxy.size,
                    onMeasuredContentHeight: { measured in
                        let next = max(measured, size.height + contentInset.top + contentInset.bottom)
                        if abs(next - measuredEstimatedHeight) > 0.5 {
                            measuredEstimatedHeight = next
                        }
                    },
                    onEvent: onEvent,
                    cellContent: { AnyView(cellContent($0)) }
                )
            }
            .frame(height: max(measuredEstimatedHeight, size.height + contentInset.top + contentInset.bottom))
        }
    }
}

private struct CollectionReuseRepresentable<Item: Identifiable>: UIViewRepresentable where Item.ID: Hashable {
    typealias UIViewType = UICollectionView

    let items: [Item]
    let sizing: CollectionReuseSizing
    let lineSpacing: CGFloat
    let contentInset: EdgeInsets
    let containerSize: CGSize
    let onMeasuredContentHeight: ((CGFloat) -> Void)?
    let onEvent: ((CollectionReuseEvent<Item.ID>) -> Void)?
    let cellContent: (Item) -> AnyView

    func makeCoordinator() -> Coordinator {
        Coordinator(items: items, onEvent: onEvent, minimumEstimatedSize: nil, cellContent: cellContent)
    }

    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = lineSpacing
        applySizing(to: layout)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.contentInset = uiContentInset
        view.showsHorizontalScrollIndicator = true
        view.dataSource = context.coordinator
        view.delegate = context.coordinator
        view.register(ReuseHostingCell.self, forCellWithReuseIdentifier: ReuseHostingCell.reuseIdentifier)
        return view
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        let resolvedEstimatedSize = resolveEstimatedSize(for: uiView)
        context.coordinator.update(
            items: items,
            onEvent: onEvent,
            minimumEstimatedSize: resolvedEstimatedSize,
            cellContent: cellContent
        )
        if let layout = uiView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = lineSpacing
            layout.minimumInteritemSpacing = lineSpacing
            applySizing(to: layout)
        }
        uiView.contentInset = uiContentInset
        uiView.reloadData()
        reportMeasuredContentHeight(from: uiView)
    }

    private func applySizing(to layout: UICollectionViewFlowLayout) {
        switch sizing {
        case .fixed(let size):
            layout.estimatedItemSize = .zero
            layout.itemSize = size
        case .estimated(let size):
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            layout.estimatedItemSize = size
        }
    }

    private var uiContentInset: UIEdgeInsets {
        UIEdgeInsets(
            top: contentInset.top,
            left: contentInset.leading,
            bottom: contentInset.bottom,
            right: contentInset.trailing
        )
    }

    private var minimumEstimatedSize: CGSize? {
        switch sizing {
        case .fixed:
            return nil
        case .estimated(let size):
            return size
        }
    }

    private func resolveEstimatedSize(for uiView: UICollectionView) -> CGSize? {
        guard case .estimated = sizing else { return nil }
        guard let minimumEstimatedSize else { return nil }

        let measuredHeight = max(containerSize.height, uiView.bounds.height)
        let containerHeight = measuredHeight - uiContentInset.top - uiContentInset.bottom
        let resolvedHeight = max(minimumEstimatedSize.height, containerHeight)
        return CGSize(width: minimumEstimatedSize.width, height: resolvedHeight)
    }

    private func reportMeasuredContentHeight(from uiView: UICollectionView) {
        guard onMeasuredContentHeight != nil else { return }
        DispatchQueue.main.async {
            uiView.layoutIfNeeded()
            let contentHeight = uiView.collectionViewLayout.collectionViewContentSize.height
            let resolved = contentHeight + uiContentInset.top + uiContentInset.bottom
            onMeasuredContentHeight?(resolved)
        }
    }

    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        private var items: [Item]
        private var onEvent: ((CollectionReuseEvent<Item.ID>) -> Void)?
        private var minimumEstimatedSize: CGSize?
        private var cellContent: (Item) -> AnyView

        init(
            items: [Item],
            onEvent: ((CollectionReuseEvent<Item.ID>) -> Void)?,
            minimumEstimatedSize: CGSize?,
            cellContent: @escaping (Item) -> AnyView
        ) {
            self.items = items
            self.onEvent = onEvent
            self.minimumEstimatedSize = minimumEstimatedSize
            self.cellContent = cellContent
        }

        func update(
            items: [Item],
            onEvent: ((CollectionReuseEvent<Item.ID>) -> Void)?,
            minimumEstimatedSize: CGSize?,
            cellContent: @escaping (Item) -> AnyView
        ) {
            self.items = items
            self.onEvent = onEvent
            self.minimumEstimatedSize = minimumEstimatedSize
            self.cellContent = cellContent
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            items.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ReuseHostingCell.reuseIdentifier,
                for: indexPath
            ) as? ReuseHostingCell else {
                return UICollectionViewCell()
            }

            let item = items[indexPath.item]
            cell.configure(
                id: AnyHashable(item.id),
                content: cellContent(item),
                minimumEstimatedSize: minimumEstimatedSize,
                eventHandler: { [weak self] rawEvent in
                    self?.emit(rawEvent)
                }
            )
            return cell
        }

        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard indexPath.item < items.count else { return }
            onEvent?(.willDisplay(items[indexPath.item].id))
        }

        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard indexPath.item < items.count else { return }
            onEvent?(.didEndDisplay(items[indexPath.item].id))
        }

        private func emit(_ rawEvent: ReuseHostingCell.RawEvent) {
            switch rawEvent {
            case .prepareForReuse(let id):
                onEvent?(.prepareForReuse(id as? Item.ID))
            case .deinitCell:
                onEvent?(.deinitCell)
            }
        }
    }
}

private final class ReuseHostingCell: UICollectionViewCell {
    static let reuseIdentifier = "ReuseHostingCell"

    enum RawEvent {
        case prepareForReuse(AnyHashable?)
        case deinitCell
    }

    private(set) var currentID: AnyHashable?
    private var eventHandler: ((RawEvent) -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()
        eventHandler?(.prepareForReuse(currentID))
        contentConfiguration = nil
        currentID = nil
    }

    deinit {
        eventHandler?(.deinitCell)
    }

    func configure(
        id: AnyHashable,
        content: AnyView,
        minimumEstimatedSize: CGSize?,
        eventHandler: @escaping (RawEvent) -> Void
    ) {
        currentID = id
        self.eventHandler = eventHandler

        let configuredContent: AnyView
        if let minimumEstimatedSize {
            configuredContent = AnyView(
                content.frame(
                    minWidth: minimumEstimatedSize.width,
                    minHeight: minimumEstimatedSize.height,
                    alignment: .center
                )
            )
        } else {
            configuredContent = content
        }

        contentConfiguration = UIHostingConfiguration {
            configuredContent
        }
        .margins(.all, 0)
    }
}

#Preview {
    CollectionReuseViewPreviewContainer()
        .padding(.horizontal, 16)
}

private struct CollectionReusePreviewItem: Identifiable {
    let id: UUID
    let index: Int
    let title: String
    let hue: Double

    var color: Color {
        Color(hue: hue, saturation: 0.75, brightness: 0.9)
    }

    static let samples: [CollectionReusePreviewItem] = (0..<30).map { index in
        let randomLength = Int.random(in: 4...14)
        let title = String(repeating: "#", count: randomLength) + " \(index)"
        return CollectionReusePreviewItem(
            id: UUID(),
            index: index,
            title: title,
            hue: Double.random(in: 0...1)
        )
    }
}

private struct CollectionReuseViewPreviewContainer: View {
    @State private var mode: PreviewMode = .fixed
    @State private var items: [CollectionReusePreviewItem] = CollectionReusePreviewItem.samples

    var body: some View {
        VStack(spacing: 12) {
            Picker("Preview Mode", selection: $mode) {
                ForEach(PreviewMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            CollectionReuseView(
                items: items,
                sizing: mode.sizing,
                lineSpacing: 8,
                contentInset: EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            ) { item in
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.color)
                    .overlay {
                        VStack(spacing: 8) {
                            Text("\(item.index)")
                                .font(.headline)
                            Text(item.title)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                    }
            }

            Button("Shuffle") {
                items.shuffle()
            }
            .buttonStyle(.bordered)

            Text("Estimated uses container height via geometry (UICollectionView bounds).")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(height: mode.previewHeight)
    }

    private enum PreviewMode: String, CaseIterable, Identifiable {
        case fixed
        case wider
        case estimated

        var id: String { rawValue }

        var sizing: CollectionReuseSizing {
            switch self {
            case .fixed:
                return .fixed(CGSize(width: 100, height: 200))
            case .wider:
                return .fixed(CGSize(width: 160, height: 200))
            case .estimated:
                return .estimated(CGSize(width: 0, height: 120))
            }
        }

        var title: String {
            switch self {
            case .fixed:
                return "Fixed 100"
            case .wider:
                return "Fixed 160"
            case .estimated:
                return "Estimated"
            }
        }

        var previewHeight: CGFloat {
            switch self {
            case .fixed, .wider:
                return 120
            case .estimated:
                return 170
            }
        }
    }
}
