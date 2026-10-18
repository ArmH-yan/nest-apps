import type { Metadata } from "next";
import { Geist } from "next/font/google";

import "./globals.css";
import { Providers } from "./providers";

const geistSans = Geist({ variable: "--font-geist-sans", subsets: ["latin"] });

export const metadata: Metadata = {
  title: "NEST Manager",
  description: "NEST operations — manager and admin",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="hy" className={geistSans.variable}>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
