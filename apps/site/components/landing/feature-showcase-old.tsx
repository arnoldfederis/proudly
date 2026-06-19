import { FadeIn, Stagger, StaggerItem } from "@/components/common/motion";

const FEATURES = [
  {
    id: "track",
    title: "Track daily habits",
    description: "Create simple habits and check them off throughout the day.",
    accent: "bg-violet-100 text-violet-600",
    icon: (
      <svg
        aria-hidden="true"
        className="size-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={1.75}
        />
      </svg>
    ),
  },
  {
    id: "flexible",
    title: "Flexible daily goals",
    description:
      "Track once-a-day habits or multiple small completions per day.",
    accent: "bg-sky-100 text-sky-600",
    icon: (
      <svg
        aria-hidden="true"
        className="size-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={1.75}
        />
      </svg>
    ),
  },
  {
    id: "streaks",
    title: "Streaks without pressure",
    description: "See current and best streaks without guilt or harsh resets.",
    accent: "bg-orange-100 text-orange-500",
    icon: (
      <svg
        aria-hidden="true"
        className="size-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={1.75}
        />
        <path
          d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={1.75}
        />
      </svg>
    ),
  },
  {
    id: "moments",
    title: "Proud Moments",
    description:
      "Look back at the wins you have already completed. Celebrate every one.",
    accent: "bg-pink-100 text-pink-500",
    icon: (
      <svg
        aria-hidden="true"
        className="size-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={1.75}
        />
      </svg>
    ),
  },
  {
    id: "reminders",
    title: "Gentle reminders",
    description:
      "Set local reminders that nudge you kindly at the right moment.",
    accent: "bg-emerald-100 text-emerald-600",
    icon: (
      <svg
        aria-hidden="true"
        className="size-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={1.75}
        />
      </svg>
    ),
  },
  {
    id: "themes",
    title: "Custom themes",
    description:
      "Personalize Proudly with soft, polished themes that feel like yours.",
    accent: "bg-purple-100 text-purple-600",
    icon: (
      <svg
        aria-hidden="true"
        className="size-5"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={1.75}
        />
      </svg>
    ),
  },
];

export function FeatureShowcase() {
  return (
    <section className="py-24" id="features">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mb-14 text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Track daily habits your way
          </h2>
        </FadeIn>

        <Stagger
          className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3"
          staggerDelay={0.07}
        >
          {FEATURES.map((f) => (
            <StaggerItem key={f.id}>
              <div className="flex flex-col gap-4 rounded-2xl bg-white p-6 shadow-sm ring-1 ring-black/5 dark:bg-card dark:ring-white/10">
                <div
                  className={`flex size-10 items-center justify-center rounded-xl ${f.accent}`}
                >
                  {f.icon}
                </div>
                <div>
                  <h3 className="mb-1.5 font-semibold">{f.title}</h3>
                  <p className="text-muted-foreground text-sm leading-relaxed">
                    {f.description}
                  </p>
                </div>
              </div>
            </StaggerItem>
          ))}
        </Stagger>
      </div>
    </section>
  );
}
