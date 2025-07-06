import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Dydat",
  description: "L'ecosistema di apprendimento intelligente",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="it">
      <body>{children}</body>
    </html>
  );
} 