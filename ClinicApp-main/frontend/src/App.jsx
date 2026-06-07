import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { AppointmentProvider } from "./context/AppointmentContext.jsx"; 
import LandingPage from "./pages/LandingPage";
import About from "./pages/About";
import Services from "./pages/Services";
import Contact from "./pages/Contact";
import Login from "./pages/Login";
import RoleSelection from "./pages/RoleSelection";
import SignUp from "./pages/SignUp";
import DoctorSignUp from "./pages/DoctorSignUp";
import Home from "./pages/Home";
import DoctorHome from "./pages/DoctorHome";
import PatientProfile from "./pages/PatientProfile";
import Settings from "./pages/Settings";
import NewAnalysis from "./pages/NewAnalysis";
import BookAppointment from "./pages/BookAppointment";
import Schedule from "./pages/Schedule"; 

import { useEffect } from "react";

export default function App() {
  useEffect(() => {
    // 1. Get saved theme or check system preference
    const savedTheme = localStorage.getItem("theme");
    const systemPrefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    
    // 2. Determine final theme: saved > system > light (default)
    const finalTheme = savedTheme || (systemPrefersDark ? "dark" : "light");
    
    // 3. Apply the theme
    if (finalTheme === "dark") {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
    
    // 4. Save if it was the first time (system preference)
    if (!savedTheme) {
      localStorage.setItem("theme", finalTheme);
    }
  }, []);

  return (
    <AppointmentProvider>
      <Router>
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/about" element={<About />} />
          <Route path="/services" element={<Services />} />
          <Route path="/Contact" element={<Contact />} />
          <Route path="/login" element={<Login />} />
          <Route path="/select-role" element={<RoleSelection />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/doctor-signup" element={<DoctorSignUp />} />
          
          <Route path="/home" element={<Home />} />
          <Route path="/doctor-home" element={<DoctorHome />} />
          <Route path="/patient-profile" element={<PatientProfile />} />
          <Route path="/new-analysis" element={<NewAnalysis />} />
          <Route path="/book-appointment" element={<BookAppointment />} />
          <Route path="/schedule" element={<Schedule />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Router>
    </AppointmentProvider>
  );
}