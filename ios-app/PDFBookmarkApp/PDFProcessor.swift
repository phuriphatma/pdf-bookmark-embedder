import Foundation
import PDFKit

// MARK: - PDFProcessor
class PDFProcessor {
    
    enum ProcessingError: LocalizedError {
        case invalidPDF
        case processingFailed
        case saveFailed
        case memoryLimitExceeded
        
        var errorDescription: String? {
            switch self {
            case .invalidPDF:
                return "Invalid PDF file"
            case .processingFailed:
                return "PDF processing failed"
            case .saveFailed:
                return "Failed to save PDF"
            case .memoryLimitExceeded:
                return "PDF file too large for processing"
            }
        }
    }
    
    // MARK: - Main Processing Function
    func addBookmarksToPDF(
        pdfURL: URL,
        bookmarks: [PDFBookmark],
        progressHandler: @escaping (Double) -> Void = { _ in }
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try self.processBookmarks(
                        pdfURL: pdfURL,
                        bookmarks: bookmarks,
                        progressHandler: progressHandler
                    )
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func processBookmarks(
        pdfURL: URL,
        bookmarks: [PDFBookmark],
        progressHandler: @escaping (Double) -> Void
    ) throws -> URL {
        
        progressHandler(0.1)
        
        // Load the PDF document
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            throw ProcessingError.invalidPDF
        }
        
        progressHandler(0.2)
        
        // Check memory constraints for large files
        let fileSize = try getFileSize(pdfURL)
        if fileSize > 200 * 1024 * 1024 { // 200MB limit
            throw ProcessingError.memoryLimitExceeded
        }
        
        progressHandler(0.3)
        
        // Add bookmarks to the document
        try addBookmarksToDocument(pdfDocument, bookmarks: bookmarks) { progress in
            progressHandler(0.3 + (progress * 0.5))
        }
        
        progressHandler(0.8)
        
        // Generate output URL
        let outputURL = try generateOutputURL(for: pdfURL)
        
        progressHandler(0.9)
        
        // Save the modified PDF
        guard pdfDocument.write(to: outputURL) else {
            throw ProcessingError.saveFailed
        }
        
        progressHandler(1.0)
        
        return outputURL
    }
    
