"use client";

import Image from "next/image";
import { ThemeSwitcher } from "@/components/common/theme-switcher";
import { iconBlurDataURL } from "@/lib/image-placeholders";

// TODO: Replace with final App Store URL before launch.
const APP_STORE_URL = "#";

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full border-border/50 border-b bg-background/80 backdrop-blur-lg">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-6">
        <a
          className="flex items-center gap-2 font-bold text-xl tracking-tight"
          href="/"
        >
          <Image
            alt="Proudly app icon"
            blurDataURL={iconBlurDataURL}
            className="size-8 rounded-xl"
            height={128}
            placeholder="blur"
            priority
            quality={85}
            src="/proudly-icon-128x128.png"
            width={128}
          />
          Proudly
        </a>

        <div className="flex items-center gap-2">
          <ThemeSwitcher />
          <a
            aria-label="Download Proudly on the App Store"
            className="inline-block shrink-0 rounded-[0.625rem] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
            href={APP_STORE_URL}
          >
            <Image
              alt="Download on the App Store"
              className="h-10 w-auto"
              height={40}
              priority
              src="/store-badges/black.svg"
              width={120}
            />
          </a>
        </div>
      </div>
    </header>
  );
}
