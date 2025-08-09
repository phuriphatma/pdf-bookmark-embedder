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
            this.pyodide = await loadPyodide({
                indexURL: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/"
            });
            
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
                import base64
                
                def add_bookmarks_to_pdf(pdf_base64):
                    """Add bookmarks to PDF and return the modified PDF as base64"""
                    try:
                        # Decode base64 to bytes
                        pdf_bytes = base64.b64decode(pdf_base64)
                        print(f"Processing PDF of {len(pdf_bytes)} bytes")
                        
                        # Open PDF from bytes
                        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
                        page_count = len(doc)
                        print(f"PDF has {page_count} pages")
                        
                        # Clear existing bookmarks
                        doc.set_toc([])
                        
                        # Create bookmark list
                        bookmarks = []
                        
                        # Add bookmark for page 1 if it exists
                        if page_count >= 1:
                            bookmarks.append([1, "Page 1", 1])
                            print("Added bookmark for page 1")
                        
                        # Add bookmark for page 2 if it exists
                        if page_count >= 2:
                            bookmarks.append([1, "Page 2", 2])
                            print("Added bookmark for page 2")
                        
                        # Add bookmark for page 5 if it exists
                        if page_count >= 5:
                            bookmarks.append([1, "Page 5", 5])
                            print("Added bookmark for page 5")
                        
                        # Set the bookmarks
                        if bookmarks:
                            doc.set_toc(bookmarks)
                            print(f"Set {len(bookmarks)} bookmarks")
                        else:
                            print("No bookmarks added (PDF may have fewer than 1 page)")
                        
                        # Save to bytes
                        output_buffer = io.BytesIO()
                        doc.save(output_buffer)
                        output_bytes = output_buffer.getvalue()
                        doc.close()
                        
                        # Convert back to base64 for transfer
                        output_base64 = base64.b64encode(output_bytes).decode('utf-8')
                        print(f"Generated output PDF of {len(output_bytes)} bytes")
                        return output_base64
                    except Exception as e:
                        import traceback
                        error_msg = f"Error processing PDF: {str(e)}"
                        print(error_msg)
                        print(traceback.format_exc())
                        return f"ERROR: {error_msg}"
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

    arrayBufferToBase64(uint8Array) {
        // Convert Uint8Array to base64 in chunks to avoid call stack overflow
        const chunkSize = 8192; // Process 8KB at a time
        let binary = '';
        
        for (let i = 0; i < uint8Array.length; i += chunkSize) {
            const chunk = uint8Array.slice(i, i + chunkSize);
            binary += String.fromCharCode.apply(null, chunk);
        }
        
        return btoa(binary);
    }

    base64ToUint8Array(base64String) {
        // Convert base64 back to Uint8Array safely
        const binaryString = atob(base64String);
        const bytes = new Uint8Array(binaryString.length);
        
        for (let i = 0; i < binaryString.length; i++) {
            bytes[i] = binaryString.charCodeAt(i);
        }
        
        return bytes;
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

        // Check if Pyodide is ready
        if (!this.pyodide) {
            this.showError('PDF processing environment not ready. Please wait for initialization to complete and try again.');
            return;
        }

        this.originalFileName = file.name;
        this.showStatus();
        
        try {
            this.updateStatus('Reading PDF file...', 20);
            const arrayBuffer = await file.arrayBuffer();
            const uint8Array = new Uint8Array(arrayBuffer);
            
            // Convert to base64 for reliable transfer to Python (chunked to avoid stack overflow)
            this.updateStatus('Converting PDF data...', 30);
            const base64String = this.arrayBufferToBase64(uint8Array);
            
            this.updateStatus('Processing PDF and adding bookmarks...', 50);
            
            // Pass the PDF to Python for processing
            this.pyodide.globals.set('pdf_base64_data', base64String);
            
            this.updateStatus('Adding bookmarks to pages 1, 2, and 5...', 70);
            
            const result = await this.pyodide.runPython(`
                result = add_bookmarks_to_pdf(pdf_base64_data)
                result
            `);

            if (typeof result === 'string' && result.startsWith('ERROR:')) {
                throw new Error(result.replace('ERROR: ', ''));
            }

            if (!result || result.length === 0) {
                throw new Error('No data returned from PDF processing');
            }

            this.updateStatus('Converting result...', 85);
            
            // Convert base64 back to binary for download using helper function
            const bytes = this.base64ToUint8Array(result);
            
            this.updateStatus('Finalizing...', 90);
            this.processedPdfData = bytes;
            
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
        console.log('Download requested, checking processed data...');
        console.log('processedPdfData exists:', !!this.processedPdfData);
        console.log('processedPdfData type:', typeof this.processedPdfData);
        
        if (!this.processedPdfData) {
            console.error('No processed PDF data available');
            this.showError('No processed PDF data available. Please process a PDF first.');
            return;
        }

        if (this.processedPdfData.length === 0) {
            console.error('Processed PDF data is empty');
            this.showError('Processed PDF data is empty. Please try processing the PDF again.');
            return;
        }

        try {
            console.log('Creating blob from processed data...');
            console.log('Data length:', this.processedPdfData.length);
            
            const blob = new Blob([this.processedPdfData], { type: 'application/pdf' });
            console.log('Blob created, size:', blob.size);
            
            if (blob.size === 0) {
                throw new Error('Generated PDF blob is empty');
            }
            
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            
            // Generate download filename
            const downloadName = this.originalFileName 
                ? this.originalFileName.replace('.pdf', '_with_bookmarks.pdf')
                : 'pdf_with_bookmarks.pdf';
            a.download = downloadName;
            
            console.log('Triggering download:', downloadName);
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            
            console.log('Download triggered successfully');
        } catch (error) {
            console.error('Error downloading PDF:', error);
            this.showError(`Error downloading the processed PDF: ${error.message}`);
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
