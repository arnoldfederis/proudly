import { AppStoreBadge } from "@/components/common/app-store-badge";
import { FadeIn } from "@/components/common/motion";

const BENEFITS = [
  "Unlimited habits",
  "Custom themes",
  "Proud Moments history",
  "Advanced progress insights",
];

function CheckIcon() {
  return (
    <svg
      aria-hidden="true"
      className="size-3.5 text-white"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <path
        d="M5 13l4 4L19 7"
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2.5}
      />
    </svg>
  );
}

export function ProudlyPlus() {
  return (
    <section className="py-24" id="plus">
      <div className="mx-auto max-w-4xl px-6">
        <FadeIn>
          <div className="rounded-3xl border border-black/5 bg-gradient-to-br from-violet-50 via-pink-50/60 to-sky-50 p-10 text-center shadow-[0_24px_80px_-32px_rgba(167,139,250,0.45)] md:p-14 dark:border-white/10 dark:bg-[linear-gradient(135deg,rgba(59,43,85,0.96),rgba(42,33,60,0.94)_45%,rgba(30,39,61,0.94))] dark:shadow-[0_24px_80px_-32px_rgba(0,0,0,0.6)]">
            <span className="mb-5 inline-block rounded-full bg-violet-100 px-4 py-1.5 font-semibold text-xs uppercase tracking-widest dark:bg-violet-400/15 dark:text-violet-100 dark:ring-1 dark:ring-violet-200/10">
              <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
                Proudly Plus
              </span>
            </span>

            <h2 className="mb-5 font-bold text-3xl tracking-tight sm:text-4xl">
              More room for your small wins.
            </h2>

            <p className="mx-auto mb-9 max-w-lg text-muted-foreground leading-relaxed dark:text-white/72">
              Proudly is free for up to 3 habits. Upgrade to Proudly Plus when
              you want unlimited habits, custom themes, Proud Moments history,
              and deeper progress insights.
            </p>

            <ul className="mx-auto mb-8 max-w-xs space-y-3 text-left">
              {BENEFITS.map((b) => (
                <li
                  className="flex items-center gap-3 rounded-2xl bg-white/55 px-4 py-3 backdrop-blur-sm dark:bg-white/6 dark:ring-1 dark:ring-white/8"
                  key={b}
                >
                  <span className="flex size-5 shrink-0 items-center justify-center rounded-full bg-violet-500 dark:bg-violet-400">
                    <CheckIcon />
                  </span>
                  <span className="font-medium text-sm">{b}</span>
                </li>
              ))}
            </ul>

            <p className="mb-7 text-muted-foreground text-sm dark:text-white/60">
              Monthly and yearly plans available.
            </p>

            <AppStoreBadge
              ariaLabel="Unlock Proudly Plus on the App Store"
              className="h-12"
            />
          </div>
        </FadeIn>
      </div>
    </section>
  );
}
