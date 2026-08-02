"use client";

import { create } from "zustand";
import { seedBookings } from "@/lib/mock-data/seed";
import type { Booking, BookingStatus } from "@/types/booking";

interface BookingState {
  bookings: Booking[];
  updateBooking: (id: string, patch: Partial<Booking>) => void;
  updateStatus: (id: string, status: BookingStatus) => void;
  deleteBooking: (id: string) => void;
  getById: (id: string) => Booking | undefined;
}

export const useBookingStore = create<BookingState>((set, get) => ({
  bookings: seedBookings,
  updateBooking: (id, patch) =>
    set((s) => ({
      bookings: s.bookings.map((b) => (b.id === id ? { ...b, ...patch } : b)),
    })),
  updateStatus: (id, status) => get().updateBooking(id, { status }),
  deleteBooking: (id) =>
    set((s) => ({ bookings: s.bookings.filter((b) => b.id !== id) })),
  getById: (id) => get().bookings.find((b) => b.id === id),
}));
