import {
  BugIcon,
  ClockIcon,
  MailIcon,
  MessageSquareIcon,
  SmartphoneIcon,
} from "lucide-react";
import type { Metadata } from "next";
import { LegalPageShell } from "@/components/legal/LegalPageShell";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { buildMetadata, SUPPORT_EMAIL, siteUrl } from "@/lib/seo";

export const metadata: Metadata = buildMetadata({
  title: "Contact",
  description:
    "Contact Proudly for support, feedback, subscription questions, and bug reports.",
  canonical: "/contact",
});

const COMMON_QUESTIONS = [
  {
    q: "Is Proudly free?",
    a: "Yes. Proudly can be used for free with up to 3 habits.",
  },
  {
    q: "What is Proudly Plus?",
    a: "Proudly Plus unlocks unlimited habits, custom themes, Proud Moments history, and advanced progress insights.",
  },
  {
    q: "How do I cancel my subscription?",
    a: "Subscriptions are managed by Apple. Open iPhone Settings, tap your Apple Account, then Subscriptions, then Proudly, then Cancel. Cancellation usually keeps access active until the end of the current billing period.",
  },
  {
    q: "How do I restore purchases?",
    a: "Open Proudly, go to the paywall or subscription area, and tap Restore Purchases.",
  },
  {
    q: "Does Proudly have iCloud sync?",
    a: "Yes, for Proudly Plus subscribers. iCloud sync is optional and can be enabled in Settings; your habit data is stored in your private iCloud account. Proudly continues to work locally when iCloud is unavailable.",
  },
  {
    q: "Does Proudly sell my data?",
    a: "No. Proudly does not sell personal data.",
  },
  {
    q: "Does Proudly send reminders?",
    a: "Yes, if reminders are enabled and notification permission is granted. You can change notification permission in iOS Settings → Notifications → Proudly.",
  },
  {
    q: "Why did my reminder not appear?",
    a: "Check that notifications are allowed for Proudly in iOS Settings, Focus modes are not blocking notifications, and the habit has reminders enabled.",
  },
  {
    q: "Can I track habits multiple times per day?",
    a: "Yes. Proudly supports habits that can be completed more than once per day.",
  },
  {
    q: "What happens if I cancel Proudly Plus?",
    a: "You usually keep Plus access until the end of the paid billing period. After it expires, Proudly returns to the free plan limits.",
  },
  {
    q: "Will I lose my habits if I cancel Plus?",
    a: "No. Your existing habit data stays on your device. If you have more than 3 habits, they are kept, but you may be limited from creating additional habits or using premium-only features until you re-subscribe.",
  },
  {
    q: "Is Proudly medical advice?",
    a: "No. Proudly is for personal habit tracking and motivation only. It is not a substitute for professional medical or mental health advice.",
  },
  {
    q: "How do I contact support?",
    a: `Email ${SUPPORT_EMAIL} and we'll do our best to help.`,
  },
];

const contactJsonLd = {
  "@context": "https://schema.org",
  "@type": "ContactPage",
  name: "Contact Proudly",
  url: `${siteUrl}/contact`,
  contactPoint: {
    "@type": "ContactPoint",
    contactType: "customer support",
    email: SUPPORT_EMAIL,
  },
};

function ContactCard({
  icon,
  title,
  children,
}: {
  icon: React.ReactNode;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="rounded-2xl bg-white/70 p-6 shadow-sm ring-1 ring-black/5 backdrop-blur-sm dark:bg-card dark:ring-white/10">
      <div className="mb-3 flex items-center gap-3">
        <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-violet-50 text-violet-500 dark:bg-violet-950/40">
          {icon}
        </div>
        <h3 className="font-semibold">{title}</h3>
      </div>
      {children}
    </div>
  );
}