    // MARK: - Bookmark Addition
    private func addBookmarksToDocument(
        _ document: PDFDocument,
        bookmarks: [PDFBookmark],
        progressHandler: @escaping (Double) -> Void
    ) throws {
        
        guard !bookmarks.isEmpty else { return }
        
        // Create root outline
        let outline = PDFOutline()
        outline.label = "Bookmarks"
        
        // Sort bookmarks by page number
        let sortedBookmarks = bookmarks.sorted { $0.page < $1.page }
        
        for (index, bookmark) in sortedBookmarks.enumerated() {
            // Update progress
            let progress = Double(index) / Double(sortedBookmarks.count)
            progressHandler(progress)
            
            // Validate page number
            guard bookmark.page > 0 && bookmark.page <= document.pageCount else {
                continue
            }
            
            // Get the PDF page
            guard let page = document.page(at: bookmark.page - 1) else {
                continue
            }
            
            // Create bookmark outline
            let bookmarkOutline = PDFOutline()
            bookmarkOutline.label = bookmark.name
            
            // Create destination
            let destination = PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: .mediaBox).height))
            bookmarkOutline.destination = destination
            
            // Add to root outline
            outline.insertChild(bookmarkOutline, at: outline.numberOfChildren)
        }
        
        // Set the outline root
        document.outlineRoot = outline
        
        progressHandler(1.0)
    }
    
    // MARK: - File Management
    private func getFileSize(_ url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
    
    private func generateOutputURL(for inputURL: URL) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputDir = documentsPath.appendingPathComponent("ProcessedPDFs", isDirectory: true)
        
        // Create directory if it doesn't exist
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        // Generate unique filename
        let baseName = inputURL.deletingPathExtension().lastPathComponent
        let timestamp = Int(Date().timeIntervalSince1970)
        let outputFilename = "\(baseName)_bookmarked_\(timestamp).pdf"
        
        return outputDir.appendingPathComponent(outputFilename)
    }
    
    // MARK: - Alternative Processing Methods
    
    // Method for very large files - creates a copy with bookmarks
    func addBookmarksToLargePDF(
        pdfURL: URL,
        bookmarks: [PDFBookmark],
        progressHandler: @escaping (Double) -> Void = { _ in }
    ) async throws -> URL {
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                do {
                    progressHandler(0.1)
                    
                    // For very large files, we'll copy the file first
                    let outputURL = try self.generateOutputURL(for: pdfURL)
                    try FileManager.default.copyItem(at: pdfURL, to: outputURL)
                    
                    progressHandler(0.4)
                    
                    // Load the copied document
                    guard let document = PDFDocument(url: outputURL) else {
                        throw ProcessingError.invalidPDF
                    }
                    
                    progressHandler(0.5)
                    
                    // Add bookmarks
                    try self.addBookmarksToDocument(document, bookmarks: bookmarks) { progress in
                        progressHandler(0.5 + (progress * 0.4))
                    }
                    
                    progressHandler(0.9)
                    
                    // Save the document back
                    guard document.write(to: outputURL) else {
                        throw ProcessingError.saveFailed
                    }
                    
                    progressHandler(1.0)
                    continuation.resume(returning: outputURL)
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Method for creating bookmark JSON export
    func exportBookmarksAsJSON(bookmarks: [PDFBookmark]) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputDir = documentsPath.appendingPathComponent("BookmarkExports", isDirectory: true)
        
        // Create directory if it doesn't exist
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        // Generate filename
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "bookmarks_\(timestamp).json"
        let outputURL = outputDir.appendingPathComponent(filename)
        
        // Create export data
        let exportData = BookmarkExportData(
            bookmarks: bookmarks.map { BookmarkExportItem(name: $0.name, page: $0.page) },
            exportDate: Date(),
            totalBookmarks: bookmarks.count
        )
        
        // Encode and save
        let jsonData = try JSONEncoder().encode(exportData)
        try jsonData.write(to: outputURL)
        
        return outputURL
    }
    
    // MARK: - Validation
    func validatePDF(at url: URL) -> Bool {
        guard let document = PDFDocument(url: url) else {
            return false
        }
        return document.pageCount > 0
    }
    
    func getPDFInfo(at url: URL) -> PDFInfo? {
        guard let document = PDFDocument(url: url) else {
            return nil
        }
        
        let fileSize = (try? getFileSize(url)) ?? 0
        
        return PDFInfo(
            pageCount: document.pageCount,
            fileSize: fileSize,
            title: document.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String,
            author: document.documentAttributes?[PDFDocumentAttribute.authorAttribute] as? String,
            creator: document.documentAttributes?[PDFDocumentAttribute.creatorAttribute] as? String,
            hasBookmarks: document.outlineRoot != nil
        )
    }
}

// MARK: - Supporting Data Structures
struct PDFInfo {
    let pageCount: Int
    let fileSize: Int64
    let title: String?
    let author: String?
    let creator: String?
    let hasBookmarks: Bool
    
    var fileSizeFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useBytes]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

struct BookmarkExportData: Codable {
    let bookmarks: [BookmarkExportItem]
    let exportDate: Date
    let totalBookmarks: Int
}

struct BookmarkExportItem: Codable {
    let name: String
    let page: Int
}

// MARK: - Extensions
extension PDFProcessor {
    
    // Cleanup old processed files
    func cleanupOldFiles(olderThan days: Int = 7) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputDir = documentsPath.appendingPathComponent("ProcessedPDFs", isDirectory: true)
        
        guard FileManager.default.fileExists(atPath: outputDir.path) else { return }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: outputDir, includingPropertiesForKeys: [.creationDateKey])
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            
            for file in files {
                if let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   creationDate < cutoffDate {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("Error cleaning up old files: \(error)")
        }
    }
    
    // Get estimated processing time based on file size
    func estimatedProcessingTime(for fileSize: Int64) -> TimeInterval {
        // Rough estimate: 1 second per MB
        let mbSize = Double(fileSize) / (1024 * 1024)
        return max(1.0, mbSize * 0.5) // Minimum 1 second, 0.5 seconds per MB
    }
}
