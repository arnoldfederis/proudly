import type { Metadata } from "next";
import { AppleStyleFeatureCarousel } from "@/components/landing/apple-style-feature-carousel";
import { FAQ } from "@/components/landing/faq";
import { FeatureShowcase } from "@/components/landing/feature-showcase";
import { FinalCTA } from "@/components/landing/final-cta";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";
import { Hero } from "@/components/landing/hero";
import { HowItWorks } from "@/components/landing/how-it-works";
import { ProudlyPlus } from "@/components/landing/proudly-plus";
import {
  APP_NAME,
  absoluteUrl,
  buildMetadata,
  HOME_FAQ_ITEMS,
  siteUrl,
  TAGLINE,
} from "@/lib/seo";

export const metadata: Metadata = buildMetadata({
  title: APP_NAME,
  description:
    "A gentle habit tracker for small wins. Track daily habits, build streaks, set reminders, and celebrate progress without pressure.",
  canonical: "/",
  openGraphTitle: "Proudly: Habit Tracker for Small Wins",
  openGraphDescription:
    "Build habits gently with Proudly, an iPhone habit tracker for daily routines, reminders, streaks, and small wins.",
  twitterDescription: TAGLINE,
});

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "SoftwareApplication",
      name: APP_NAME,
      alternateName: "Proudly",
      applicationCategory: "LifestyleApplication",
      operatingSystem: "iOS",
      description: TAGLINE,
      url: siteUrl,
      offers: {
        "@type": "Offer",
        price: "0",
        priceCurrency: "USD",
        description:
          "Free plan available with optional Proudly Plus subscription.",
      },
      featureList: [
        "Track daily habits",
        "Set local reminders",
        "Build streaks",
        "Track habits multiple times per day",
        "View Proud Moments history",
        "Customize themes with Proudly Plus",
      ],
    },
    {
      "@type": "Organization",
      name: "Proudly",
      url: siteUrl,
      logo: absoluteUrl("/proudly-icon-512x512.png"),
    },
    {
      "@type": "WebSite",
      name: "Proudly",
      url: siteUrl,
      description: TAGLINE,
    },
    {
      "@type": "FAQPage",
      mainEntity: HOME_FAQ_ITEMS.map((item) => ({
        "@type": "Question",
        name: item.question,
        acceptedAnswer: {
          "@type": "Answer",
          text: item.answer,
        },
      })),
    },
  ],
};

export default function Home() {
  return (
    <>
      <script
        // biome-ignore lint/security/noDangerouslySetInnerHtml: trusted static JSON-LD
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        type="application/ld+json"
      />
      <Header />
      <main>
        <Hero />
        <FeatureShowcase />
        <AppleStyleFeatureCarousel />
        <HowItWorks />
        <ProudlyPlus />
        <FAQ />
        <FinalCTA />
      </main>
      <Footer />
    </>
  );
}
