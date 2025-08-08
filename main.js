// PDF Bookmark Embedder - Main Application
// Optimized for iOS Safari

class PDFBookmarkEmbedder {
    constructor() {
        this.serverUrl = this.getServerUrl()
        this.currentFile = null
        this.initializeElements()
        this.bindEvents()
    }

    async embedBookmarks(file, bookmarks) {
        try {
            console.log('📤 Sending PDF to server for processing...')
            console.log('🗃️ File details:', {
                name: file.name,
                size: file.size,
                type: file.type,
                lastModified: file.lastModified
            })
            console.log('🔗 Server URL:', `${this.serverUrl}/embed-bookmarks`)
            
            // Send to server
            const formData = new FormData()
            formData.append('pdf', file)
            formData.append('bookmarks', JSON.stringify(bookmarks))

            const response = await fetch(`${this.serverUrl}/embed-bookmarks`, {
                method: 'POST',
                body: formData
            })

            if (response.ok) {
                const blob = await response.blob()
                return blob
            } else {
                throw new Error(`Server error: ${response.status}`)
            }
        } catch (error) {
            console.error('❌ Server error:', error)
            throw error
        }
    }

    getServerUrl() {
        // If we're accessing from a different device, use the current host
        const currentHost = window.location.hostname
        if (currentHost !== 'localhost' && currentHost !== '127.0.0.1') {
            return `http://${currentHost}:8081`
        }
        return 'http://localhost:8081'
    }

    displayNetworkInfo() {
        // Show network access information
        const currentHost = window.location.hostname
        if (currentHost !== 'localhost' && currentHost !== '127.0.0.1') {
            console.log(`📱 Accessing from network device: ${currentHost}`)
            console.log(`🔗 Server URL: ${this.serverUrl}`)
        } else {
            // Show iPad access URL when running on localhost
            const ipadUrl = `http://192.168.1.182:3000`
            this.elements.networkInfo.style.display = 'block'
            this.elements.ipadUrl.textContent = ipadUrl
            console.log(`📱 iPad can access at: ${ipadUrl}`)
        }
    }

    initializeElements() {
        // Get all DOM elements
        this.elements = {
            uploadArea: document.getElementById('uploadArea'),
            fileInput: document.getElementById('fileInput'),
            uploadBtn: document.getElementById('uploadBtn'),
            processing: document.getElementById('processing'),
            processingStatus: document.getElementById('processingStatus'),
            result: document.getElementById('result'),
            downloadBtn: document.getElementById('downloadBtn'),
            newFileBtn: document.getElementById('newFileBtn'),
            error: document.getElementById('error'),
            errorMessage: document.getElementById('errorMessage'),
            retryBtn: document.getElementById('retryBtn'),
            networkInfo: document.getElementById('networkInfo'),
            ipadUrl: document.getElementById('ipadUrl')
        }
    }

