import { resolve } from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    outDir: resolve(__dirname, '../lib/js'),
    emptyOutDir: true,
    lib: {
      entry: resolve(__dirname, 'src/connect_to_host.ts'),
      formats: ['es'],
      fileName: 'connect_to_host',
    },
  },
});
