import Foundation
import PDFKit

// MARK: - PDFBookmark Model
struct PDFBookmark: Identifiable, Codable {
    let id = UUID()
    var name: String
    var page: Int
    var createdAt: Date
    
    init(name: String, page: Int) {
        self.name = name
        self.page = page
        self.createdAt = Date()
    }
}

// MARK: - BookmarkManager
class BookmarkManager: ObservableObject {
    @Published var bookmarks: [PDFBookmark] = []
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 0
    
    private var currentPDFURL: URL?
    
    init() {
        loadBookmarks()
    }
    
    // MARK: - PDF Management
    func loadPDF(from url: URL) {
        currentPDFURL = url
        loadBookmarks()
        
        // Load PDF to get page count
        if let document = PDFDocument(url: url) {
            totalPages = document.pageCount
        }
        
        currentPage = 1
    }
    
    // MARK: - Bookmark Management
    func addBookmark(name: String, page: Int) {
        // Check if bookmark already exists for this page
        if bookmarks.contains(where: { $0.page == page }) {
            // Update existing bookmark
            if let index = bookmarks.firstIndex(where: { $0.page == page }) {
                bookmarks[index].name = name
            }
        } else {
            // Add new bookmark
            let bookmark = PDFBookmark(name: name, page: page)
            bookmarks.append(bookmark)
        }
        
        // Sort bookmarks by page number
        bookmarks.sort { $0.page < $1.page }
        
        saveBookmarks()
    }
    
    func deleteBookmark(_ bookmark: PDFBookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        saveBookmarks()
    }
    
    func deleteBookmark(at page: Int) {
        bookmarks.removeAll { $0.page == page }
        saveBookmarks()
    }
    
    func bookmark(for page: Int) -> PDFBookmark? {
        return bookmarks.first { $0.page == page }
    }
    
    func clearAllBookmarks() {
        bookmarks.removeAll()
        saveBookmarks()
    }
    
    // MARK: - Navigation
    func goToPage(_ page: Int) {
        if page >= 1 && page <= totalPages {
            currentPage = page
        }
    }
    
    func nextPage() {
        if currentPage < totalPages {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 1 {
            currentPage -= 1
        }
    }
    
    func goToBookmark(_ bookmark: PDFBookmark) {
        goToPage(bookmark.page)
    }
    
    // MARK: - Persistence
    private var bookmarksFileURL: URL? {
        guard let pdfURL = currentPDFURL else { return nil }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let bookmarksDir = documentsPath.appendingPathComponent("PDFBookmarks", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: bookmarksDir, withIntermediateDirectories: true)
        
        // Create a filename based on the PDF file
        let pdfName = pdfURL.lastPathComponent
        let bookmarksFile = bookmarksDir.appendingPathComponent("\(pdfName).bookmarks.json")
        
        return bookmarksFile
    }
    
    private func saveBookmarks() {
        guard let fileURL = bookmarksFileURL else { return }
        
        do {
            let data = try JSONEncoder().encode(bookmarks)
            try data.write(to: fileURL)
        } catch {
            print("Error saving bookmarks: \(error)")
        }
    }
    
    private func loadBookmarks() {
        guard let fileURL = bookmarksFileURL,
              FileManager.default.fileExists(atPath: fileURL.path) else {
            bookmarks = []
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            bookmarks = try JSONDecoder().decode([PDFBookmark].self, from: data)
        } catch {
            print("Error loading bookmarks: \(error)")
            bookmarks = []
        }
    }
    
    // MARK: - Export Data
    func getBookmarksForExport() -> [(String, Int)] {
        return bookmarks.map { ($0.name, $0.page) }
    }
    
    // MARK: - Default Bookmarks
    func addDefaultBookmarks() {
        // Add default bookmarks for pages 1, 3, and 6 (matching web app behavior)
        let defaultBookmarks = [
            ("Introduction", 1),
            ("Chapter 1", 3),
            ("Chapter 2", 6)
        ]
        
        for (name, page) in defaultBookmarks {
            if page <= totalPages && !bookmarks.contains(where: { $0.page == page }) {
                addBookmark(name: name, page: page)
            }
        }
    }
    
    // MARK: - Statistics
    var bookmarkStats: (total: Int, coverage: Double) {
        let total = bookmarks.count
        let coverage = totalPages > 0 ? Double(total) / Double(totalPages) * 100 : 0
        return (total: total, coverage: coverage)
    }
    
    // MARK: - Validation
    func validateBookmarks() {
        // Remove bookmarks that exceed the total page count
        bookmarks.removeAll { $0.page > totalPages || $0.page < 1 }
        saveBookmarks()
    }
    
    // MARK: - Import/Export
    func exportBookmarksToJSON() -> Data? {
        do {
            return try JSONEncoder().encode(bookmarks)
        } catch {
            print("Error exporting bookmarks: \(error)")
            return nil
        }
    }
    
    func importBookmarksFromJSON(_ data: Data) -> Bool {
        do {
            let importedBookmarks = try JSONDecoder().decode([PDFBookmark].self, from: data)
            
            // Validate imported bookmarks
            let validBookmarks = importedBookmarks.filter { $0.page >= 1 && $0.page <= totalPages }
            
            // Merge with existing bookmarks (replace duplicates)
            for bookmark in validBookmarks {
                addBookmark(name: bookmark.name, page: bookmark.page)
            }
            
            return true
        } catch {
            print("Error importing bookmarks: \(error)")
            return false
        }
    }
}

// MARK: - Bookmark Extensions
extension PDFBookmark {
    var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var pageDescription: String {
        return "Page \(page)"
    }
}
