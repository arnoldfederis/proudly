import { FadeIn, Stagger, StaggerItem } from "@/components/common/motion";

const STEPS = [
  {
    step: "1",
    title: "Choose one small habit",
    description: "Start with something simple and realistic.",
  },
  {
    step: "2",
    title: "Complete it today",
    description: "Track your progress with a calm, satisfying check-in.",
  },
  {
    step: "3",
    title: "Feel proud and keep going",
    description: "Build momentum one small win at a time.",
  },
];

export function HowItWorks() {
  return (
    <section className="bg-muted/30 py-24" id="how-it-works">
      <div className="mx-auto max-w-6xl px-6">
        <FadeIn className="mx-auto mb-14 max-w-xl text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            How it works.
          </h2>
        </FadeIn>

        <Stagger
          className="mx-auto grid max-w-3xl gap-10 sm:grid-cols-3"
          staggerDelay={0.1}
        >
          {STEPS.map((s) => (
            <StaggerItem key={s.step}>
              <div className="flex flex-col gap-3">
                <span className="font-bold text-4xl text-primary/20 tabular-nums leading-none">
                  {s.step}
                </span>
                <h3 className="font-semibold">{s.title}</h3>
                <p className="text-muted-foreground text-sm leading-relaxed">
                  {s.description}
                </p>
              </div>
            </StaggerItem>
          ))}
        </Stagger>
      </div>
    </section>
  );
}
