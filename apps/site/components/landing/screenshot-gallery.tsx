import { FadeIn, Stagger, StaggerItem } from "@/components/common/motion";

const PILLARS = [
  {
    title: "Gentle tracking",
    description:
      "No pressure, no punishment. Just simple daily check-ins that feel good.",
  },
  {
    title: "Daily reminders",
    description:
      "Nudge yourself kindly with local reminders you set and control.",
  },
  {
    title: "Proud moments",
    description:
      "Look back at everything you have already accomplished. Every win counts.",
  },
];

export function BeliefStrip() {
  return (
    <section className="border-y bg-muted/30 py-20">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mb-12 text-center">
          <h2 className="font-bold text-foreground text-lg sm:text-xl">
            Build habits without pressure
          </h2>
        </FadeIn>

        <Stagger className="grid gap-5 sm:grid-cols-3" staggerDelay={0.1}>
          {PILLARS.map((p) => (
            <StaggerItem key={p.title}>
              <div className="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-black/5 dark:bg-card dark:ring-white/10">
                <h3 className="mb-2 font-semibold">{p.title}</h3>
                <p className="text-muted-foreground text-sm leading-relaxed">
                  {p.description}
                </p>
              </div>
            </StaggerItem>
          ))}
        </Stagger>
      </div>
    </section>
  );
}
