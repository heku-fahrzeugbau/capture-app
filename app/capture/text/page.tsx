"use client";

import { useState } from "react";
import Link from "next/link";

export default function TextCapture() {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const handleSave = async () => {
    if (!content.trim()) {
      setMessage("Bitte Text eingeben");
      return;
    }

    setLoading(true);
    try {
      const response = await fetch("/api/capture/create", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          type: "text",
          title: title || "Notiz",
          content,
        }),
      });

      if (!response.ok) throw new Error("Upload failed");

      setMessage("✅ In Inbox gespeichert");
      setTitle("");
      setContent("");
      setTimeout(() => setMessage(""), 3000);
    } catch (error) {
      setMessage("❌ Fehler beim Speichern");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-white dark:from-slate-900 dark:to-slate-950 p-4">
      <div className="max-w-2xl mx-auto py-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <Link href="/" className="text-2xl">⬅️</Link>
          <h1 className="text-3xl font-bold">📝 Notiz eingeben</h1>
          <div className="w-8" />
        </div>

        {/* Title Input */}
        <input
          type="text"
          placeholder="Titel (optional)"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="w-full p-4 mb-4 border border-green-200 dark:border-slate-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 dark:bg-slate-800"
        />

        {/* Content Textarea */}
        <textarea
          placeholder="Deine Notiz..."
          value={content}
          onChange={(e) => setContent(e.target.value)}
          rows={12}
          className="w-full p-4 mb-4 border border-green-200 dark:border-slate-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 dark:bg-slate-800"
        />

        {/* Status Message */}
        {message && (
          <div className="mb-4 p-3 bg-blue-100 dark:bg-blue-900 text-blue-900 dark:text-blue-100 rounded-lg">
            {message}
          </div>
        )}

        {/* Save Button */}
        <button
          onClick={handleSave}
          disabled={loading}
          className="w-full py-4 bg-green-500 hover:bg-green-600 disabled:bg-gray-400 text-white font-bold rounded-lg transition"
        >
          {loading ? "Wird gespeichert..." : "💾 In Inbox speichern"}
        </button>
      </div>
    </div>
  );
}
