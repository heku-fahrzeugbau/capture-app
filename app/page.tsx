"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

export default function Home() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = document.cookie
      .split("; ")
      .find((row) => row.startsWith("session_token="))
      ?.split("=")[1];
    setIsAuthenticated(!!token);
    setLoading(false);
  }, []);

  if (loading) {
    return <div className="flex items-center justify-center min-h-screen">Loading...</div>;
  }

  if (!isAuthenticated) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen gap-8 p-4">
        <div className="text-center">
          <h1 className="text-4xl font-bold mb-2">📸 Capture</h1>
          <p className="text-slate-600 dark:text-slate-400">
            Schnelle Text- und Spracherfassung für dein Second Brain
          </p>
        </div>

        <button
          onClick={() => {
            const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;
            const redirectUri = `${process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"}/api/auth/callback`;
            const scope = "openid profile email https://www.googleapis.com/auth/drive.file";
            const authUrl = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code&scope=${scope}`;
            window.location.href = authUrl;
          }}
          className="px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold"
        >
          Mit Google anmelden
        </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen gap-6 p-4">
      <h1 className="text-4xl font-bold mb-8">📸 Capture</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full max-w-2xl">
        {/* Sprache Button */}
        <Link
          href="/capture/voice"
          className="flex flex-col items-center justify-center p-8 bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-xl hover:shadow-lg transition"
        >
          <span className="text-5xl mb-3">🎙️</span>
          <h2 className="text-xl font-bold">Sprechen</h2>
          <p className="text-sm text-blue-100 mt-2">Sprache aufnehmen</p>
        </Link>

        {/* Text Button */}
        <Link
          href="/capture/text"
          className="flex flex-col items-center justify-center p-8 bg-gradient-to-br from-green-500 to-green-600 text-white rounded-xl hover:shadow-lg transition"
        >
          <span className="text-5xl mb-3">📝</span>
          <h2 className="text-xl font-bold">Schreiben</h2>
          <p className="text-sm text-green-100 mt-2">Text eingeben</p>
        </Link>

        {/* Settings Button */}
        <Link
          href="/settings"
          className="flex flex-col items-center justify-center p-8 bg-gradient-to-br from-slate-500 to-slate-600 text-white rounded-xl hover:shadow-lg transition"
        >
          <span className="text-5xl mb-3">⚙️</span>
          <h2 className="text-xl font-bold">Einstellungen</h2>
          <p className="text-sm text-slate-100 mt-2">Konfiguration</p>
        </Link>
      </div>
    </div>
  );
}
