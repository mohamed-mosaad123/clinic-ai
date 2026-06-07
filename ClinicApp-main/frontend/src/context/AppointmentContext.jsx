import React, { useState, useEffect } from "react";
import { AppointmentContext } from "./AppointmentContext.js"; 
import { appointmentService, authService } from "../services/api";

export function AppointmentProvider({ children }) {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(false);

  // Fetch real appointments from the server
  const refreshAppointments = async () => {
    setLoading(true);
    try {
      const profile = await authService.getProfile();
      if (profile.patientId) {
        const data = await appointmentService.getPatientAppointments(profile.patientId);
        // Transform server data to frontend structure
        const mapped = data.map(app => ({
          id: app.id,
          doctorName: `Dr. ${app.doctorFirstName} ${app.doctorLastName}`,
          doctorImg: `https://i.pravatar.cc/150?u=${app.doctorId}`,
          spec: app.specialization || "General Medicine",
          date: new Date(app.scheduleDate).toLocaleDateString(),
          time: new Date(app.scheduleDate).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          type: "Consultation",
          isCancelled: app.status === "Cancelled"
        }));
        setAppointments(mapped);
      }
    } catch (err) {
      console.error("Failed to fetch appointments:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      refreshAppointments();
    }
  }, []);

  const addAppointment = (appointment) => {
    // Update locally immediately for UI responsiveness, then sync with server if needed
    setAppointments((prev) => [appointment, ...prev]);
    refreshAppointments(); 
  };

  const cancelAppointment = async (id) => {
    try {
      // Call cancellation API here if available, currently just local update
      setAppointments((prev) => prev.filter((app) => app.id !== id));
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <AppointmentContext.Provider value={{ appointments, addAppointment, cancelAppointment, refreshAppointments, loading }}>
      {children}
    </AppointmentContext.Provider>
  );
}