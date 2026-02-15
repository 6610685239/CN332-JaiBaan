import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // บอกว่าถ้าเจอ /api ให้ส่งไปที่ Backend (Port 3000)
      '/api': {
        target: 'https://musical-meme-7qwgvr7q6wqh7qr-3000.app.github.dev/',
        changeOrigin: true,
        secure: false,
      },
    },
  },
})