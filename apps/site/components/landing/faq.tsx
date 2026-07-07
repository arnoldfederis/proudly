import { FadeIn } from "@/components/common/motion";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

const FAQS = [
  {
    q: "Is Proudly free?",
    a: "Yes. You can use Proudly for free with up to 3 habits.",
  },
  {
    q: "What does Proudly Plus include?",
    a: "Unlimited habits, custom themes, Proud Moments history, and deeper progress insights.",
  },
  {
    q: "Does Proudly use guilt or streak pressure?",
    a: "No. Proudly is designed to feel gentle, encouraging, and supportive.",
  },
  {
    q: "Are reminders available?",
    a: "Yes. Proudly supports local daily reminders.",
  },
  {
    q: "Is iCloud sync included?",
    a: "Yes. Proudly Plus subscribers can enable optional iCloud sync to keep habits consistent across their Apple devices. Sync uses Apple iCloud/CloudKit; Proudly still works locally when iCloud is unavailable.",
  },
];

export function FAQ() {
  return (
    <section className="border-t bg-muted/30 py-24" id="faq">
      <div className="mx-auto max-w-3xl">
        <FadeIn className="mb-14 px-6 text-center">
          <h2 className="font-bold text-3xl tracking-tight sm:text-4xl">
            Common questions
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            Quick answers about Proudly.
          </p>
        </FadeIn>

        <FadeIn delay={0.2}>
          <Accordion className="border-0 px-2 md:px-0">
            {FAQS.map(({ q, a }) => (
              <AccordionItem key={q} value={q}>
                <AccordionTrigger className="cursor-pointer">
                  {q}
                </AccordionTrigger>
                <AccordionContent>
                  <p>{a}</p>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </FadeIn>
      </div>
    </section>
  );
}
