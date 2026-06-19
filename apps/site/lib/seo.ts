import type { Metadata } from "next";

export const siteUrl =
  process.env.NEXT_PUBLIC_SITE_URL ?? "https://proudlyhabit.com";

export const SITE_NAME = "Proudly";
export const APP_NAME = "Proudly: Habit Tracker";
export const TAGLINE = "A gentle habit tracker for small wins.";
export const EMOTIONAL_HOOK = "Do one thing today that makes you proud.";
export const SITE_DESCRIPTION =
  "Proudly is a gentle habit tracker for small wins. Track daily habits, celebrate progress, and build routines without pressure.";

// TODO: Replace support email if the final address changes.
export const SUPPORT_EMAIL = "support@proudlyhabit.com";

// TODO: Replace with final App Store URL before launch.
export const APP_STORE_URL = "https://apps.apple.com/app/id6782197891";

export const KEYWORDS = [
  "habit tracker app",
  "gentle habit tracker",
  "iPhone habit tracker",
  "daily habit tracker",
  "habit tracker for small wins",
  "simple habit tracker",
  "streak tracker",
  "daily reminders habit app",
  "habit tracker without pressure",
  "habit tracker with reminders",
  "habit tracker for iOS",
  "Proudly habit tracker",
  "build better habits",
  "track daily habits",
  "small wins app",
  "habit progress tracker",
  "personal habit tracker",
  "habit reminder app",
  "daily routine tracker",
  "goal tracker app",
  "self improvement app",
  "productivity app without pressure",
  "streaks without guilt",
  "mindful habit tracker",
];

export const SITE_PATHS = ["/", "/privacy", "/terms", "/contact"] as const;

export const FOOTER_LINKS = [
  { href: "/", label: "Home" },
  { href: "/contact", label: "Contact" },
  { href: "/privacy", label: "Privacy Policy" },
  { href: "/terms", label: "Terms of Use" },
] as const;

export const FAQ_ITEMS = [
  {
    question: "What is Proudly?",
    answer:
      "Proudly is a gentle habit tracker for small wins. It helps you track daily habits, build streaks, set reminders, and celebrate progress without pressure.",
  },
  {
    question: "Is Proudly free?",
    answer: "Yes. Proudly can be used for free with up to 3 habits.",
  },
  {
    question: "What is Proudly Plus?",
    answer:
      "Proudly Plus unlocks unlimited habits, custom themes, Proud Moments history, and advanced progress insights.",
  },
  {
    question: "Can I track habits multiple times per day?",
    answer:
      "Yes. Proudly supports habits that can be completed more than once per day, such as drinking water four times a day.",
  },
  {
    question: "Does Proudly support reminders?",
    answer:
      "Yes. Proudly supports local daily reminders if notification permission is enabled.",
  },
  {
    question: "Does Proudly have iCloud sync?",
    answer:
      "Not in v1. Proudly stores habit data locally on the device. iCloud sync is planned for a future update.",
  },
  {
    question: "How do I cancel Proudly Plus?",
    answer:
      "Proudly Plus subscriptions are managed by Apple. Open iPhone Settings, tap your Apple Account, then Subscriptions, then Proudly, then cancel.",
  },
  {
    question: "Will I lose my habits if I cancel Proudly Plus?",
    answer:
      "Your habit data should not be deleted just because Plus expires. After Plus expires, the app returns to free plan limits.",
  },
  {
    question: "Does Proudly sell my data?",
    answer: "No. Proudly does not sell personal data.",
  },
  {
    question: "Is Proudly medical advice?",
    answer:
      "No. Proudly is for personal habit tracking and motivation only. It is not medical, mental health, fitness, or professional advice.",
  },
  {
    question: "How do I contact Proudly support?",
    answer: `You can contact Proudly support by emailing ${SUPPORT_EMAIL}.`,
  },
] as const;

export const HOME_FAQ_ITEMS = FAQ_ITEMS.slice(0, 6);

export function absoluteUrl(path = "/") {
  return new URL(path, siteUrl).toString();
}

export function buildMetadata({
  title,
  description,
  canonical,
  openGraphTitle,
  openGraphDescription,
  twitterDescription,
}: {
  title: string;
  description: string;
  canonical: string;
  openGraphTitle?: string;
  openGraphDescription?: string;
  twitterDescription?: string;
}): Metadata {
  return {
    title,
    description,
    keywords: KEYWORDS,
    alternates: {
      canonical,
    },
    openGraph: {
      title: openGraphTitle ?? title,
      description: openGraphDescription ?? description,
      url: canonical,
      type: "website",
      siteName: SITE_NAME,
      images: [
        {
          url: "/opengraph-image",
          width: 1200,
          height: 630,
          alt: "Proudly: Habit Tracker",
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: openGraphTitle ?? title,
      description: twitterDescription ?? openGraphDescription ?? description,
      images: ["/twitter-image"],
    },
  };
}

export function createFaqPageJsonLd(
  items: ReadonlyArray<{ question: string; answer: string }>,
) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: items.map(({ question, answer }) => ({
      "@type": "Question",
      name: question,
      acceptedAnswer: {
        "@type": "Answer",
        text: answer,
      },
    })),
  };
}
