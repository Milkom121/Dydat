import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Providers } from '@/components/providers';

const inter = Inter({ 
  subsets: ["latin"],
  display: 'swap',
  variable: '--font-inter',
});

export const metadata: Metadata = {
  title: "Dydat - L'ecosistema di apprendimento intelligente",
  description: "Piattaforma educativa con gamification e AI per studenti e creator",
  keywords: ["education", "learning", "AI", "gamification", "courses", "dydat"],
  authors: [{ name: "Dydat Team" }],
  viewport: "width=device-width, initial-scale=1",
  themeColor: "#0066CC",
  robots: "index, follow",
  openGraph: {
    title: "Dydat - L'ecosistema di apprendimento intelligente",
    description: "Piattaforma educativa con gamification e AI per studenti e creator",
    type: "website",
    locale: "it_IT",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="it" className={inter.variable}>
      <body className="font-sans antialiased">
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  );
} 