import { Suspense, type ReactNode } from "react";

import { AppShell } from "@/components/app-shell";

// Server layout. The shell reads the URL (usePathname / useParams), which with
// cacheComponents must sit under a Suspense boundary so the route can prerender.
//
// The signed-in pages load their data in the browser with the session cookie, so
// navigating to them is allowed to wait for that data (no instant-navigation
// validation for this segment).
export const instant = false;

export default function AppLayout({ children }: { children: ReactNode }) {
  return (
    <Suspense fallback={<main className="login-wrap" />}>
      <AppShell>{children}</AppShell>
    </Suspense>
  );
}
