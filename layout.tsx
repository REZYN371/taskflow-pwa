import type { Metadata, Viewport } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'TaskFlow — Rencanakan dengan lebih tenang',
  description: 'Jadwal, prioritas, dan tugas dalam satu ruang produktivitas pintar.',
  applicationName: 'TaskFlow',
  manifest: '/manifest.json',
  appleWebApp: { capable: true, statusBarStyle: 'default', title: 'TaskFlow' },
  icons: { icon: '/icon.svg', apple: '/icon.svg' },
};
export const viewport: Viewport = { themeColor: '#f5f7f4', width: 'device-width', initialScale: 1 };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="id"><body>{children}<script dangerouslySetInnerHTML={{__html:`if ('serviceWorker' in navigator && location.protocol.startsWith('http')) { window.addEventListener('load', () => navigator.serviceWorker.register('/sw.js').catch(() => {})); }`}} /></body></html>;
}