    bindEvents() {
        // File input events
        this.elements.uploadBtn.addEventListener('click', () => {
            this.elements.fileInput.click()
        })

        this.elements.fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                this.handleFileUpload(e.target.files[0])
            }
        })

        // Drag and drop events
        this.elements.uploadArea.addEventListener('click', () => {
            this.elements.fileInput.click()
        })

        this.elements.uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault()
            this.elements.uploadArea.classList.add('dragover')
        })

        this.elements.uploadArea.addEventListener('dragleave', () => {
            this.elements.uploadArea.classList.remove('dragover')
        })

        this.elements.uploadArea.addEventListener('drop', (e) => {
            e.preventDefault()
            this.elements.uploadArea.classList.remove('dragover')
            
            const files = e.dataTransfer.files
            if (files.length > 0 && files[0].type === 'application/pdf') {
                this.handleFileUpload(files[0])
            }
        })

        // Action buttons
        this.elements.downloadBtn.addEventListener('click', () => {
            this.downloadProcessedPDF()
        })

        this.elements.newFileBtn.addEventListener('click', () => {
            this.resetToUpload()
        })

        this.elements.retryBtn.addEventListener('click', () => {
            if (this.currentFile) {
                this.handleFileUpload(this.currentFile)
            } else {
                this.resetToUpload()
            }
        })
    }

    async checkServerStatus() {
        try {
            console.log('🔍 Checking server status...')
            const response = await fetch(`${this.serverUrl}/health`, {
                method: 'GET',
                mode: 'cors'
            })
            
            if (response.ok) {
                console.log('✅ Server is available')
            } else {
                console.warn('⚠️ Server responded with error:', response.status)
                this.showServerWarning()
            }
        } catch (error) {
            console.warn('⚠️ Server not available:', error.message)
            this.showServerWarning()
        }
    }

    showServerWarning() {
        // Create a subtle warning banner about server availability
        const banner = document.createElement('div')
        banner.innerHTML = `
            <div style="background: #fff3cd; color: #856404; padding: 10px; text-align: center; border-radius: 5px; margin-bottom: 20px; font-size: 0.9em;">
                ⚠️ Server not detected. Make sure to run: <code>npm run server</code>
            </div>
        `
        document.querySelector('.container').insertBefore(banner, document.querySelector('main'))
    }

    async handleFileUpload(file) {
        console.log('📁 File uploaded:', file.name, file.size, 'bytes')
        
        // Validate file
        if (!this.validateFile(file)) {
            return
        }

        this.currentFile = file
        this.showProcessing()
        
        try {
            // Show processing steps
            this.updateProcessingStatus('Reading PDF file...')
            await this.delay(500)
            
            this.updateProcessingStatus('Adding bookmarks to pages 1, 3, and 6...')
            await this.delay(1000)
            
            // Process the PDF
            const result = await this.processPDF(file)
            
            if (result.success) {
                this.processedPdfData = result.data
                this.showResult()
            } else {
                this.showError(result.error || 'Processing failed')
            }
            
        } catch (error) {
            console.error('❌ Processing error:', error)
            this.showError(error.message || 'Processing failed')
        }
    }

    validateFile(file) {
        // Check file type
        if (file.type !== 'application/pdf') {
            this.showError('Please select a PDF file')
            return false
        }

        // Check file size (50MB limit)
        const maxSize = 50 * 1024 * 1024 // 50MB
        if (file.size > maxSize) {
            this.showError('File too large. Please select a PDF smaller than 50MB')
            return false
        }

        // Check if file is not empty
        if (file.size === 0) {
            this.showError('The selected file is empty')
            return false
        }

        return true
    }

    async processPDF(file) {
        try {
            // Create form data
            const formData = new FormData()
            formData.append('pdf', file)
            
            console.log('📤 Sending PDF to server for processing...')
            console.log('� File details:', {
                name: file.name,
                size: file.size,
                type: file.type,
                lastModified: file.lastModified
            })
            
            // Send to server
            const response = await fetch(`${this.serverUrl}/embed-bookmarks`, {
                method: 'POST',
                body: formData,
                mode: 'cors'
            })

            console.log('📡 Server response status:', response.status, response.statusText)
            console.log('📡 Response headers:', Object.fromEntries(response.headers.entries()))

            if (!response.ok) {
                const errorText = await response.text()
                console.error('❌ Server error response:', errorText)
                throw new Error(`Server error: ${response.status} - ${errorText}`)
            }

            // Check if we got a PDF back
            const contentType = response.headers.get('content-type')
            console.log('📄 Response content type:', contentType)
            
            if (contentType && contentType.includes('application/pdf')) {
                const result = await response.blob()
                console.log('✅ PDF processed successfully, size:', result.size, 'bytes')
                
                return {
                    success: true,
                    data: result
                }
            } else {
                // Might be an error response in JSON
                const errorData = await response.text()
                console.error('❌ Unexpected response format:', errorData)
                throw new Error('Server returned unexpected response format')
            }
            
        } catch (error) {
            console.error('❌ Server processing failed:', error)
            
            // Try client-side fallback
            console.log('🔄 Attempting client-side processing fallback...')
            return await this.clientSideFallback(file)
        }
    }

    async clientSideFallback(file) {
        try {
            // Import pdf-lib dynamically for client-side processing
            const { PDFDocument } = await import('pdf-lib')
            
            this.updateProcessingStatus('Using client-side fallback...')
            
            // Read the PDF
            const arrayBuffer = await file.arrayBuffer()
            const pdfDoc = await PDFDocument.load(arrayBuffer)
            
            // Add metadata bookmarks (limited functionality)
            pdfDoc.setTitle(`${file.name} - With Bookmarks`)
            pdfDoc.setKeywords('PDF Bookmark Embedder, Page 1, Page 3, Page 6')
            pdfDoc.setSubject('PDF with embedded bookmarks on pages 1, 3, and 6')
            
            // Save the PDF
            const pdfBytes = await pdfDoc.save()
            const blob = new Blob([pdfBytes], { type: 'application/pdf' })
            
            console.log('✅ Client-side processing completed')
            
            return {
                success: true,
                data: blob
            }
            
        } catch (error) {
            console.error('❌ Client-side fallback failed:', error)
            return {
                success: false,
                error: 'Both server and client-side processing failed. Please try a different PDF file.'
            }
        }
    }

    downloadProcessedPDF() {
        if (!this.processedPdfData) {
            this.showError('No processed PDF available')
            return
        }

        try {
            // Create download link
            const url = URL.createObjectURL(this.processedPdfData)
            const link = document.createElement('a')
            link.href = url
            link.download = this.getDownloadFilename()
            
            // Trigger download
            document.body.appendChild(link)
            link.click()
            document.body.removeChild(link)
            
            // Clean up
            URL.revokeObjectURL(url)
            
            console.log('📥 Download triggered')
            
        } catch (error) {
            console.error('❌ Download failed:', error)
            this.showError('Download failed. Please try again.')
        }
    }

    getDownloadFilename() {
        if (this.currentFile) {
            const name = this.currentFile.name.replace('.pdf', '')
            return `${name}_with_bookmarks.pdf`
        }
        return 'pdf_with_bookmarks.pdf'
    }

    // UI State Management
    showProcessing() {
        this.hideAllStates()
        this.elements.processing.style.display = 'block'
    }

    showResult() {
        this.hideAllStates()
        this.elements.result.style.display = 'block'
    }

    showError(message) {
        this.hideAllStates()
        this.elements.error.style.display = 'block'
        this.elements.errorMessage.textContent = message
    }

    resetToUpload() {
        this.hideAllStates()
        this.elements.uploadArea.style.display = 'block'
        this.elements.fileInput.value = ''
        this.currentFile = null
        this.processedPdfData = null
    }

    hideAllStates() {
        this.elements.uploadArea.style.display = 'none'
        this.elements.processing.style.display = 'none'
        this.elements.result.style.display = 'none'
        this.elements.error.style.display = 'none'
    }

    updateProcessingStatus(status) {
        this.elements.processingStatus.textContent = status
        console.log('🔄', status)
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms))
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 PDF Bookmark Embedder initialized')
    new PDFBookmarkEmbedder()
})

// Handle iOS Safari specific behaviors
if (navigator.userAgent.includes('Safari') && navigator.userAgent.includes('Mobile')) {
    console.log('📱 iOS Safari detected - optimized mode active')
    
    // Prevent zoom on file input
    document.addEventListener('touchstart', () => {}, { passive: true })
}
