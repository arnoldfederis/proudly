"use client";

import * as React from "react";
import { ProgressiveImage } from "@/components/common/progressive-image";
import {
  Carousel,
  type CarouselApi,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
  useCarousel,
} from "@/components/ui/carousel";
import { deviceBlurDataURL } from "@/lib/image-placeholders";
import { cn } from "@/lib/utils";

const CAROUSEL_OPTS = {
  align: "start" as const,
  containScroll: false as const,
  dragFree: false,
  loop: false,
  watchDrag: true,
};

type CarouselFeatureItem = {
  altName: string;
  eyebrow: string;
  heading: string;
  body: string;
  imageSrc: string;
  imageAlt: string;
  hasImage: boolean;
};

function DeviceFrame({
  children,
  title,
}: {
  children: React.ReactNode;
  title: string;
}) {
  return (
    <div className="mx-auto w-full max-w-[22rem] rounded-[2.35rem] border border-black/8 bg-[#18121F] p-2 shadow-[0_18px_48px_rgba(36,28,47,0.18)] dark:border-white/10 dark:bg-[#120F18] dark:shadow-[0_24px_64px_rgba(0,0,0,0.45)]">
      <div className="flex items-center justify-center pt-1 pb-2">
        <div className="h-1.5 w-22 rounded-full bg-white/14" />
      </div>
      <div className="overflow-hidden rounded-[1.9rem] border border-white/10 bg-white/90 dark:bg-[#20182A]">
        {children}
      </div>
      <span className="sr-only">{title}</span>
    </div>
  );
}

function ScreenshotPlaceholder({ item }: { item: CarouselFeatureItem }) {
  return (
    <DeviceFrame title={item.altName}>
      <div className="flex min-h-[28rem] flex-col justify-between bg-[linear-gradient(180deg,rgba(250,245,255,0.95)_0%,rgba(245,252,249,0.95)_100%)] p-5 dark:bg-[linear-gradient(180deg,rgba(33,24,43,0.98)_0%,rgba(28,32,44,0.98)_100%)]">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="font-medium text-[#8E82A6] text-[0.62rem] uppercase tracking-[0.24em]">
              {item.eyebrow}
            </p>
            <h3 className="mt-2 font-semibold text-[#241C2F] text-lg dark:text-white">
              {item.altName}
            </h3>
          </div>
          <div className="rounded-full border border-white/70 bg-white/75 px-3 py-1 text-[#6F6478] text-xs backdrop-blur-md dark:border-white/10 dark:bg-white/[0.06] dark:text-white/70">
            Preview
          </div>
        </div>

        <div className="mt-6 grid flex-1 gap-3">
          <div className="rounded-[1.35rem] bg-[linear-gradient(135deg,rgba(199,184,255,0.9)_0%,rgba(240,166,202,0.82)_55%,rgba(180,244,226,0.86)_100%)] p-[1px]">
            <div className="flex min-h-36 flex-col justify-end rounded-[calc(1.35rem-1px)] bg-white/88 p-4 dark:bg-white/[0.06]">
              <div className="h-3 w-18 rounded-full bg-[#D7CFF7] dark:bg-white/40" />
              <div className="mt-3 h-6 w-2/3 rounded-full bg-[#F2E5F3] dark:bg-white/14" />
              <div className="mt-2 h-4 w-1/2 rounded-full bg-[#DDF5ED] dark:bg-white/10" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {["#F6D6E5", "#D7CFF7", "#D8F3EC", "#D6E9FF"].map((color) => (
              <div
                className="rounded-[1.1rem] p-3 dark:bg-white/[0.05]"
                key={color}
                style={{ backgroundColor: color }}
              >
                <div className="h-3 w-10 rounded-full bg-white/80 dark:bg-white/24" />
                <div className="mt-3 h-12 rounded-[0.85rem] bg-white/65 dark:bg-white/10" />
              </div>
            ))}
          </div>
        </div>

        <div className="mt-4 rounded-[1.2rem] border border-white/70 bg-white/72 p-4 dark:border-white/10 dark:bg-white/[0.05]">
          <div className="h-4 w-24 rounded-full bg-[#E6DFF8] dark:bg-white/32" />
          <div className="mt-2 h-3 w-2/3 rounded-full bg-[#ECE6F7] dark:bg-white/14" />
        </div>
      </div>
    </DeviceFrame>
  );
}

