import SwiftUI
import PDFKit

struct PDFViewerView: UIViewRepresentable {
    let pdfURL: URL
    @ObservedObject var bookmarkManager: BookmarkManager
    let onAddBookmark: () -> Void
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Configure PDF view
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.systemBackground
        
        // Load the PDF document
        if let document = PDFDocument(url: pdfURL) {
            pdfView.document = document
            bookmarkManager.totalPages = document.pageCount
            
            // Set initial page if we have a current page
            if bookmarkManager.currentPage > 0 && bookmarkManager.currentPage <= document.pageCount {
                if let page = document.page(at: bookmarkManager.currentPage - 1) {
                    pdfView.go(to: page)
                }
            }
        }
        
        // Set up delegate
        pdfView.delegate = context.coordinator
        
        // Add gesture recognizer for adding bookmarks
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        pdfView.addGestureRecognizer(tapGesture)
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update current page if needed
        if let document = pdfView.document,
           bookmarkManager.currentPage > 0 && bookmarkManager.currentPage <= document.pageCount {
            let targetPageIndex = bookmarkManager.currentPage - 1
            if let currentPage = pdfView.currentPage,
               let currentPageIndex = document.index(for: currentPage),
               currentPageIndex != targetPageIndex {
                if let targetPage = document.page(at: targetPageIndex) {
                    pdfView.go(to: targetPage)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        let parent: PDFViewerView
        
        init(_ parent: PDFViewerView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            parent.onAddBookmark()
        }
        
        func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
            // Handle link clicks if needed
        }
        
        func pdfViewDidChange(sender: PDFView) {
            // Update current page when user scrolls
            if let document = sender.document,
               let currentPage = sender.currentPage {
                let pageIndex = document.index(for: currentPage)
                DispatchQueue.main.async {
                    self.parent.bookmarkManager.currentPage = pageIndex + 1
                }
            }
        }
    }
}

// Alternative SwiftUI-native PDF viewer for iOS 17+
@available(iOS 17.0, *)
struct NativePDFViewerView: View {
    let pdfURL: URL
    @ObservedObject var bookmarkManager: BookmarkManager
    let onAddBookmark: () -> Void
    
    @State private var pdfDocument: PDFDocument?
    @State private var currentPageIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: {
                    if currentPageIndex > 0 {
                        currentPageIndex -= 1
                        bookmarkManager.currentPage = currentPageIndex + 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .disabled(currentPageIndex <= 0)
                
                Spacer()
                
                VStack {
                    Text("Page \(currentPageIndex + 1)")
                        .font(.headline)
                    if let document = pdfDocument {
                        Text("of \(document.pageCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if let document = pdfDocument, currentPageIndex < document.pageCount - 1 {
                        currentPageIndex += 1
                        bookmarkManager.currentPage = currentPageIndex + 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                .disabled(pdfDocument == nil || currentPageIndex >= (pdfDocument?.pageCount ?? 0) - 1)
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            
            // PDF content
            ScrollView([.horizontal, .vertical]) {
                if let document = pdfDocument,
                   let page = document.page(at: currentPageIndex) {
                    PDFPageView(page: page)
                        .onTapGesture(count: 2) {
                            onAddBookmark()
                        }
                } else {
                    ProgressView("Loading PDF...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color.white)
            
            // Bottom toolbar
            HStack {
                Button(action: onAddBookmark) {
                    HStack {
                        Image(systemName: "bookmark.circle")
                        Text("Add Bookmark")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Page indicator
                HStack {
                    TextField("Page", value: $currentPageIndex, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                        .onChange(of: currentPageIndex) { oldValue, newValue in
                            let clampedValue = max(0, min(newValue, (pdfDocument?.pageCount ?? 1) - 1))
                            if clampedValue != newValue {
                                currentPageIndex = clampedValue
                            }
                            bookmarkManager.currentPage = currentPageIndex + 1
                        }
                    
                    Text("/ \(pdfDocument?.pageCount ?? 0)")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
        }
        .onAppear {
            loadPDF()
        }
        .onChange(of: bookmarkManager.currentPage) { oldValue, newValue in
            let targetIndex = newValue - 1
            if targetIndex >= 0 && targetIndex < (pdfDocument?.pageCount ?? 0) && targetIndex != currentPageIndex {
                currentPageIndex = targetIndex
            }
        }
    }
    
    private func loadPDF() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let document = PDFDocument(url: pdfURL) {
                DispatchQueue.main.async {
                    self.pdfDocument = document
                    self.bookmarkManager.totalPages = document.pageCount
                    self.currentPageIndex = max(0, min(self.bookmarkManager.currentPage - 1, document.pageCount - 1))
                }
            }
        }
    }
}

struct PDFPageView: UIViewRepresentable {
    let page: PDFPage
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        // Create a custom view to render the PDF page
        let pageView = PDFPageRenderView(page: page)
        pageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pageView)
        
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
}

class PDFPageRenderView: UIView {
    let page: PDFPage
    
    init(page: PDFPage) {
        self.page = page
        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Fill background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // Draw PDF page
        context.saveGState()
        
        let pageRect = page.bounds(for: .mediaBox)
        let scaleX = rect.width / pageRect.width
        let scaleY = rect.height / pageRect.height
        let scale = min(scaleX, scaleY)
        
        let scaledWidth = pageRect.width * scale
        let scaledHeight = pageRect.height * scale
        let offsetX = (rect.width - scaledWidth) / 2
        let offsetY = (rect.height - scaledHeight) / 2
        
        context.translateBy(x: offsetX, y: offsetY + scaledHeight)
        context.scaleBy(x: scale, y: -scale)
        context.translateBy(x: -pageRect.minX, y: -pageRect.minY)
        
        page.draw(with: .mediaBox, to: context)
        
        context.restoreGState()
    }
    
    override var intrinsicContentSize: CGSize {
        let pageRect = page.bounds(for: .mediaBox)
        let aspectRatio = pageRect.width / pageRect.height
        let maxWidth: CGFloat = 800
        let width = min(maxWidth, pageRect.width)
        let height = width / aspectRatio
        return CGSize(width: width, height: height)
    }
}
