"use client";

// Site pin + geofence circle on OpenStreetMap (Leaflet). The pin is the
// authoritative location for GPS checks (ARCHITECTURE §25). Leaflet touches
// `window`, so it is imported only in the browser, after mount.

import "leaflet/dist/leaflet.css";

import type { Circle, CircleMarker, Map as LeafletMap } from "leaflet";
import { useEffect, useRef } from "react";

const YEREVAN: [number, number] = [40.1792, 44.4991];

export function SiteMap({
  lat,
  lng,
  radius,
  onPick,
}: {
  lat: number | null;
  lng: number | null;
  radius: number;
  onPick?: (lat: number, lng: number) => void;
}) {
  const box = useRef<HTMLDivElement>(null);
  const map = useRef<LeafletMap | null>(null);
  const pin = useRef<CircleMarker | null>(null);
  const area = useRef<Circle | null>(null);
  const pickRef = useRef(onPick);
  pickRef.current = onPick;

  useEffect(() => {
    let disposed = false;
    void import("leaflet").then((L) => {
      if (disposed || !box.current || map.current) return;
      const m = L.map(box.current).setView(lat != null && lng != null ? [lat, lng] : YEREVAN, 15);
      L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 19,
        attribution: "© OpenStreetMap contributors",
      }).addTo(m);
      m.on("click", (e) => pickRef.current?.(round6(e.latlng.lat), round6(e.latlng.lng)));
      map.current = m;
      draw(L);
    });
    return () => {
      disposed = true;
      map.current?.remove();
      map.current = null;
      pin.current = null;
      area.current = null;
    };
    // created once; updates are drawn by the effect below
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function draw(L: typeof import("leaflet")) {
    const m = map.current;
    if (!m || lat == null || lng == null) return;
    // circle markers need no image assets (default marker icons break with bundlers)
    pin.current ??= L.circleMarker([lat, lng], {
      radius: 7,
      color: "#1f2124",
      weight: 2,
      fillColor: "#ffc400",
      fillOpacity: 1,
    }).addTo(m);
    area.current ??= L.circle([lat, lng], { radius, color: "#1e8e3e", weight: 1.5 }).addTo(m);
    pin.current.setLatLng([lat, lng]);
    area.current.setLatLng([lat, lng]).setRadius(radius);
  }

  useEffect(() => {
    if (!map.current) return;
    void import("leaflet").then(draw);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lat, lng, radius]);

  return <div ref={box} className="map" />;
}

function round6(value: number): number {
  return Math.round(value * 1e6) / 1e6;
}
