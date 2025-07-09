import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { ThemeProvider } from '../components/theme-provider';

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export const metadata: Metadata = {
  title: 'Dydat - Piattaforma di Apprendimento',
  description: 'Dydat - La piattaforma di apprendimento che unisce AI, gamification e strumenti innovativi per trasformare il modo in cui studi e cresci professionalmente.',
  keywords: ['apprendimento', 'corsi online', 'tutoring', 'AI', 'gamification', 'formazione'],
  authors: [{ name: 'Dydat Team' }],
  creator: 'Dydat',
  publisher: 'Dydat',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL('https://dydat.com'),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    title: 'Dydat - Piattaforma di Apprendimento',
    description: 'La piattaforma di apprendimento che unisce AI, gamification e strumenti innovativi.',
    url: 'https://dydat.com',
    siteName: 'Dydat',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Dydat - Piattaforma di Apprendimento',
      },
    ],
    locale: 'it_IT',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Dydat - Piattaforma di Apprendimento',
    description: 'La piattaforma di apprendimento che unisce AI, gamification e strumenti innovativi.',
    images: ['/og-image.jpg'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="it" suppressHydrationWarning>
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <link rel="manifest" href="/manifest.json" />
        <meta name="theme-color" content="#F59E0B" />
        <meta name="color-scheme" content="light dark" />
      </head>
      <body 
        className={`${inter.variable} font-sans antialiased bg-stone-50 dark:bg-stone-900 transition-colors duration-300`}
        suppressHydrationWarning
      >
        <ThemeProvider>
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
} 