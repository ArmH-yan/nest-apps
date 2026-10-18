import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  cacheComponents: true,
  partialPrefetching: true,
  experimental: {
    // The signed-in pages are client components that load data with the session
    // cookie, so instant-navigation validation would flag every one of them.
    // Validate only segments that opt in with `export const instant`.
    instantInsights: { validationLevel: "manual-warning" },
  },
};

export default nextConfig;
