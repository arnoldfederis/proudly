import Image from "next/image";
import { FadeIn } from "@/components/common/motion";

// TODO: Replace with App Store URL when available
const APP_STORE_URL = "#";

export function FinalCTA() {
  return (
    <section className="border-t py-28">
      <FadeIn className="mx-auto max-w-2xl px-6 text-center">
        <h2 className="mb-8 font-bold text-4xl leading-[1.1] tracking-tight sm:text-5xl">
          Do one thing today
          <br />
          that makes you proud.
        </h2>

        <a
          aria-label="Download Proudly on the App Store"
          className="inline-block shrink-0 rounded-[0.875rem] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
          href={APP_STORE_URL}
        >
          <Image
            alt="Download on the App Store"
            className="h-14 w-auto"
            height={40}
            src="/store-badges/black.svg"
            width={120}
          />
        </a>

        <p className="mt-5 text-muted-foreground text-sm">
          Start free. Upgrade when you're ready.
        </p>
      </FadeIn>
    </section>
  );
}
