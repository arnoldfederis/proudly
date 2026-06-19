import { AppStoreBadge } from "@/components/common/app-store-badge";
import { FadeIn } from "@/components/common/motion";

// TODO: Replace with App Store URL when available
const _APP_STORE_URL = "#";

export function FinalCTA() {
  return (
    <section className="border-t py-28">
      <FadeIn className="mx-auto max-w-2xl px-6 text-center">
        <h2 className="mt-5 mb-6 text-balance font-bold text-4xl text-[#241C2F] tracking-tight sm:text-5xl lg:text-6xl dark:text-white">
          A gentle habit tracker for{" "}
          <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
            small wins
          </span>
          .
        </h2>

        <AppStoreBadge className="h-14" />

        <p className="mt-5 text-muted-foreground text-sm">
          Start free. Upgrade when you're ready.
        </p>
      </FadeIn>
    </section>
  );
}
