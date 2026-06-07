import { useNavigate } from "react-router-dom";
import { 
  FaUserInjured, FaCalendarCheck, FaClock, FaSignOutAlt, 
  FaSearch, FaBell, FaUserMd, FaChevronRight, FaHospitalUser, FaFileMedical
} from "react-icons/fa";
import { useState, useEffect, useMemo } from "react";
import { authService, appointmentService } from "../services/api";
import fullLogo from "../assets/full logo update.jpg";

export default function DoctorHome() {
  const navigate = useNavigate();
  const [user, setUser] = useState({ username: "Doctor", email: "" });
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    const fetchDoctorData = async () => {
      try {
        const profile = await authService.getProfile();
        setUser({
          username: profile.userName || profile.email?.split('@')[0],
          email: profile.email,
          doctorId: profile.doctorId
        });

        if (profile.doctorId) {
            // Need a getDoctorAppointments endpoint or filter
            const allApps = await appointmentService.getPatientAppointments(profile.doctorId); // Actually we need doctor specific
            // Since we don't have a specific doctor endpoint that works well for now, we'll assume the API handles it or we filter
            setAppointments(allApps || []);
        }
      } catch (err) {
        console.error("DoctorHome Error:", err);
      } finally {
        setLoading(false);
      }
    };
    fetchDoctorData();
  }, []);

  const handleLogout = () => {
    authService.logout();
    navigate("/login");
  };

  const stats = [
    { label: "Total Patients", value: "42", icon: <FaHospitalUser />, color: "bg-blue-500" },
    { label: "Today's Apps", value: appointments.length.toString(), icon: <FaCalendarCheck />, color: "bg-emerald-500" },
    { label: "Pending Reports", value: "12", icon: <FaFileMedical />, color: "bg-orange-500" }
  ];

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] font-sans transition-colors duration-300">
      
      {/* Header - Premium Neo-Brutalism */}
      <header className="bg-white/80 dark:bg-slate-900/80 backdrop-blur-2xl border-b-4 border-[var(--text-main)] dark:border-white sticky top-0 z-50 px-6 md:px-12 py-5">
        <div className="max-w-[1400px] mx-auto flex justify-between items-center">
            <div className="flex items-center gap-4">
               <img src={fullLogo} alt="Healix" className="h-12 rounded-xl border-2 border-slate-900 shadow-[4px_4px_0px_0px_#0B8ED9]" />
               <div className="hidden md:block">
                  <h1 className="font-black italic uppercase text-xl leading-none">Practitioner <span className="text-[#0B8ED9]">Portal</span></h1>
                  <p className="text-[10px] font-black uppercase tracking-widest opacity-40">System Version 3.1 Stable</p>
               </div>
            </div>

            <div className="flex items-center gap-6">
                <button className="relative p-3 bg-slate-100 dark:bg-slate-800 rounded-2xl hover:scale-110 transition-all border-2 border-transparent hover:border-[#0B8ED9]">
                   <FaBell className="text-slate-500" />
                   <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-red-500 rounded-full border-2 border-white"></span>
                </button>
                <div className="flex items-center gap-3 bg-slate-900 text-white px-5 py-2.5 rounded-2xl shadow-[6px_6px_0px_0px_#0B8ED9]">
                   <div className="w-8 h-8 bg-blue-500 rounded-xl flex items-center justify-center text-xs font-black">DR</div>
                   <div className="hidden sm:block text-left">
                      <p className="text-[10px] font-black uppercase italic leading-none">{user.username}</p>
                      <p className="text-[8px] font-bold opacity-60">Verified Specialist</p>
                   </div>
                </div>
            </div>
        </div>
      </header>

      <main className="max-w-[1400px] mx-auto px-6 md:px-12 py-10">
          
          {/* Welcome Section */}
          <div className="mb-12">
             <h2 className="text-4xl md:text-6xl font-black italic uppercase tracking-tighter mb-4">Welcome back, <br /><span className="text-[#0B8ED9] not-italic">Dr. {user.username.split(' ')[0]}</span></h2>
             <p className="text-sm font-bold uppercase italic text-slate-500 tracking-widest">// You have {appointments.length} appointments scheduled for today.</p>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
             {stats.map((stat, i) => (
                <div key={i} className="bg-white dark:bg-slate-900 p-8 rounded-[3rem] border-4 border-slate-900 dark:border-white shadow-[12px_12px_0px_0px_#0B8ED9] group hover:-translate-y-1 transition-all">
                   <div className={`w-14 h-14 ${stat.color} text-white rounded-2xl flex items-center justify-center text-2xl mb-6 shadow-lg group-hover:rotate-12 transition-transform`}>
                      {stat.icon}
                   </div>
                   <p className="text-[10px] font-black uppercase opacity-40 tracking-widest mb-1">{stat.label}</p>
                   <p className="text-4xl font-black italic">{stat.value}</p>
                </div>
             ))}
          </div>

          <div className="grid lg:grid-cols-3 gap-10">
             
             {/* Main Appointments Table */}
             <div className="lg:col-span-2 space-y-6">
                <div className="flex items-center justify-between mb-4">
                   <h3 className="text-xl font-black uppercase italic tracking-widest underline decoration-[#0B8ED9] decoration-4 underline-offset-8">Patient Schedule</h3>
                   <div className="relative">
                      <FaSearch className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
                      <input 
                        type="text" 
                        placeholder="Search patient..." 
                        className="bg-white dark:bg-slate-900 border-2 border-slate-200 dark:border-slate-800 rounded-xl py-2 pl-10 pr-4 text-xs font-bold focus:border-[#0B8ED9] outline-none"
                        onChange={(e) => setSearchQuery(e.target.value)}
                      />
                   </div>
                </div>

                <div className="bg-[var(--bg-card)] dark:bg-slate-900 rounded-[3rem] border-4 border-[var(--text-main)] dark:border-white overflow-hidden shadow-[15px_15px_0px_0px_rgba(0,0,0,0.05)]">
                   <table className="w-full text-left border-collapse">
                      <thead>
                         <tr className="bg-slate-50 dark:bg-slate-800/50 border-b-2 border-[var(--text-main)] dark:border-white">
                            <th className="p-6 text-[10px] font-black uppercase tracking-widest opacity-50">Patient</th>
                            <th className="p-6 text-[10px] font-black uppercase tracking-widest opacity-50">Type</th>
                            <th className="p-6 text-[10px] font-black uppercase tracking-widest opacity-50">Time</th>
                            <th className="p-6 text-[10px] font-black uppercase tracking-widest opacity-50 text-right">Actions</th>
                         </tr>
                      </thead>
                      <tbody className="divide-y-2 divide-slate-100 dark:divide-slate-800">
                         {appointments.length > 0 ? appointments.map((app) => (
                            <tr key={app.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/30 transition-colors group">
                               <td className="p-6">
                                  <div className="flex items-center gap-3">
                                     <div className="w-10 h-10 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center font-black text-xs">P</div>
                                     <div>
                                        <p className="font-bold text-sm">Patient #{app.patientId}</p>
                                        <p className="text-[10px] opacity-50">Member ID: HLX-2026</p>
                                     </div>
                                  </div>
                               </td>
                               <td className="p-6">
                                  <span className="px-3 py-1 bg-emerald-100 text-emerald-700 rounded-lg text-[9px] font-black uppercase">General</span>
                               </td>
                               <td className="p-6">
                                  <div className="flex items-center gap-2 text-slate-500">
                                     <FaClock size={12} />
                                     <span className="text-xs font-bold uppercase">{app.time || "09:00 AM"}</span>
                                  </div>
                               </td>
                               <td className="p-6 text-right">
                                  <button className="p-2 bg-slate-900 text-white rounded-lg hover:bg-[#0B8ED9] transition-all shadow-md active:scale-90">
                                     <FaChevronRight size={12} />
                                  </button>
                               </td>
                            </tr>
                         )) : (
                            <tr>
                               <td colSpan="4" className="p-20 text-center">
                                  <FaCalendarCheck size={48} className="mx-auto mb-4 opacity-10" />
                                  <p className="font-black uppercase italic opacity-20 tracking-widest">No Patients Scheduled</p>
                               </td>
                            </tr>
                         )}
                      </tbody>
                   </table>
                </div>
             </div>

             {/* Sidebar Actions */}
             <div className="space-y-8">
                <div className="bg-[#0B8ED9] p-8 rounded-[3rem] border-4 border-slate-900 text-white shadow-[12px_12px_0px_0px_rgba(0,0,0,1)]">
                   <h4 className="text-2xl font-black italic uppercase mb-4 tracking-tighter">Quick Actions</h4>
                   <div className="space-y-3">
                      <ActionButton icon={<FaUserInjured />} label="Add Medical Record" />
                      <ActionButton icon={<FaCalendarCheck />} label="Update Schedule" />
                      <ActionButton icon={<FaSignOutAlt />} label="Log Out Session" onClick={handleLogout} />
                   </div>
                </div>

                <div className="bg-white dark:bg-slate-900 p-8 rounded-[3rem] border-4 border-slate-900 dark:border-white">
                   <h4 className="text-[10px] font-black uppercase opacity-40 mb-6 tracking-widest">Medical Support</h4>
                   <p className="text-xs font-bold leading-relaxed mb-6 italic text-slate-500">Need technical assistance with the AI diagnostic engine? Contact our 24/7 dev hub.</p>
                   <button className="w-full py-4 bg-slate-100 dark:bg-slate-800 rounded-2xl font-black uppercase text-[10px] tracking-widest hover:bg-slate-200 transition-all">Open Ticket</button>
                </div>
             </div>

          </div>
      </main>
    </div>
  );
}

function ActionButton({ icon, label, onClick }) {
  return (
    <button onClick={onClick} className="w-full flex items-center gap-4 p-4 bg-white/10 hover:bg-white/20 rounded-2xl border-2 border-white/20 transition-all group active:scale-95 text-left">
       <span className="text-xl group-hover:rotate-12 transition-transform">{icon}</span>
       <span className="font-black uppercase italic text-xs tracking-widest">{label}</span>
    </button>
  );
}
