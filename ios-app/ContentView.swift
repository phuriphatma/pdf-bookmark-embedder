import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var bookmarkManager = BookmarkManager()
    @State private var selectedPDF: URL?
    @State private var showingFilePicker = false
    @State private var showingBookmarkDialog = false
    @State private var newBookmarkName = ""
    @State private var isExporting = false
    @State private var exportStatus = ""
    
    var body: some View {
        NavigationView {
            // Sidebar with file info and bookmarks
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 15) {
                    Button(action: {
                        showingFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("Choose PDF File")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    if let pdfURL = selectedPDF {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text(pdfURL.lastPathComponent)
                                    .font(.headline)
                                    .lineLimit(2)
                            }
                            
                            HStack {
                                Image(systemName: "ruler")
                                Text(formatFileSize(pdfURL))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "doc.plaintext")
                                Text("\(bookmarkManager.totalPages) pages")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                Divider()
                
                // Bookmarks section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("🔖 Bookmarks")
                            .font(.headline)
                        Spacer()
                        Text("(\(bookmarkManager.bookmarks.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if bookmarkManager.bookmarks.isEmpty {
                        VStack(spacing: 8) {
                            Text("No bookmarks yet")
                                .foregroundColor(.secondary)
                            Text("Tap + to add bookmarks while viewing")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        List {
                            ForEach(bookmarkManager.bookmarks) { bookmark in
                                BookmarkRow(
                                    bookmark: bookmark,
                                    onTap: {
                                        bookmarkManager.currentPage = bookmark.page
                                    },
                                    onDelete: {
                                        bookmarkManager.deleteBookmark(bookmark)
                                    }
                                )
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                Spacer()
                
                // Export button
                if selectedPDF != nil {
                    VStack(spacing: 8) {
                        if isExporting {
                            ProgressView()
                            Text(exportStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Button(action: exportPDF) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export PDF with Bookmarks")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(bookmarkManager.bookmarks.isEmpty)
                        }
                    }
                    .padding()
                }
            }
            .frame(minWidth: 300, maxWidth: 350)
            .background(Color(UIColor.systemGroupedBackground))
            
            // Main PDF viewer
            Group {
                if let pdfURL = selectedPDF {
                    PDFViewerView(
                        pdfURL: pdfURL,
                        bookmarkManager: bookmarkManager,
                        onAddBookmark: {
                            showingBookmarkDialog = true
                        }
                    )
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 80))
                            .foregroundColor(.secondary)
                        Text("Select a PDF file to begin viewing and bookmarking")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                }
            }
        }
        .navigationTitle("📚 PDF Bookmark Manager")
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    loadPDF(url: url)
                }
            case .failure(let error):
                print("Error selecting PDF: \(error)")
            }
        }
        .alert("Add Bookmark", isPresented: $showingBookmarkDialog) {
            TextField("Bookmark name", text: $newBookmarkName)
            Button("Cancel", role: .cancel) {
                newBookmarkName = ""
            }
            Button("Save") {
                if !newBookmarkName.isEmpty {
                    bookmarkManager.addBookmark(name: newBookmarkName, page: bookmarkManager.currentPage)
                    newBookmarkName = ""
                }
            }
        } message: {
            Text("Enter a name for the bookmark on page \(bookmarkManager.currentPage)")
        }
    }
    
    private func loadPDF(url: URL) {
        selectedPDF = url
        bookmarkManager.loadPDF(from: url)
    }
    
    private func formatFileSize(_ url: URL) -> String {
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resources.fileSize {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useMB, .useKB, .useBytes]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: Int64(fileSize))
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return "Unknown size"
    }
    
    private func exportPDF() {
        guard let pdfURL = selectedPDF else { return }
        
        isExporting = true
        exportStatus = "Processing PDF..."
        
        Task {
            do {
                let processor = PDFProcessor()
                let outputURL = try await processor.addBookmarksToPDF(
                    pdfURL: pdfURL,
                    bookmarks: bookmarkManager.bookmarks
                ) { progress in
                    DispatchQueue.main.async {
                        exportStatus = "Processing: \(Int(progress * 100))%"
                    }
                }
                
                DispatchQueue.main.async {
                    isExporting = false
                    exportStatus = ""
                    
                    // Share the exported PDF
                    let activityVC = UIActivityViewController(
                        activityItems: [outputURL],
                        applicationActivities: nil
                    )
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityVC, animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isExporting = false
                    exportStatus = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct BookmarkRow: View {
    let bookmark: PDFBookmark
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bookmark.name)
                    .font(.body)
                Text("Page \(bookmark.page)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    ContentView()
}