function ScreenshotPresentation({ item }: { item: CarouselFeatureItem }) {
  if (!item.hasImage) {
    return <ScreenshotPlaceholder item={item} />;
  }

  return (
    <ProgressiveImage
      alt={item.altName}
      blurDataURL={deviceBlurDataURL}
      className="h-auto w-65 sm:w-75"
      height={2796}
      placeholder="blur"
      quality={85}
      sizes="(max-width: 640px) 260px, 300px"
      src={item.imageSrc}
      width={1419}
    />
  );
}

export function AppleStyleFeatureCarouselClient({
  items,
}: {
  items: CarouselFeatureItem[];
}) {
  const [api, setApi] = React.useState<CarouselApi>();
  const [layoutWidth, setLayoutWidth] = React.useState<{
    carouselWidth?: number;
    controlsWidth: number;
    innerWidth?: number;
  }>({
    carouselWidth: undefined,
    controlsWidth: 350,
    innerWidth: undefined,
  });

  React.useEffect(() => {
    if (!api) return;
    const root = api.rootNode();
    if (root) {
      root.style.touchAction = "pan-y";
    }
    api.reInit();
  }, [api]);

  React.useEffect(() => {
    const updateLayoutWidth = () => {
      const { innerWidth } = window;

      if (innerWidth < 1024) {
        setLayoutWidth({
          carouselWidth: undefined,
          controlsWidth: 350,
          innerWidth,
        });
      } else {
        setLayoutWidth({
          carouselWidth: (innerWidth * 1820) / 2560,
          controlsWidth: (innerWidth * 350) / 2560,
          innerWidth,
        });
      }

      api?.reInit();
    };

    updateLayoutWidth();
    window.addEventListener("resize", updateLayoutWidth);

    return () => {
      window.removeEventListener("resize", updateLayoutWidth);
    };
  }, [api]);

  return (
    <div className="w-full">
      <div
        className="mr-0 ml-auto flex flex-col gap-6 px-6 lg:px-0 2xl:px-6 2xl:pr-0"
        style={{
          maxWidth: "100%",
          width: layoutWidth.carouselWidth
            ? `${layoutWidth.carouselWidth}px`
            : undefined,
        }}
      >
        <Carousel
          aria-label="Supporting Proudly features"
          className="w-full"
          opts={CAROUSEL_OPTS}
          setApi={setApi}
        >
          <CarouselContainer
            api={api}
            controlsWidth={layoutWidth.controlsWidth}
            innerWidth={layoutWidth.innerWidth}
            items={items}
          />
        </Carousel>
      </div>
    </div>
  );
}

