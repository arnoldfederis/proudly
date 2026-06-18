import type { MetadataRoute } from "next";
import { absoluteUrl, SITE_PATHS } from "@/lib/seo";

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();

  return SITE_PATHS.map((path) => {
    if (path === "/") {
      return {
        url: absoluteUrl(path),
        lastModified: now,
        changeFrequency: "weekly" as const,
        priority: 1,
      };
    }

    if (path === "/contact") {
      return {
        url: absoluteUrl(path),
        lastModified: now,
        changeFrequency: "monthly" as const,
        priority: 0.6,
      };
    }

    return {
      url: absoluteUrl(path),
      lastModified: now,
      changeFrequency: "yearly" as const,
      priority: 0.5,
    };
  });
}
