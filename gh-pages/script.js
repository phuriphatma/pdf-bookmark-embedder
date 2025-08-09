class PDFBookmarkManager {
    constructor() {
        this.pyodide = null;
        this.processedPdfData = null;
        this.originalFileName = '';
        this.initializeElements();
        this.bindEvents();
        this.initializePyodide();
    }

    initializeElements() {
        this.uploadArea = document.getElementById('uploadArea');
        this.pdfInput = document.getElementById('pdfInput');
        this.statusSection = document.getElementById('statusSection');
        this.resultSection = document.getElementById('resultSection');
        this.errorSection = document.getElementById('errorSection');
        this.progressFill = document.getElementById('progressFill');
        this.progressText = document.getElementById('progressText');
        this.statusMessage = document.getElementById('statusMessage');
        this.downloadBtn = document.getElementById('downloadBtn');
        this.resetBtn = document.getElementById('resetBtn');
        this.errorResetBtn = document.getElementById('errorResetBtn');
        this.errorMessage = document.getElementById('errorMessage');
    }

    bindEvents() {
        // Upload area events
        this.uploadArea.addEventListener('click', () => this.pdfInput.click());
        this.uploadArea.addEventListener('dragover', this.handleDragOver.bind(this));
        this.uploadArea.addEventListener('dragleave', this.handleDragLeave.bind(this));
        this.uploadArea.addEventListener('drop', this.handleDrop.bind(this));
        
        // File input event
        this.pdfInput.addEventListener('change', this.handleFileSelect.bind(this));
        
        // Button events
        this.downloadBtn.addEventListener('click', this.downloadProcessedPDF.bind(this));
        this.resetBtn.addEventListener('click', this.reset.bind(this));
        this.errorResetBtn.addEventListener('click', this.reset.bind(this));
    }

    async initializePyodide() {
        try {
            this.updateStatus('Initializing Python environment...', 10);
            this.pyodide = await loadPyodide();
            
            this.updateStatus('Installing PyMuPDF...', 30);
            await this.pyodide.loadPackage(['micropip']);
            await this.pyodide.runPython(`
                import micropip
                await micropip.install('pymupdf')
            `);
            
            this.updateStatus('Setting up PDF processing...', 50);
            await this.pyodide.runPython(`
                import fitz
                import io
                import js
                from js import Uint8Array
                
                def add_bookmarks_to_pdf(pdf_bytes):
                    """Add bookmarks to PDF and return the modified PDF bytes"""
                    try:
                        # Open PDF from bytes
                        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
                        
                        # Clear existing bookmarks
                        doc.set_toc([])
                        
                        # Create bookmark list
                        bookmarks = []
                        
                        # Add bookmark for page 1 if it exists
                        if len(doc) >= 1:
                            bookmarks.append([1, "Page 1", 1])
                        
                        # Add bookmark for page 2 if it exists
                        if len(doc) >= 2:
                            bookmarks.append([1, "Page 2", 2])
                        
                        # Add bookmark for page 5 if it exists
                        if len(doc) >= 5:
                            bookmarks.append([1, "Page 5", 5])
                        
                        # Set the bookmarks
                        if bookmarks:
                            doc.set_toc(bookmarks)
                        
                        # Save to bytes
                        output_buffer = io.BytesIO()
                        doc.save(output_buffer)
                        output_bytes = output_buffer.getvalue()
                        doc.close()
                        
                        return output_bytes
                    except Exception as e:
                        raise Exception(f"Error processing PDF: {str(e)}")
            `);
            
            this.updateStatus('Ready to process PDFs!', 100);
            setTimeout(() => {
                this.hideStatus();
            }, 1000);
            
        } catch (error) {
            console.error('Failed to initialize Pyodide:', error);
            this.showError('Failed to initialize PDF processing environment. Please refresh the page and try again.');
        }
    }

    handleDragOver(e) {
        e.preventDefault();
        this.uploadArea.classList.add('dragover');
    }

    handleDragLeave(e) {
        e.preventDefault();
        this.uploadArea.classList.remove('dragover');
    }

    handleDrop(e) {
        e.preventDefault();
        this.uploadArea.classList.remove('dragover');
        
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            this.handleFile(files[0]);
        }
    }

    handleFileSelect(e) {
        const file = e.target.files[0];
        if (file) {
            this.handleFile(file);
        }
    }

    async handleFile(file) {
        // Validate file
        if (!file.type.includes('pdf')) {
            this.showError('Please select a valid PDF file.');
            return;
        }

        if (file.size > 50 * 1024 * 1024) { // 50MB limit
            this.showError('File size must be less than 50MB.');
            return;
        }

        this.originalFileName = file.name;
        this.showStatus();
        
        try {
            this.updateStatus('Reading PDF file...', 20);
            const arrayBuffer = await file.arrayBuffer();
            const uint8Array = new Uint8Array(arrayBuffer);
            
            this.updateStatus('Processing PDF and adding bookmarks...', 40);
            
            // Pass the PDF to Python for processing
            this.pyodide.globals.set('pdf_data', uint8Array);
            
            this.updateStatus('Adding bookmarks to pages 1, 2, and 5...', 70);
            
            const result = await this.pyodide.runPython(`
                try:
                    processed_pdf = add_bookmarks_to_pdf(pdf_data.to_py())
                    processed_pdf
                except Exception as e:
                    str(e)
            `);

            if (typeof result === 'string') {
                throw new Error(result);
            }

            this.updateStatus('Finalizing...', 90);
            this.processedPdfData = result;
            
            this.updateStatus('Complete!', 100);
            setTimeout(() => {
                this.showResult();
            }, 500);
            
        } catch (error) {
            console.error('Error processing PDF:', error);
            this.showError(`Error processing PDF: ${error.message}`);
        }
    }

    downloadProcessedPDF() {
        if (!this.processedPdfData) {
            this.showError('No processed PDF data available.');
            return;
        }

        try {
            const blob = new Blob([this.processedPdfData], { type: 'application/pdf' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = this.originalFileName.replace('.pdf', '_with_bookmarks.pdf');
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        } catch (error) {
            console.error('Error downloading PDF:', error);
            this.showError('Error downloading the processed PDF.');
        }
    }

    updateStatus(message, progress) {
        this.statusMessage.textContent = message;
        this.progressFill.style.width = `${progress}%`;
        this.progressText.textContent = `${progress}%`;
    }

    showStatus() {
        this.hideAllSections();
        this.statusSection.style.display = 'block';
    }

    showResult() {
        this.hideAllSections();
        this.resultSection.style.display = 'block';
    }

    showError(message) {
        this.hideAllSections();
        this.errorMessage.textContent = message;
        this.errorSection.style.display = 'block';
    }

    hideStatus() {
        this.statusSection.style.display = 'none';
    }

    hideAllSections() {
        this.statusSection.style.display = 'none';
        this.resultSection.style.display = 'none';
        this.errorSection.style.display = 'none';
    }

    reset() {
        this.hideAllSections();
        this.pdfInput.value = '';
        this.processedPdfData = null;
        this.originalFileName = '';
        this.updateStatus('Ready to process PDFs!', 0);
    }
}

// Initialize the application when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new PDFBookmarkManager();
});
