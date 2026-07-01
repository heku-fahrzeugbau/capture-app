"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

export default function Settings() {
  const [folder, setFolder] = useState("");
  const [user, setUser] = useState("");

  useEffect(() => {
    const folderData = localStorage.getItem("capture_drive_folder");
    const userData = localStorage.getItem("capture_user");
    if (folderData) setFolder(folderData);
    if (userData) setUser(userData);
  }, []);

  const handleSignOut = () => {
    document.cookie = "session_token=; path=/; max-age=0;";
    localStorage.clear();
    window.location.href = "/";
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white dark:from-slate-900 dark:to-slate-950 p-4">
      <div className="max-w-2xl mx-auto py-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <Link href="/" className="text-2xl">⬅️</Link>
          <h1 className="text-3xl font-bold">⚙️ Einstellungen</h1>
          <div className="w-8" />
        </div>

        {/* Google Account */}
        <div className="bg-white dark:bg-slate-800 rounded-xl p-6 mb-6">
          <h2 className="text-xl font-bold mb-4">Google Konto</h2>
          {user ? (
            <>
              <p className="text-slate-600 dark:text-slate-400 mb-4">{user}</p>
              <button
                onClick={handleSignOut}
                className="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg"
              >
                Abmelden
              </button>
            </>
          ) : (
            <p className="text-slate-600 dark:text-slate-400">Nicht angemeldet</p>
          )}
        </div>

        {/* Target Folder */}
        <div className="bg-white dark:bg-slate-800 rounded-xl p-6 mb-6">
          <h2 className="text-xl font-bold mb-4">Zielordner</h2>
          {folder ? (
            <>
              <p className="text-slate-600 dark:text-slate-400 mb-4">{folder}</p>
              <button
                onClick={() => {
                  localStorage.removeItem("capture_drive_folder");
                  setFolder("");
                }}
                className="px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg"
              >
                Ändern
              </button>
            </>
          ) : (
            <p className="text-slate-600 dark:text-slate-400">
              Kein Ordner gewählt
            </p>
          )}
        </div>

        {/* Language */}
        <div className="bg-white dark:bg-slate-800 rounded-xl p-6">
          <h2 className="text-xl font-bold mb-4">Sprache</h2>
          <div className="flex gap-4">
            <label className="flex items-center">
              <input
                type="radio"
                name="language"
                value="de"
                defaultChecked
                className="mr-2"
              />
              Deutsch
            </label>
            <label className="flex items-center">
              <input
                type="radio"
                name="language"
                value="en"
                className="mr-2"
              />
              English
            </label>
          </div>
        </div>
      </div>
    </div>
  );
}
