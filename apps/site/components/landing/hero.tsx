import Image from "next/image";
import { FadeIn } from "@/components/common/motion";
import { PhoneMockup } from "@/components/common/phone-mockup";
import { deviceBlurDataURL } from "@/lib/image-placeholders";

// TODO: Replace with App Store URL when available
const APP_STORE_URL = "#";

export function Hero() {
  return (
    <section className="overflow-hidden pt-24 pb-0">
      <div className="mx-auto max-w-4xl px-6 text-center">
        <FadeIn>
          <h1 className="font-bold text-5xl leading-[1.07] tracking-tight sm:text-6xl lg:text-7xl">
            Do one thing today that makes you
            <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
              {" "}
              proud
            </span>
            .
          </h1>
        </FadeIn>

        <FadeIn delay={0.1}>
          <p className="mx-auto mt-6 max-w-lg text-lg text-muted-foreground leading-relaxed">
            Proudly is a gentle habit tracker for small wins. Track daily
            habits, build streaks, set reminders, and celebrate progress without
            pressure.
          </p>
        </FadeIn>

        <FadeIn delay={0.2}>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <a
              aria-label="Download Proudly on the App Store"
              className="inline-block shrink-0 rounded-[0.875rem] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
              href={APP_STORE_URL}
            >
              <Image
                alt="Download on the App Store"
                className="h-12 w-auto"
                height={40}
                priority
                src="/store-badges/black.svg"
                width={120}
              />
            </a>
            <a
              className="font-medium text-muted-foreground text-sm underline-offset-4 transition-colors hover:text-foreground hover:underline"
              href="#how-it-works"
            >
              See how it works
            </a>
          </div>
          <p className="mt-4 text-muted-foreground text-xs">
            Start free with up to 3 habits.
          </p>
        </FadeIn>
      </div>

      <FadeIn
        className="relative mt-16 flex justify-center px-6 pb-0"
        delay={0.3}
      >
        <div className="pointer-events-none absolute top-1/2 left-1/2 size-80 -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/15 blur-3xl" />
        <PhoneMockup className="relative">
          <Image
            alt="Do one thing today that makes you proud"
            blurDataURL={deviceBlurDataURL}
            className="h-auto w-65 sm:w-75"
            height={2796}
            placeholder="blur"
            priority
            quality={85}
            sizes="(max-width: 640px) 260px, 300px"
            src="/assets/device-1.png"
            width={1419}
          />
        </PhoneMockup>
      </FadeIn>
    </section>
  );
}
