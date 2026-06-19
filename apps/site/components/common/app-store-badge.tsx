import Image from "next/image";
import { ProgressiveImage } from "@/components/common/progressive-image";
import { deviceBlurDataURL } from "@/lib/image-placeholders";
import { APP_STORE_URL } from "@/lib/seo";
import { cn } from "@/lib/utils";

type AppStoreBadgeProps = {
  className?: string;
  isPriority?: boolean;
  ariaLabel?: string;
};

export function AppStoreBadge({
  className,
  isPriority,
  ariaLabel = "Download Proudly on the App Store",
}: AppStoreBadgeProps) {
  return (
    <a
      aria-label={ariaLabel}
      className="inline-block shrink-0 rounded-[0.875rem] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
      href={APP_STORE_URL}
    >
      {isPriority ? (
        <>
          <Image
            alt="Download on the App Store"
            className={cn("h-10 w-auto dark:hidden", className)}
            height={40}
            priority
            src="/store-badges/white.svg"
            width={120}
          />
          <Image
            alt="Download on the App Store"
            className={cn("hidden h-10 w-auto dark:block", className)}
            height={40}
            priority
            src="/store-badges/black.svg"
            width={120}
          />
        </>
      ) : (
        <>
          <ProgressiveImage
            alt="Download on the App Store"
            blurDataURL={deviceBlurDataURL}
            className={cn("h-10 w-auto dark:hidden", className)}
            height={40}
            src="/store-badges/white.svg"
            width={120}
          />
          <ProgressiveImage
            alt="Download on the App Store"
            blurDataURL={deviceBlurDataURL}
            className={cn("hidden h-10 w-auto dark:block", className)}
            height={40}
            src="/store-badges/black.svg"
            width={120}
          />
        </>
      )}
    </a>
  );
}
