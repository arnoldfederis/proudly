import type { Metadata } from "next";
import Link from "next/link";
import { LegalPageShell } from "@/components/legal/LegalPageShell";
import { buildMetadata, SUPPORT_EMAIL } from "@/lib/seo";

export const metadata: Metadata = buildMetadata({
  title: "Terms of Use",
  description:
    "Terms of Use for Proudly, a gentle habit tracker for small wins.",
  canonical: "/terms",
});

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <h2 className="mb-3 font-semibold">{title}</h2>
      {children}
    </section>
  );
}

function Body({ children }: { children: React.ReactNode }) {
  return (
    <p className="text-muted-foreground text-sm leading-relaxed">{children}</p>
  );
}

function BulletList({ items }: { items: string[] }) {
  return (
    <ul className="mt-3 space-y-2 text-muted-foreground text-sm">
      {items.map((item) => (
        <li className="flex items-start gap-2" key={item}>
          <span className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary" />
          {item}
        </li>
      ))}
    </ul>
  );
}

export default function TermsPage() {
  return (
    <LegalPageShell
      effectiveDate="Effective date: June 19, 2026"
      intro="These Terms of Use explain how you may use Proudly, a gentle habit tracker for small wins."
      title="Terms of Use"
    >
      <Section title="About Proudly">
        <Body>
          Proudly is a gentle habit tracker that helps you create habits,
          complete daily actions, view your progress, set reminders, and
          celebrate streaks and Proud Moments. It is designed to support your
          personal goals in a calm, pressure-free way.
        </Body>
      </Section>

      <Section title="Not Medical Advice">
        <Body>
          Proudly is for personal habit tracking and motivation only. It is not
          medical advice, mental health advice, fitness advice, or any other
          kind of professional advice.
        </Body>
      </Section>

      <Section title="Your Responsibilities">
        <Body>When you use Proudly, you agree to:</Body>
        <BulletList
          items={[
            "Use the app for lawful purposes only",
            "Keep your device and Apple Account secure",
            "Not attempt to copy, reverse engineer, or interfere with the app",
            "Not misuse the app in ways that could harm others or Proudly",
          ]}
        />
      </Section>

      <Section title="Subscriptions and Proudly Plus">
        <Body>
          Proudly offers an optional paid subscription called Proudly Plus.
          Proudly Plus may include unlimited habits, custom themes, Proud
          Moments history, and advanced progress insights.
        </Body>
        <BulletList
          items={[
            "Subscriptions are purchased through the Apple App Store. Billing is handled by Apple.",
            "Your subscription renews automatically unless you cancel before the renewal date.",
            "To cancel: open iPhone Settings, tap your Apple Account, then Subscriptions, then Proudly.",
            "Pricing and available plans may vary by country and may change over time.",
            "Proudly uses RevenueCat to help manage subscription status and unlock Proudly Plus features.",
            "You can restore purchases in the app if your active subscription is not recognized.",
            "If Apple provides a billing grace period after a failed renewal payment, you may continue to access Proudly Plus during that grace period while Apple attempts to recover the payment.",
          ]}
        />
      </Section>

      <Section title="Free Plan">
        <Body>
          Proudly can be used for free with up to 3 habits. Free features may
          change over time.
        </Body>
      </Section>

      <Section title="Reminders and Notifications">
        <Body>
          Proudly can send local reminders to help you remember your habits.
          Reminders are only delivered if you grant notification permission.
        </Body>
      </Section>

      <Section title="App Changes">
        <Body>
          Proudly may change over time. Features may be added, updated, or
          removed.
        </Body>
      </Section>

      <Section title="Limitation of Liability">
        <Body>
          Proudly is provided as-is. To the extent allowed by law, the developer
          of Proudly is not responsible for any loss, damage, missed reminders,
          data loss, or issues with subscriptions handled by Apple that may
          result from using Proudly.
        </Body>
      </Section>

      <Section title="Contact">
        <Body>
          Questions about these Terms? Contact us at{" "}
          <Link
            className="text-primary underline underline-offset-3 hover:text-primary/80"
            href={`mailto:${SUPPORT_EMAIL}`}
          >
            {SUPPORT_EMAIL}
          </Link>
          .
        </Body>
        <Body>
          You can also{" "}
          <Link
            className="text-primary underline underline-offset-3 hover:text-primary/80"
            href="/privacy"
          >
            read the Proudly Privacy Policy
          </Link>{" "}
          or{" "}
          <Link
            className="text-primary underline underline-offset-3 hover:text-primary/80"
            href="/contact"
          >
            contact Proudly support
          </Link>
          .
        </Body>
      </Section>
    </LegalPageShell>
  );
}
