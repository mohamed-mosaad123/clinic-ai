import { useState, useMemo, useEffect } from "react";
import { useNavigate, Link } from "react-router-dom";
import { 
  FaBell, FaSearch, FaHome, FaHistory, FaCalendarAlt, 
   FaCalendarCheck, FaDownload, FaFileMedical, FaClock, 
  FaTimes, FaCloudUploadAlt, FaPlus, FaUserCircle, FaArrowRight, 
  FaMicroscope, FaShieldAlt, FaFacebook, FaTwitter, FaLinkedin, 
  FaUserEdit, FaLock, FaInfoCircle, FaEnvelope, FaMapMarkerAlt, FaPhone,
  FaInstagram, FaPaperPlane, FaStethoscope, FaMedkit, FaCog, FaHeadset, FaAmbulance, FaPhoneAlt
} from "react-icons/fa";

import { useAppointments } from "../context/AppointmentContext.js"; 
import { authService } from "../services/api";
import fullLogo from "../assets/full logo update.jpg";

export default function Home() {
  const navigate = useNavigate();
  const [user, setUser] = useState({ username: "User", email: "" });
  const [loadingProfile, setLoadingProfile] = useState(true);
  const { appointments, cancelAppointment, refreshAppointments } = useAppointments();
  
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    const fetchRealData = async () => {
      const token = localStorage.getItem('token');
      if (!token) {
        setLoadingProfile(false);
        return;
      }

      try {
        const profile = await authService.getProfile();
        setUser({
          username: profile.userName || profile.email?.split('@')[0],
          email: profile.email
        });
        refreshAppointments();
      } catch (err) {
        console.error("Home: Failed to fetch profile", err);
      } finally {
        setLoadingProfile(false);
      }
    };
    fetchRealData();
  }, []);

  const userName = user.username;

  const displayedAppointments = useMemo(() => 
    appointments?.filter(app => 
      app.doctorName.toLowerCase().includes(searchQuery.toLowerCase())
    ).slice(0, 2) || []
  , [appointments, searchQuery]);

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] font-sans flex flex-col animate-in fade-in duration-1000 selection:bg-blue-500 selection:text-white transition-colors duration-500">
      
      {/* Background Elements */}
      <div className="fixed top-[-10%] right-[-5%] w-[600px] h-[600px] bg-blue-100/30 dark:bg-blue-900/10 blur-[140px] rounded-full -z-10 animate-pulse" />
      <div className="fixed bottom-[-10%] left-[-5%] w-[400px] h-[400px] bg-indigo-50/50 dark:bg-indigo-900/10 blur-[100px] rounded-full -z-10" />

      {/* --- Navigation Bar --- */}
      <nav className="sticky top-0 z-[100] bg-white/80 dark:bg-slate-900/80 backdrop-blur-2xl border-b border-slate-200/50 dark:border-slate-800/50 px-6 py-4 transition-all">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-10">
            <img 
              src={fullLogo} 
              alt="Healix" 
              className="h-9 md:h-10 w-auto cursor-pointer hover:scale-105 transition-transform" 
              onClick={() => navigate('/home')} 
            />
            <div className="hidden lg:flex items-center gap-6 bg-slate-100/50 dark:bg-slate-800/50 p-1.5 rounded-2xl border border-slate-200/50 dark:border-slate-700/50">
              <NavLink label="Dashboard" active onClick={() => navigate('/home')} />
              <NavLink label="Analysis" onClick={() => navigate('/new-analysis')} />
              <NavLink label="Schedule" onClick={() => navigate('/schedule')} />
              <NavLink label="Contact" onClick={() => navigate('/contact')} icon={<FaHeadset className="mr-1 text-[10px]" />} />
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="absolute top-0 right-0 w-2.5 h-2.5 bg-red-500 border-2 border-white dark:border-slate-900 rounded-full z-10 animate-ping" />
              <button className="p-3 bg-white dark:bg-slate-800 text-slate-500 dark:text-slate-400 rounded-xl hover:bg-blue-600 hover:text-white transition-all shadow-sm border border-slate-100 dark:border-slate-700">
                <FaBell size={16} />
              </button>
            </div>
            
            <button 
              onClick={() => navigate('/settings')} 
              className="group flex items-center gap-3 pl-2 pr-4 py-1.5 rounded-xl transition-all bg-white dark:bg-slate-800 border-2 border-slate-100 dark:border-slate-700 hover:border-blue-500 shadow-sm"
            >
              <div className="w-9 h-9 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-lg flex items-center justify-center text-white font-black text-xs shadow-md">
                {userName[0]?.toUpperCase() || 'M'}
              </div>
              <div className="hidden sm:block text-left">
                <p className="text-[9px] font-black uppercase text-slate-400 leading-none mb-1">System User</p>
                <p className="text-[11px] font-black uppercase text-slate-700 dark:text-white leading-none tracking-tighter">Account</p>
              </div>
              <FaCog className="text-slate-300 group-hover:rotate-90 transition-transform ml-1" size={14} />
            </button>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-8 pt-16 flex-grow w-full">
        {/* Header Section */}
        <section className="mb-20 flex flex-col lg:flex-row justify-between items-start lg:items-center gap-10">
          <div className="space-y-6">
            <div className="flex items-center gap-3">
              <span className="px-4 py-1.5 bg-blue-600 text-white text-[9px] font-black uppercase tracking-[0.2em] rounded-full shadow-lg shadow-blue-200 dark:shadow-none">System Ready</span>
              <span className="text-slate-400 dark:text-slate-500 font-bold text-[10px] uppercase tracking-widest italic">Stable V3.1.0</span>
            </div>
            <h1 className="text-6xl md:text-8xl font-black italic tracking-tighter text-slate-900 dark:text-white leading-[0.8] uppercase">
              Welcome, 
              {/* Update: Added onClick event and hover styles */}
              <span 
                onClick={() => navigate('/patient-profile')} 
                className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-indigo-600 not-italic cursor-pointer hover:opacity-80 transition-all ml-4 relative group/name"
              >
                {userName}
                <span className="absolute bottom-0 left-0 w-0 h-1 bg-blue-600 transition-all duration-300 group-hover/name:w-full"></span>
              </span>
            </h1>
          </div>
          <div className="flex gap-4">
             <button onClick={() => navigate('/book-appointment')} className="bg-[#0B8ED9] text-white px-10 py-6 rounded-3xl font-black uppercase italic tracking-widest text-xs hover:bg-slate-900 dark:hover:bg-blue-700 transition-all flex items-center gap-3 shadow-[8px_8px_0px_0px_rgba(11,142,217,0.2)] active:scale-95">
               <FaPlus /> Start Booking
             </button>
          </div>
        </section>

        {/* Dashboard Grid */}
        <div className="grid grid-cols-12 gap-12 mb-32">
          <div className="col-span-12 lg:col-span-8 space-y-16">
            {/* Search Section */}
            <div className="relative group">
              <div className="absolute inset-0 bg-blue-600/5 blur-2xl rounded-[3rem] group-focus-within:bg-blue-600/10 transition-all" />
              <div className="relative flex items-center">
                <FaSearch className="absolute left-8 text-slate-400 group-focus-within:text-blue-600 transition-colors" size={20} />
                <input 
                  type="text" 
                  placeholder="Query your medical history..."
                  className="w-full bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 rounded-[2.5rem] py-8 pl-20 pr-10 text-base font-bold shadow-sm focus:border-blue-500 focus:shadow-2xl outline-none transition-all dark:text-white"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
            </div>

            {/* Appointment Cards */}
            <div className="space-y-10">
              <h2 className="text-3xl font-black uppercase italic tracking-tighter flex items-center gap-4 dark:text-white">
                <div className="w-10 h-10 bg-blue-600 rounded-2xl flex items-center justify-center text-white rotate-3 shadow-lg"><FaStethoscope /></div>
                Active Sessions
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {displayedAppointments.length > 0 ? (
                  displayedAppointments.map(app => (
                    <AppointmentCard key={app.id} app={app} onCancel={cancelAppointment} />
                  ))
                ) : (
                  <div className="col-span-full py-24 bg-white dark:bg-slate-900/50 border-4 border-dashed border-slate-50 dark:border-slate-800 rounded-[4rem] flex flex-col items-center justify-center text-center">
                    <FaCalendarAlt className="text-slate-200 dark:text-slate-700 mb-6" size={40} />
                    <p className="text-xs font-black uppercase italic text-slate-300 dark:text-slate-600 tracking-[0.3em]">No medical records found in core</p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <aside className="col-span-12 lg:col-span-4 space-y-10">
            <div className="bg-slate-900 dark:bg-blue-950/40 rounded-[3.5rem] p-10 text-white relative overflow-hidden shadow-2xl border border-white/5">
              <div className="absolute top-0 right-0 w-40 h-40 bg-blue-500/10 blur-[60px]" />
              <div className="relative z-10 space-y-10">
                <h3 className="text-[11px] font-black uppercase tracking-[0.4em] text-slate-500">System Tools</h3>
                <div className="space-y-4">
                  <ToolButton icon={<FaCloudUploadAlt />} title="Cloud Export" color="blue" />
                  <ToolButton icon={<FaFileMedical />} title="Medical ID" />
                </div>
              </div>
            </div>
          </aside>
        </div>

        {/* 3. Info Cards */}
        <section className="px-6 md:px-12 mb-24 relative z-20">
          <div className="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-3 border-4 border-slate-900 dark:border-white rounded-[3.5rem] overflow-hidden shadow-[25px_25px_0px_0px_rgba(15,23,42,1)] dark:shadow-[25px_25px_0px_0px_rgba(255,255,255,0.1)] bg-white dark:bg-slate-900">
            <EnhancedInfoCard icon={<FaPhoneAlt />} title="Emergency" detail="122" primary />
            <EnhancedInfoCard icon={<FaMapMarkerAlt />} title="location" detail="6th October, Giza" />
            <EnhancedInfoCard icon={<FaAmbulance />} title="Ambulance" detail="123" primary />
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="w-full bg-white dark:bg-slate-950 mt-auto border-t-[1px] border-slate-200 dark:border-slate-800">
        <div className="max-w-7xl mx-auto px-10 pt-32 pb-16">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-20 mb-24">
            <div className="space-y-8">
              <div className="p-5 border-2 border-slate-900 dark:border-white rounded-[2rem] w-fit shadow-[8px_8px_0px_0px_rgba(15,23,42,1)] dark:shadow-[8px_8px_0px_0px_rgba(255,255,255,0.1)] bg-white dark:bg-slate-900 transition-all">
                <img src={fullLogo} alt="Healix" className="h-9" />
              </div>
              <p className="text-slate-500 dark:text-slate-400 text-xs font-bold uppercase italic tracking-widest leading-relaxed">
                Building the future of healthcare with cutting-edge AI and human touch.
              </p>
              <div className="flex gap-4">
                <SocialIcon icon={<FaFacebook />} />
                <SocialIcon icon={<FaTwitter />} />
                <SocialIcon icon={<FaLinkedin />} />
                <SocialIcon icon={<FaInstagram />} />
              </div>
            </div>

            <FooterColumn title="QUICK LINKS" links={['HOME', 'ABOUT', 'SERVICES', 'CONTACT']} />
            
            <div className="space-y-10">
              <h4 className="font-black uppercase italic text-xl text-slate-900 dark:text-white border-b-4 border-[#0B8ED9] w-fit pb-1">SUPPORT</h4>
              <ul className="space-y-5">
                <li className="flex items-center gap-3 text-[var(--text-main)] text-[11px] font-black uppercase tracking-widest italic group">
                  <FaEnvelope className="text-[#0B8ED9] group-hover:scale-125 transition-transform" /> SUPPORT@HEALIX.AI
                </li>
                <li className="flex items-center gap-3 text-[var(--text-main)] text-[11px] font-black uppercase tracking-widest italic group">
                  <FaPhone className="text-[#0B8ED9] group-hover:rotate-12 transition-transform" /> +20 100 000 000
                </li>
                <li className="flex items-center gap-3 text-[var(--text-main)] text-[11px] font-black uppercase tracking-widest italic group">
                  <FaMapMarkerAlt className="text-[#0B8ED9] group-hover:bounce" /> GIZA, EGYPT
                </li>
              </ul>
            </div>
          </div>

          <div className="pt-12 border-t-2 border-slate-100 dark:border-slate-800 flex flex-col md:flex-row justify-between items-center gap-8">
            <p className="text-[11px] font-black uppercase text-slate-900 dark:text-slate-400 tracking-[0.3em]">
              © 2026 HEALIX MEDICAL SYSTEMS | DESIGNED BY HEALIX TEAM
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}

// --- Modified/New Helper Components ---

function EnhancedInfoCard({ icon, title, detail, primary }) {
  return (
    <div className={`flex flex-col items-center justify-center py-12 px-6 border-r-[3px] last:border-r-0 border-slate-900 dark:border-white transition-all duration-500 hover:bg-[#0B8ED9] hover:text-white group cursor-default ${primary ? 'bg-slate-50 dark:bg-slate-800' : 'bg-white dark:bg-slate-900'}`}>
      <div className="text-3xl mb-4 group-hover:scale-110 group-hover:rotate-12 transition-transform duration-500">
        {icon}
      </div>
      <h3 className="text-3xl font-black italic uppercase tracking-tighter mb-1 leading-none">{title}</h3>
      <p className="text-[11px] font-black uppercase tracking-[0.2em] opacity-60 group-hover:opacity-100 transition-opacity">{detail}</p>
    </div>
  );
}

function NavLink({ label, active, onClick, icon }) {
  return (
    <button 
      onClick={onClick} 
      className={`flex items-center px-4 py-2 text-[10px] font-black uppercase tracking-[0.2em] transition-all rounded-xl ${active ? 'bg-white dark:bg-slate-700 text-blue-600 shadow-sm' : 'text-slate-400 hover:text-blue-500'}`}
    >
      {icon}
      {label}
    </button>
  );
}

function AppointmentCard({ app, onCancel }) {
  return (
    <div className="bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 p-10 rounded-[4rem] hover:shadow-[0_40px_80px_rgba(0,0,0,0.1)] hover:-translate-y-2 transition-all duration-500 relative group overflow-hidden">
      <div className="absolute top-0 right-0 w-32 h-32 bg-blue-50/50 dark:bg-blue-900/10 rounded-bl-[5rem] -z-10 group-hover:bg-blue-100/50 transition-colors" />
      <button onClick={() => onCancel(app.id)} className="absolute top-8 right-8 text-slate-200 dark:text-slate-700 hover:text-red-500 transition-colors"><FaTimes size={16} /></button>
      <div className="flex items-center gap-6 mb-10">
        <div className="w-20 h-20 bg-slate-50 dark:bg-slate-800 rounded-[2.2rem] border-2 border-white dark:border-slate-700 flex items-center justify-center text-slate-200 overflow-hidden">
           {app.doctorImg ? <img src={app.doctorImg} className="w-full h-full object-cover" /> : <FaUserCircle size={45} />}
        </div>
        <div>
          <h3 className="font-black uppercase italic text-2xl text-[var(--text-main)] leading-none mb-2">{app.doctorName}</h3>
          <p className="text-[10px] font-black uppercase text-blue-500 tracking-[0.2em]">{app.spec}</p>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-slate-50 dark:bg-slate-800/50 py-4 rounded-3xl flex flex-col items-center justify-center border border-slate-100/50 dark:border-slate-700">
          <FaCalendarAlt className="text-blue-500 mb-2" size={14} /><span className="font-black text-[10px] uppercase text-[var(--text-main)]">{app.date}</span>
        </div>
        <div className="bg-slate-50 dark:bg-slate-800/50 py-4 rounded-3xl flex flex-col items-center justify-center border border-slate-100/50 dark:border-slate-700">
          <FaClock className="text-blue-500 mb-2" size={14} /><span className="font-black text-[10px] uppercase text-[var(--text-main)]">{app.time}</span>
        </div>
      </div>
    </div>
  );
}

function ToolButton({ icon, title, color }) {
    const isBlue = color === 'blue';
    return (
      <button className={`w-full flex items-center justify-between p-6 rounded-[2rem] transition-all group border-2 ${isBlue ? 'bg-blue-600 border-blue-500 text-white shadow-xl' : 'bg-slate-50 dark:bg-slate-800/20 border-slate-100 dark:border-slate-700 text-[var(--text-main)] hover:bg-slate-100 dark:hover:bg-white/10'}`}>
        <div className="flex items-center gap-5">
          <div className={`p-4 rounded-2xl ${isBlue ? 'bg-white/20' : 'bg-blue-50 dark:bg-slate-700 text-blue-600 dark:text-blue-400'}`}>{icon}</div>
          <span className="font-black uppercase italic text-[11px] tracking-widest">{title}</span>
        </div>
        <FaArrowRight className="size-3 opacity-20 group-hover:translate-x-2 group-hover:opacity-100 transition-all" />
      </button>
    );
}

function FooterInfoBlock({ title, detail, light }) {
    return (
      <div className={`flex flex-col items-center justify-center py-14 px-6 border-r border-slate-100 dark:border-white/5 transition-all duration-700 cursor-default group ${light ? 'bg-white text-slate-900' : 'bg-slate-50 dark:bg-transparent text-[var(--text-main)] hover:bg-slate-100'}`}>
        <h3 className="text-4xl font-black italic uppercase tracking-tighter mb-3 group-hover:scale-110 transition-transform">{title}</h3>
        <p className={`text-xs font-black uppercase tracking-[0.2em] ${light ? 'text-slate-400' : 'text-[var(--text-sub)]'}`}>{detail}</p>
      </div>
    );
}

function SocialIcon({ icon }) {
  return (
    <div className="w-12 h-12 border-2 border-slate-900 dark:border-white rounded-2xl flex items-center justify-center text-slate-900 dark:text-white hover:bg-slate-900 dark:hover:bg-white hover:text-white dark:hover:text-slate-900 transition-all cursor-pointer shadow-[5px_5px_0px_0px_rgba(15,23,42,1)] dark:shadow-[5px_5px_0px_0px_rgba(255,255,255,0.1)] hover:shadow-none hover:translate-x-1 hover:translate-y-1">
      {icon}
    </div>
  );
}

function FooterColumn({ title, links }) {
    return (
        <div className="space-y-10">
            <h4 className="font-black uppercase italic text-xl text-slate-900 dark:text-white border-b-4 border-[#0B8ED9] w-fit pb-1">{title}</h4>
            <ul className="space-y-5">
                {links.map(link => (
                    <li key={link} className="text-slate-500 dark:text-slate-400 text-[11px] font-black uppercase tracking-widest hover:text-blue-600 dark:hover:text-blue-500 hover:translate-x-2 transition-all cursor-pointer italic">
                      {link}
                    </li>
                ))}
            </ul>
        </div>
    );
}