function CarouselContainer({
  items,
  controlsWidth,
  api,
  innerWidth,
}: {
  items: CarouselFeatureItem[];
  controlsWidth: number;
  api: CarouselApi | undefined;
  innerWidth: number | undefined;
}) {
  const isMobile = innerWidth !== undefined && innerWidth < 1024;
  useCarousel(); // keep context alive for CarouselPrevious / CarouselNext
  const [selectedIndex, setSelectedIndex] = React.useState(0);
  const visibleItems = items.slice(0, -1);
  const lastRealIndex = visibleItems.length - 1;

  React.useEffect(() => {
    if (!api) return;

    const onSelect = () => {
      const nextIndex = api.selectedScrollSnap();

      if (nextIndex > lastRealIndex) {
        api.scrollTo(lastRealIndex);
        setSelectedIndex(lastRealIndex);
        return;
      }

      setSelectedIndex(nextIndex);
    };

    onSelect();
    api.on("select", onSelect);
    api.on("reInit", onSelect);

    return () => {
      api.off("select", onSelect);
      api.off("reInit", onSelect);
    };
  }, [api, lastRealIndex]);

  const disableNext = selectedIndex >= lastRealIndex;

  return (
    <>
      <CarouselContent className="">
        {items.map((item, index) => {
          const isLastItem = index === items.length - 1;

          if (isLastItem && isMobile) return null;

          return (
            <CarouselItem
              aria-hidden={isLastItem}
              className={cn(
                "flex pl-[16px] lg:basis-[60%] xl:basis-[60%] 2xl:basis-[58%] 2xl:pl-8",
                isLastItem ? "hidden lg:flex" : "",
              )}
              key={item.altName}
            >
              {isLastItem ? null : (
                <article className="grid w-full overflow-hidden rounded-[2rem] border border-gray bg-white/70 backdrop-blur-2xl md:min-h-[42rem] 2xl:grid-cols-[0.92fr_1.08fr] dark:border-white/10 dark:bg-white/[0.06] dark:shadow-[0_24px_80px_rgba(0,0,0,0.35)]">
                  <div className="flex h-full flex-col justify-between p-7 sm:p-8 lg:p-12">
                    <div>
                      <p className="font-medium text-[0.75rem] uppercase tracking-[0.28em]">
                        <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
                          {item.eyebrow}
                        </span>
                      </p>
                      <h3 className="mt-4 max-w-sm font-semibold text-[#241C2F] text-[2rem] leading-[1.08] sm:text-[2.15rem] dark:text-white">
                        {item.heading}
                      </h3>
                      <p className="mt-5 max-w-md text-[#6F6478] text-base leading-relaxed sm:text-lg dark:text-white/72">
                        {item.body}
                      </p>
                    </div>

                    <div className="mt-6 inline-flex w-fit rounded-full border border-white/60 bg-white/72 px-4 py-2 text-[#241C2F] text-sm shadow-[0_10px_30px_rgba(36,28,47,0.08)] backdrop-blur-xl lg:mt-8 dark:border-white/10 dark:bg-white/[0.06] dark:text-white/88">
                      <span className="bg-linear-to-r from-[#8B7CF6] via-[#C7B8FF] to-[#F0A6CA] bg-clip-text font-bold text-transparent dark:from-[#D9D0FF] dark:via-[#C7B8FF] dark:to-[#FFB6DC]">
                        {item.altName}
                      </span>
                    </div>
                  </div>

                  <div className="order-first flex min-h-96 items-center justify-center bg-white/32 p-6 sm:min-h-[26rem] sm:p-8 lg:order-none lg:min-h-0 lg:p-10 dark:bg-black/10">
                    <ScreenshotPresentation item={item} />
                  </div>
                </article>
              )}
            </CarouselItem>
          );
        })}
      </CarouselContent>

      <div
        className="mx-auto mt-6 flex flex-col justify-end gap-4 2xl:pr-8"
        style={{
          maxWidth: "100%",
          width: `${controlsWidth}px`,
        }}
      >
        <div className="flex items-center justify-center gap-3 lg:justify-end">
          {visibleItems.map((item, index) => {
            const isActive = index === selectedIndex;

            return (
              <button
                aria-label={`Go to ${item.altName}`}
                className={cn(
                  "h-2.5 rounded-full transition-all",
                  isActive
                    ? "w-7 bg-[linear-gradient(135deg,#8B7CF6_0%,#F0A6CA_100%)]"
                    : "w-2.5 bg-[#D7D0E0] hover:bg-[#C7BDD6] dark:bg-white/18 dark:hover:bg-white/28",
                )}
                key={item.altName}
                onClick={() => {
                  api?.scrollTo(index);
                  setSelectedIndex(index);
                }}
                type="button"
              />
            );
          })}
        </div>
      </div>

      <div
        className="mx-auto mt-6 flex flex-col justify-end gap-4 2xl:pr-8"
        style={{
          maxWidth: "100%",
          width: `${controlsWidth}px`,
        }}
      >
        <div className="flex flex-col items-center gap-4 lg:flex-row lg:justify-end">
          <div className="flex items-center justify-center gap-3 md:justify-end">
            <CarouselPrevious
              aria-label="Previous feature"
              className="static border-white/60 bg-white/72 text-[#241C2F] shadow-[0_10px_30px_rgba(36,28,47,0.12)] backdrop-blur-xl hover:bg-white dark:border-white/10 dark:bg-white/[0.06] dark:text-white dark:hover:bg-white/[0.1]"
            />
            <CarouselNext
              aria-label="Next feature"
              className="static border-white/60 bg-white/72 text-[#241C2F] shadow-[0_10px_30px_rgba(36,28,47,0.12)] backdrop-blur-xl hover:bg-white dark:border-white/10 dark:bg-white/[0.06] dark:text-white dark:hover:bg-white/[0.1]"
              disabled={disableNext}
            />
          </div>
        </div>
      </div>
    </>
  );
}
