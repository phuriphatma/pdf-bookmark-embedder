import { defineConfig } from 'vite'

export default defineConfig({
    server: {
        port: 3000,
        host: '0.0.0.0', // Allow access from iOS devices on same network
        open: true,
        cors: true
    },
    build: {
        outDir: 'dist',
        sourcemap: true
    },
    optimizeDeps: {
        include: ['pdf-lib']
    }
})
