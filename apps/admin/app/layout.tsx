import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'ReKamoso AgriMart Admin',
  description: 'Admin panel for ReKamoso AgriMart',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
