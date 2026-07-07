import fs from "node:fs";
import path from "node:path";
import { FadeIn } from "@/components/common/motion";
import { AppleStyleFeatureCarouselClient } from "@/components/landing/apple-style-feature-carousel-client";

type CarouselFeatureItem = {
  altName: string;
  eyebrow: string;
  heading: string;
  body: string;
  imageSrc: string;
  imageAlt: string;
};

const carouselItems: CarouselFeatureItem[] = [
  {
    altName: "Monthly History",
    eyebrow: "Full month view",
    heading: "See your whole month at a glance.",
    body: "A gentle monthly calendar shows the days you showed up, so your progress is easy to feel — not just count.",
    imageSrc: "/assets/device-14.png",
    imageAlt:
      "Proudly monthly history calendar showing completed days for a habit across the month",
  },
  {
    altName: "iCloud Sync",
    eyebrow: "Across your devices",
    heading: "Your habits, on every Apple device.",
    body: "Optional iCloud sync keeps habits, completions, and reminders consistent across your iPhone. Your data stays in your private iCloud account.",
    imageSrc: "/assets/device-15.png",
    imageAlt:
      "Proudly iCloud sync settings screen showing habits syncing across Apple devices",
  },
  {
    altName: "Proud Moments",
    eyebrow: "Completed wins",
    heading: "Look back at what you’ve already done.",
    body: "See the small wins you have completed and remember that progress is already happening.",
    imageSrc: "/assets/device-7.png",
    imageAlt:
      "Proudly Proud Moments screen showing completed habits and small wins history",
  },
  {
    altName: "Focus Timer",
    eyebrow: "Focus",
    heading: "Stay with one small win.",
    body: "Start a gentle countdown for timed habits like reading, studying, stretching, or watching a lesson.",
    imageSrc: "/assets/device-12.png",
    imageAlt:
      "Proudly Focus Timer screen showing a countdown for a timed habit",
  },
  {
    altName: "Siri Shortcuts",
    eyebrow: "Shortcuts",
    heading: "Start habits faster with Siri.",
    body: "Use quick actions to open Today, start a Focus Timer, or complete a habit with your voice.",
    imageSrc: "/assets/device-13.png",
    imageAlt:
      "Proudly shortcuts screen showing Siri actions for opening Today, starting Focus Timer, and completing habits",
  },
  {
    altName: "Themes",
    eyebrow: "Personal touch",
    heading: "Make Proudly feel like yours.",
    body: "Choose soft custom themes that make habit tracking feel calm, personal, and inviting.",
    imageSrc: "/assets/device-8.png",
    imageAlt: "Proudly theme picker screen showing soft custom app themes",
  },
  {
    altName: "Subscription status",
    eyebrow: "Plan status",
    heading: "Know what’s unlocked.",
    body: "See whether you’re on Proudly Free or Proudly Plus, restore purchases, and manage your subscription when you need to.",
    imageSrc: "/assets/device-9.png",
    imageAlt:
      "Proudly subscription status screen showing Proudly Free or Proudly Plus plan details",
  },
  {
    altName: "Gentle start",
    eyebrow: "Guided setup",
    heading: "Set up your first habit gently.",
    body: "Choose your first habit, set a daily goal, and enable gentle reminders as part of the setup flow.",
    imageSrc: "/assets/device-10.png",
    imageAlt:
      "Proudly onboarding flow showing first habit setup and notification permission",
  },
  {
    altName: "Proudly Plus",
    eyebrow: "Upgrade",
    heading: "Unlock more room to grow.",
    body: "Upgrade when you want unlimited habits, custom themes, Proud Moments history, and deeper progress insights.",
    imageSrc: "/assets/device-11.png",
    imageAlt:
      "Proudly Plus screen showing unlimited habits, custom themes, Proud Moments, and progress insights",
  },
  {
    altName: "",
    eyebrow: "",
    heading: "",
    body: "",
    imageSrc: "",
    imageAlt: "",
  },
];

function hasPublicAsset(imageSrc: string) {
  return fs.existsSync(path.join(process.cwd(), "public", imageSrc));
}

export function AppleStyleFeatureCarousel() {
  const items = carouselItems.map((item) => ({
    ...item,
    hasImage: hasPublicAsset(item.imageSrc),
  }));

  return (
    <section
      aria-labelledby="more-to-love-heading"
      className="overflow-hidden py-24"
    >
      <div className="mx-auto flex max-w-6xl flex-col gap-14 px-6 pb-8">
        <FadeIn className="mx-auto max-w-3xl text-center">
          <p className="font-bold text-[0.75rem] uppercase tracking-[0.28em]">
            <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
              More to love
            </span>
          </p>
          <h2
            className="mt-4 font-bold text-4xl text-[#241C2F] leading-[1.08] tracking-tight sm:text-5xl dark:text-white"
            id="more-to-love-heading"
          >
            Small features that help <br />
            <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
              you keep going
            </span>
            .
          </h2>
          <p className="mx-auto mt-5 max-w-2xl text-[#6F6478] text-base leading-relaxed sm:text-lg dark:text-white/72">
            Proudly brings your habits, progress, themes, subscription status,
            and proud moments together in one calm place.
          </p>
        </FadeIn>
      </div>

      <AppleStyleFeatureCarouselClient items={items} />
    </section>
  );
}
