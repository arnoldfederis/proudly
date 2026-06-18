import { ArrowLeftIcon } from "lucide-react";
import { Footer } from "@/components/landing/footer";
import { Header } from "@/components/landing/header";

export function LegalPageShell({
  title,
  intro,
  effectiveDate,
  children,
}: {
  title: string;
  intro?: string;
  effectiveDate?: string;
  children: React.ReactNode;
}) {
  return (
    <>
      <Header />
      <main>
        <div className="mx-auto max-w-[760px] px-6 py-16">
          <a
            className="mb-10 inline-flex items-center gap-1.5 text-muted-foreground text-sm transition-colors hover:text-primary"
            href="/"
          >
            <ArrowLeftIcon className="size-3.5" />
            Back to home
          </a>

          <header className="mb-2">
            <h1 className="font-bold text-3xl tracking-tight">{title}</h1>
            {effectiveDate && (
              <p className="mt-3 text-muted-foreground text-sm">
                {effectiveDate}
              </p>
            )}
          </header>

          {intro && (
            <p className="mt-5 text-muted-foreground leading-relaxed">
              {intro}
            </p>
          )}

          <div className="mt-10 space-y-10 border-t pt-10">{children}</div>
        </div>
      </main>
      <Footer />
    </>
  );
}
