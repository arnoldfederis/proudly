import { FadeIn } from "@/components/common/motion";
import { PhoneMockup } from "@/components/common/phone-mockup";
import { ProgressiveImage } from "@/components/common/progressive-image";
import { deviceBlurDataURL } from "@/lib/image-placeholders";

const SHOWCASES = [
  {
    id: "habit",
    eyebrow: "Gentle progress",
    headline: "See progress without pressure.",
    body: "View current streaks, best streaks, and recent completions in a way that feels calm, encouraging, and easy to return to.",
    phoneFirst: false,
    muted: false,
    src: "/assets/device-2.png",
    alt: "Proudly habit progress screen showing streaks and recent completions",
  },
  {
    id: "flexible",
    eyebrow: "Flexible habits",
    headline: "Build habits your way.",
    body: "Track simple once-a-day habits or goals you complete multiple times a day, from reading a few pages to drinking more water.",
    phoneFirst: true,
    muted: true,
    src: "/assets/device-3.png",
    alt: "Proudly habit setup screen for creating a flexible daily habit",
  },
  {
    id: "kind",
    eyebrow: "Kind reminders",
    headline: "Gentle reminders for your routine.",
    body: "Set soft local reminders that help you check in at the right time without pressure, noise, or guilt.",
    phoneFirst: false,
    muted: false,
    src: "/assets/device-4.png",
    alt: "Proudly reminder settings screen for gentle habit reminders",
  },
  {
    id: "plus",
    eyebrow: "Proudly Plus",
    headline: "More room for your small wins.",
    body: "Unlock unlimited habits, custom themes, Proud Moments history, and deeper progress insights when you are ready to grow.",
    phoneFirst: true,
    muted: true,
    src: "/assets/device-5.png",
    alt: "Proudly Plus screen showing premium habit tracking features",
  },
];

export function FeatureShowcase() {
  return (
    <>
      {SHOWCASES.map((s) => (
        <section
          className={`py-24 ${s.muted ? "border-y bg-muted/40" : ""}`}
          id={s.id}
          key={s.id}
        >
          <div className="mx-auto max-w-6xl px-6">
            <div
              className={`flex flex-col items-center gap-16 md:gap-20 ${
                s.phoneFirst ? "md:flex-row-reverse" : "md:flex-row"
              }`}
            >
              {/* Text */}
              <FadeIn className="flex-1">
                <p className="mb-3 font-medium text-primary text-sm uppercase tracking-widest">
                  <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
                    {s.eyebrow}
                  </span>
                </p>
                <h2 className="font-bold text-4xl leading-[1.1] tracking-tight sm:text-5xl">
                  {s.headline}
                </h2>
                <p className="mt-5 max-w-md text-muted-foreground leading-relaxed">
                  {s.body}
                </p>
              </FadeIn>

              {/* Phone */}
              <div className="flex flex-1 justify-center">
                <div className="relative">
                  <div className="pointer-events-none absolute top-1/2 left-1/2 size-72 -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/10 blur-3xl" />
                  <PhoneMockup className="relative">
                    <ProgressiveImage
                      alt={s.alt}
                      blurDataURL={deviceBlurDataURL}
                      className="h-auto w-65 sm:w-75"
                      height={2796}
                      placeholder="blur"
                      quality={85}
                      sizes="(max-width: 640px) 260px, 300px"
                      src={s.src}
                      width={1419}
                    />
                  </PhoneMockup>
                </div>
              </div>
            </div>
          </div>
        </section>
      ))}
    </>
  );
}
