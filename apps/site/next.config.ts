import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: ["proudlyhabit.dev", "*.proudlyhabit.dev"],
  output: "standalone",
  reactCompiler: true,
  images: {
    qualities: [85],
    formats: ["image/webp"],
    remotePatterns: [{ protocol: "https", hostname: "**.proudlyhabit.com" }],
  },
};

export default nextConfig;
