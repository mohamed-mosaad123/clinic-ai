import { createContext, useContext } from "react";

export const AppointmentContext = createContext(null);

export const useAppointments = () => useContext(AppointmentContext);
