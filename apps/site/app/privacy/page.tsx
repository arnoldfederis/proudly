import type { Metadata } from "next";
import Link from "next/link";
import { LegalPageShell } from "@/components/legal/LegalPageShell";
import { buildMetadata, SUPPORT_EMAIL } from "@/lib/seo";

export const metadata: Metadata = buildMetadata({
  title: "Privacy Policy",
  description:
    "Privacy Policy for Proudly, a gentle habit tracker for small wins.",
  canonical: "/privacy",
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

export default function PrivacyPage() {
  return (
    <LegalPageShell
      effectiveDate="Effective date: July 3, 2026"
      intro="This Privacy Policy explains how Proudly handles habit data, reminders, subscription status, and support requests."
      title="Privacy Policy"
    >
      <Section title="Information You Provide">
        <Body>
          When you use Proudly, you may create and store the following on your
          device:
        </Body>
        <BulletList
          items={[
            "Habit names, icons, and colors",
            "Daily habit completions and notes",
            "Streak history",
            "Reminder preferences and schedules",
            "App settings and theme preferences",
          ]}
        />
      </Section>

      <Section title="Information Collected Automatically">
        <Body>
          Proudly does not have its own analytics or advertising tracking
          system. However:
        </Body>
        <BulletList
          items={[
            "Apple may collect certain device and purchase information through the App Store according to Apple's privacy policy.",
            "Proudly uses RevenueCat to validate purchases, manage subscription status, and unlock Proudly Plus features.",
            "Subscription-related information, such as purchase status, product identifiers, entitlement status, and app user or device-related identifiers, may be processed to provide subscription features.",
            "Basic crash information may be reported to Apple depending on your iOS settings.",
          ]}
        />
      </Section>

      <Section title="How We Use Information">
        <Body>Information in Proudly is used to:</Body>
        <BulletList
          items={[
            "Show your habits and daily progress",
            "Save your preferences and settings",
            "Schedule local reminders",
            "Sync habit data across your Apple devices when iCloud sync is enabled",
            "Manage access to Proudly Plus features",
            "Restore purchases and validate active subscriptions",
            "Improve and maintain the app",
            "Respond to support requests",
          ]}
        />
      </Section>

      <Section title="Local Storage">
        <Body>
          By default, Proudly stores all habit data locally on your device. If
          you delete the app, your local habit data will be removed from your
          device.
        </Body>
      </Section>

      <Section title="iCloud Sync">
        <Body>
          Proudly Plus subscribers can enable optional iCloud sync to keep habit
          data consistent across their Apple devices. When iCloud sync is
          enabled, habit data is stored in the user's private iCloud account
          using Apple CloudKit and handled by Apple according to Apple's privacy
          policy. Proudly does not operate a custom server for habit sync and
          cannot access the contents of your private iCloud database. If iCloud
          is unavailable or the user is signed out, Proudly continues to work
          locally on the device.
        </Body>
      </Section>

      <Section title="Notifications">
        <Body>
          If you enable reminders, Proudly uses local iOS notifications.
          Notification content stays on your device and is never sent to a
          server. You can change notification permission at any time in iOS
          Settings.
        </Body>
      </Section>

      <Section title="Subscriptions">
        <Body>
          Proudly Plus subscriptions are processed by Apple through the App
          Store. Proudly uses RevenueCat to help validate purchases, manage
          subscription status, restore purchases, and unlock Proudly Plus
          features. RevenueCat may process subscription-related information such
          as purchase status, product identifiers, entitlement status, and app
          user or device-related identifiers needed to provide subscription
          access. Proudly does not directly receive your payment card details.
        </Body>
      </Section>

      <Section title="Support Requests">
        <Body>
          If you contact Proudly support, we may receive the information you
          choose to provide, such as your email address, message content, and
          details needed to help with your request. Support information is used
          only to respond to your request, troubleshoot issues, and provide
          customer support.
        </Body>
      </Section>

      <Section title="Data Sharing">
        <Body>
          Proudly does not sell your personal data. Information is only shared
          with services needed to operate the app, process subscriptions, manage
          Proudly Plus access through Apple and RevenueCat, respond to support
          requests, or comply with applicable law.
        </Body>
      </Section>

      <Section title="Data Deletion">
        <Body>
          You can delete individual habits inside the Proudly app. Deleting the
          app from your device removes all locally stored Proudly data. If
          iCloud sync is enabled, habit records also live in your private iCloud
          account; you can remove them by disabling iCloud sync in Settings,
          deleting the Proudly data from iCloud in iOS Settings, or signing out
          of iCloud on your device.
        </Body>
      </Section>

      <Section title="Changes to This Policy">
        <Body>
          This Privacy Policy may be updated from time to time. The effective
          date above will be updated when changes are made.
        </Body>
      </Section>

      <Section title="Contact">
        <Body>
          Questions about this Privacy Policy? Contact us at{" "}
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
            href="/terms"
          >
            View Proudly Terms of Use
          </Link>
          .
        </Body>
      </Section>
    </LegalPageShell>
  );
}
