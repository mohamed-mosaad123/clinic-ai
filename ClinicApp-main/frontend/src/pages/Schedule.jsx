import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { 
  FaArrowLeft, FaCalendarAlt, FaClock, FaEllipsisV, 
  FaVideo, FaCalendarTimes 
} from "react-icons/fa";

// Import Appointments Hook
import { useAppointments } from "../context/AppointmentContext.js";

export default function Schedule() {
  const navigate = useNavigate();
  const { appointments, cancelAppointment } = useAppointments();
  
  // Filter State (Upcoming, Completed, Cancelled)
  const [activeTab, setActiveTab] = useState("Upcoming");

  const tabs = ["Upcoming", "Completed", "Cancelled"];

  // Filter appointments based on active tab
  // Modified to use 'app' variable to prevent ESLint errors
  const filteredAppointments = appointments?.filter((app) => {
    if (activeTab === "Upcoming") return !app.isCancelled; 
    if (activeTab === "Cancelled") return app.isCancelled;
    return false; // For Completed tab in the future
  });

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] pb-10 font-sans">
      
      {/* Header */}
      <header className="p-6 bg-[var(--bg-card)] flex items-center justify-between sticky top-0 z-10 border-b border-[var(--border)]">
        <button 
          onClick={() => navigate(-1)} 
          className="w-10 h-10 bg-[var(--bg-app)] rounded-xl flex items-center justify-center text-[var(--text-sub)] active:scale-90 transition-transform"
        >
          <FaArrowLeft />
        </button>
        <h1 className="font-black uppercase tracking-tighter italic text-xl text-[var(--text-main)]">My Schedule</h1>
        <div className="w-10"></div>
      </header>

      {/* Tabs */}
      <div className="p-6">
        <div className="flex bg-[var(--bg-app)] p-1.5 rounded-[2rem] gap-1 shadow-inner border border-[var(--border)]">
          {tabs.map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`flex-1 py-3.5 rounded-[1.5rem] text-[10px] font-black uppercase tracking-widest transition-all duration-300 ${
                activeTab === tab 
                ? 'bg-[var(--bg-card)] text-[#0B8ED9] shadow-md' 
                : 'text-[var(--text-sub)] hover:text-[#0B8ED9]'
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      {/* Appointments List */}
      <main className="px-6 space-y-6">
        {filteredAppointments && filteredAppointments.length > 0 ? (
          filteredAppointments.map((app) => (
            <div key={app.id} className="bg-[var(--bg-card)] rounded-[2.5rem] p-6 border border-[var(--border)] shadow-sm relative overflow-hidden group transition-all hover:shadow-lg">
              
              {/* Top Info */}
              <div className="flex justify-between items-start mb-6">
                <div className="flex items-center gap-3">
                  <div className="w-14 h-14 rounded-2xl overflow-hidden border-2 border-blue-50 bg-gray-50">
                    <img 
                      src={app.doctorImg || "https://via.placeholder.com/150"} 
                      className="w-full h-full object-cover" 
                      alt={app.doctorName} 
                    />
                  </div>
                  <div>
                    <h3 className="font-bold text-base leading-tight">{app.doctorName}</h3>
                    <p className="text-[10px] text-blue-500 font-black uppercase tracking-tighter mt-1">{app.spec}</p>
                  </div>
                </div>
                <button className="text-gray-300 hover:text-gray-600 p-2 transition-colors">
                  <FaEllipsisV size={14} />
                </button>
              </div>

              {/* Time & Date Box */}
              <div className="bg-[var(--bg-app)] rounded-3xl p-5 flex justify-between items-center mb-6 border border-[var(--border)]">
                <div className="flex items-center gap-2">
                  <FaCalendarAlt className="text-[#0B8ED9]" size={12} />
                  <span className="text-[11px] font-bold text-slate-600">{app.date}</span>
                </div>
                <div className="w-px h-4 bg-gray-200"></div>
                <div className="flex items-center gap-2">
                  <FaClock className="text-[#0B8ED9]" size={12} />
                  <span className="text-[11px] font-bold text-slate-600">{app.time}</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className={`w-2 h-2 rounded-full animate-pulse ${app.isCancelled ? 'bg-red-500' : 'bg-green-500'}`}></div>
                  <span className="text-[9px] font-black uppercase text-slate-400">
                    {app.isCancelled ? 'Cancelled' : 'Confirmed'}
                  </span>
                </div>
              </div>

              {/* Action Buttons */}
              {!app.isCancelled && (
                <div className="flex gap-3">
                  <button 
                    onClick={() => cancelAppointment(app.id)}
                    className="flex-1 bg-red-50 text-red-500 py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-red-500 hover:text-white transition-all active:scale-95"
                  >
                    Cancel
                  </button>
                  <button className="flex-1 bg-[#0B8ED9] text-white py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest shadow-lg shadow-blue-100 flex items-center justify-center gap-2 hover:bg-slate-900 transition-all active:scale-95">
                    <FaVideo /> Reschedule
                  </button>
                </div>
              )}
            </div>
          ))
        ) : (
          <div className="py-24 text-center">
            <div className="w-24 h-24 bg-[var(--bg-card)] rounded-full flex items-center justify-center mx-auto mb-6 border-2 border-dashed border-[var(--border)] text-gray-200">
              <FaCalendarTimes size={40} />
            </div>
            <h3 className="font-black uppercase text-gray-400 text-sm tracking-[0.2em]">No {activeTab} Mates</h3>
            <p className="text-[10px] font-bold text-gray-300 uppercase mt-2">Your medical schedule is empty</p>
          </div>
        )}
      </main>
    </div>
  );
}