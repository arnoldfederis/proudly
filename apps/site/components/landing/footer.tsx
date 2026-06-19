"use client";

import { usePathname } from "next/navigation";
import { ProgressiveImage } from "@/components/common/progressive-image";
import {
  GitHubIcon,
  LinkedInIcon,
  ThreadsIcon,
  XIcon,
} from "@/components/common/social-icons";
import { iconBlurDataURL } from "@/lib/image-placeholders";
import { cn } from "@/lib/utils";

const SOCIAL_LINKS = [
  {
    href: "https://x.com/arnoldfederis",
    label: "Follow Arnolfo Federis on X",
    Icon: XIcon,
  },
  {
    href: "https://linkedin.com/in/arnoldfederis",
    label: "Connect with Arnolfo Federis on LinkedIn",
    Icon: LinkedInIcon,
  },
  {
    href: "https://github.com/arnoldfederis",
    label: "View Arnolfo Federis on GitHub",
    Icon: GitHubIcon,
  },
  {
    href: "https://threads.com/arnoldfederis",
    label: "Follow Arnolfo Federis on Threads",
    Icon: ThreadsIcon,
  },
] as const;

const LINKS = [
  { label: "Contact", href: "/contact" },
  { label: "Privacy Policy", href: "/privacy" },
  { label: "Terms of Use", href: "/terms" },
];

export function Footer() {
  const path = usePathname();

  return (
    <footer className="border-t py-10">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-6 px-6 sm:flex-row sm:justify-between">
        <div className="flex flex-col items-center gap-2 sm:items-start">
          <a
            className="flex items-center gap-2 font-bold text-sm tracking-tight"
            href="/"
          >
            <ProgressiveImage
              alt="Proudly app icon"
              blurDataURL={iconBlurDataURL}
              className="size-7 rounded-lg"
              height={128}
              placeholder="blur"
              src="/proudly-icon-128x128.png"
              width={128}
            />
            Proudly
          </a>

          <nav className="flex flex-wrap justify-center gap-6">
            {LINKS.map((link) => (
              <a
                className={cn(
                  "text-muted-foreground text-sm transition-colors hover:text-primary",
                  {
                    "text-primary": path === link.href,
                  },
                )}
                href={link.href}
                key={link.href}
              >
                {link.label}
              </a>
            ))}
          </nav>
        </div>

        <div className="flex flex-col items-center gap-2 sm:items-end">
          <p className="text-muted-foreground text-xs">
            © {new Date().getFullYear()} Proudly. All rights reserved.
          </p>
          <div className="flex items-center gap-3">
            {SOCIAL_LINKS.map(({ href, label, Icon }) => (
              <a
                aria-label={label}
                className="text-muted-foreground transition-colors hover:text-primary"
                href={href}
                key={href}
                rel="noopener noreferrer"
                target="_blank"
              >
                <Icon className="size-4" />
              </a>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
}
