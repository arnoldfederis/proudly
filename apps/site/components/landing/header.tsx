"use client";

import Image from "next/image";
import { AppStoreBadge } from "@/components/common/app-store-badge";
import { ThemeSwitcher } from "@/components/common/theme-switcher";
import { iconBlurDataURL } from "@/lib/image-placeholders";

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
          <AppStoreBadge isPriority={true} />
        </div>
      </div>
    </header>
  );
}
