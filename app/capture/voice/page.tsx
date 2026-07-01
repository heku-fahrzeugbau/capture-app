"use client";

import { useState, useRef } from "react";
import Link from "next/link";

export default function VoiceCapture() {
  const [isRecording, setIsRecording] = useState(false);
  const [duration, setDuration] = useState(0);
  const [transcript, setTranscript] = useState("");
  const [title, setTitle] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mediaRecorder = new MediaRecorder(stream);

      mediaRecorder.ondataavailable = (e) => chunksRef.current.push(e.data);
      mediaRecorder.onstop = () => {
        stream.getTracks().forEach((track) => track.stop());
      };

      mediaRecorderRef.current = mediaRecorder;
      chunksRef.current = [];
      mediaRecorder.start();
      setIsRecording(true);
      setDuration(0);

      timerRef.current = setInterval(() => {
        setDuration((d) => d + 1);
      }, 1000);
    } catch (error) {
      setMessage("❌ Microphone access denied");
    }
  };

  const stopRecording = async () => {
    if (!mediaRecorderRef.current) return;

    mediaRecorderRef.current.stop();
    if (timerRef.current) clearInterval(timerRef.current);
    setIsRecording(false);

    // Wait for onstop callback
    setTimeout(async () => {
      const audioBlob = new Blob(chunksRef.current, { type: "audio/mp3" });
      await transcribeAudio(audioBlob);
    }, 500);
  };

  const transcribeAudio = async (audioBlob: Blob) => {
    setLoading(true);
    setMessage("⏳ Transkribiere...");

    try {
      const formData = new FormData();
      formData.append("file", audioBlob, "audio.mp3");

      const response = await fetch("/api/capture/transcribe", {
        method: "POST",
        body: formData,
      });

      if (!response.ok) throw new Error("Transcription failed");

      const { text } = await response.json();
      setTranscript(text);
      setTitle(text.split(" ").slice(0, 5).join(" ")); // First 5 words as title
      setMessage("");
    } catch (error) {
      setMessage("❌ Transkription failed");
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    if (!transcript.trim()) {
      setMessage("Bitte erst aufnehmen");
      return;
    }

    setLoading(true);
    try {
      const response = await fetch("/api/capture/create", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          type: "voice",
          title: title || "Sprachnotiz",
          content: transcript,
          metadata: { duration_seconds: duration },
        }),
      });

      if (!response.ok) throw new Error("Save failed");

      setMessage("✅ In Inbox gespeichert");
      setTranscript("");
      setTitle("");
      setDuration(0);
      setTimeout(() => setMessage(""), 3000);
    } catch (error) {
      setMessage("❌ Fehler beim Speichern");
    } finally {
      setLoading(false);
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white dark:from-slate-900 dark:to-slate-950 p-4">
      <div className="max-w-2xl mx-auto py-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <Link href="/" className="text-2xl">⬅️</Link>
          <h1 className="text-3xl font-bold">🎙️ Aufnahme</h1>
          <div className="w-8" />
        </div>

        {/* Recording Area */}
        <div className="bg-white dark:bg-slate-800 rounded-xl p-8 mb-6 text-center">
          <div className="text-6xl mb-4">🎤</div>
          <div className="text-3xl font-mono font-bold mb-6">{formatTime(duration)}</div>

          {!isRecording && !transcript && (
            <button
              onClick={startRecording}
              className="px-8 py-4 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-bold"
            >
              ▶️ Aufnahme starten
            </button>
          )}

          {isRecording && (
            <button
              onClick={stopRecording}
              className="px-8 py-4 bg-red-500 hover:bg-red-600 text-white rounded-lg font-bold"
            >
              ⏹️ Stopp
            </button>
          )}
        </div>

        {/* Transcript Display */}
        {transcript && (
          <>
            <div className="mb-4">
              <label className="block text-sm font-semibold mb-2">Titel</label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full p-3 border border-blue-200 dark:border-slate-700 rounded-lg dark:bg-slate-800"
              />
            </div>

            <div className="mb-4">
              <label className="block text-sm font-semibold mb-2">Transkript</label>
              <textarea
                value={transcript}
                onChange={(e) => setTranscript(e.target.value)}
                rows={6}
                className="w-full p-3 border border-blue-200 dark:border-slate-700 rounded-lg dark:bg-slate-800"
              />
            </div>
          </>
        )}

        {/* Status Message */}
        {message && (
          <div className="mb-4 p-3 bg-blue-100 dark:bg-blue-900 text-blue-900 dark:text-blue-100 rounded-lg">
            {message}
          </div>
        )}

        {/* Save Button */}
        {transcript && (
          <button
            onClick={handleSave}
            disabled={loading}
            className="w-full py-4 bg-blue-500 hover:bg-blue-600 disabled:bg-gray-400 text-white font-bold rounded-lg transition"
          >
            {loading ? "Wird gespeichert..." : "💾 In Inbox speichern"}
          </button>
        )}
      </div>
    </div>
  );
}
