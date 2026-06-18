import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import { ThemeProvider } from "@/components/providers/theme";
import {
  APP_NAME,
  KEYWORDS,
  SITE_DESCRIPTION,
  SITE_NAME,
  siteUrl,
  TAGLINE,
} from "@/lib/seo";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

const organizationJsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      name: SITE_NAME,
      url: siteUrl,
      logo: `${siteUrl}/proudly-icon-512x512.png`,
    },
    {
      "@type": "WebSite",
      name: SITE_NAME,
      url: siteUrl,
      description: TAGLINE,
    },
  ],
};

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  applicationName: SITE_NAME,
  title: {
    default: APP_NAME,
    template: "%s | Proudly",
  },
  description: SITE_DESCRIPTION,
  keywords: KEYWORDS,
  authors: [{ name: "Proudly" }],
  creator: "Proudly",
  publisher: "Proudly",
  category: "Productivity",
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    siteName: SITE_NAME,
    title: APP_NAME,
    description: SITE_DESCRIPTION,
    url: siteUrl,
    images: [
      {
        url: "/opengraph-image",
        width: 1200,
        height: 630,
        alt: APP_NAME,
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: APP_NAME,
    description: TAGLINE,
    images: ["/twitter-image"],
  },
  icons: {
    icon: [
      { url: "/favicon.ico" },
      { url: "/favicon-16x16.png", sizes: "16x16", type: "image/png" },
      { url: "/favicon-32x32.png", sizes: "32x32", type: "image/png" },
      { url: "/favicon-48x48.png", sizes: "48x48", type: "image/png" },
    ],
    apple: [
      { url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
    ],
  },
  manifest: "/site.webmanifest",
};

export const viewport: Viewport = {
  themeColor: "#C7B8FF",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      className={`${inter.variable} h-full antialiased`}
      lang="en"
      suppressHydrationWarning
    >
      <body className="min-h-full bg-background text-foreground">
        <script
          // biome-ignore lint/security/noDangerouslySetInnerHtml: trusted static JSON-LD
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(organizationJsonLd),
          }}
          type="application/ld+json"
        />
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