function BulletList({ items }: { items: string[] }) {
  return (
    <ul className="mt-2 space-y-1.5 text-muted-foreground text-sm">
      {items.map((item) => (
        <li className="flex items-start gap-2" key={item}>
          <span className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary" />
          {item}
        </li>
      ))}
    </ul>
  );
}

export default function ContactPage() {
  return (
    <>
      <script
        // biome-ignore lint/security/noDangerouslySetInnerHtml: trusted static JSON-LD
        dangerouslySetInnerHTML={{ __html: JSON.stringify(contactJsonLd) }}
        type="application/ld+json"
      />
      <LegalPageShell
        intro="Need help with Proudly? Send a note and we'll do our best to help."
        title="Contact Proudly"
      >
        <section className="grid gap-4 sm:grid-cols-2">
          <ContactCard icon={<MailIcon className="size-5" />} title="Support">
            <p className="mb-3 text-muted-foreground text-sm">
              For app support, subscription questions, bug reports, or feedback.
            </p>
            <a
              className="inline-flex items-center gap-1.5 font-medium text-primary text-sm underline underline-offset-3 hover:text-primary/80"
              href={`mailto:${SUPPORT_EMAIL}`}
            >
              {SUPPORT_EMAIL}
            </a>
          </ContactCard>

          <ContactCard
            icon={<SmartphoneIcon className="size-5" />}
            title="Subscription Help"
          >
            <p className="mb-2 text-muted-foreground text-sm">
              Subscriptions are managed by Apple.
            </p>
            <BulletList
              items={[
                "Manage or cancel: iPhone Settings → Apple Account → Subscriptions → Proudly",
                "Or use Restore Purchases inside the Proudly app",
                "Still need help? Email us",
              ]}
            />
          </ContactCard>

          <ContactCard
            icon={<MessageSquareIcon className="size-5" />}
            title="Feedback"
          >
            <p className="text-muted-foreground text-sm">
              Have an idea to make Proudly gentler or more useful? We'd love to
              hear it. Email us at{" "}
              <a
                className="text-primary underline underline-offset-3 hover:text-primary/80"
                href={`mailto:${SUPPORT_EMAIL}`}
              >
                {SUPPORT_EMAIL}
              </a>
              .
            </p>
          </ContactCard>

          <ContactCard
            icon={<BugIcon className="size-5" />}
            title="Bug Reports"
          >
            <p className="mb-2 text-muted-foreground text-sm">
              Please include the following when reporting a bug:
            </p>
            <BulletList
              items={[
                "Device model",
                "iOS version",
                "What happened",
                "Steps to reproduce",
                "Screenshot if helpful",
              ]}
            />
          </ContactCard>
        </section>

        <div className="flex items-center gap-3 rounded-2xl bg-violet-50/60 px-5 py-4 dark:bg-violet-950/20">
          <ClockIcon className="size-4 shrink-0 text-violet-500" />
          <p className="text-muted-foreground text-sm">
            We try to respond as soon as possible, but response times may vary.
          </p>
        </div>

        <section id="common-questions">
          <h2 className="mb-1 font-bold text-2xl tracking-tight">
            Common Questions
          </h2>
          <p className="mb-8 text-muted-foreground">
            Quick answers to questions about Proudly.
          </p>

          <Accordion className="border-0">
            {COMMON_QUESTIONS.map(({ q, a }) => (
              <AccordionItem key={q} value={q}>
                <AccordionTrigger className="cursor-pointer text-left">
                  {q}
                </AccordionTrigger>
                <AccordionContent>
                  <p>{a}</p>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>

          <div className="mt-10 rounded-2xl bg-muted/40 px-6 py-5 text-center">
            <p className="text-muted-foreground text-sm">
              Still have a question?{" "}
              <a
                className="font-medium text-primary underline underline-offset-3 hover:text-primary/80"
                href={`mailto:${SUPPORT_EMAIL}`}
              >
                Email {SUPPORT_EMAIL}
              </a>
            </p>
          </div>
        </section>
      </LegalPageShell>
    </>
  );
}
