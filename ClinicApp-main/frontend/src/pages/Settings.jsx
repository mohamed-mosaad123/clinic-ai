import { 
  FaChevronLeft, FaAt, FaLock, FaUserShield, FaFingerprint, 
  FaShareAlt, FaBell, FaFileAlt, FaQuestionCircle, FaEnvelope, 
  FaSignOutAlt, FaChevronRight, FaHome, FaHistory, FaCalendarAlt, FaCog, FaMoon, FaSun, FaTimes, FaArrowRight
} from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import { useState, useEffect } from "react";
import { authService } from "../services/api";

export default function Settings() {
  const navigate = useNavigate();
  const [userData, setUserData] = useState({ username: "Loading...", email: "..." });

  useEffect(() => {
    const fetchRealData = async () => {
      const token = localStorage.getItem('token');
      if (!token) return;

      try {
        const profile = await authService.getProfile();
        setUserData({
          username: profile.userName || profile.email?.split('@')[0],
          email: profile.email,
          role: profile.roles?.[0] || "Patient"
        });
      } catch (err) {
        console.error("Settings: Failed to fetch profile", err);
      }
    };
    fetchRealData();
  }, []);

  // Toggle States - synchronized with localStorage
  const [isDark, setIsDark] = useState(() => document.documentElement.classList.contains("dark"));
  const [biometric, setBiometric] = useState(() => localStorage.getItem("setting_biometric") === "true");
  const [appAlerts, setAppAlerts] = useState(() => localStorage.getItem("setting_alerts") === "true");
  const [emailReports, setEmailReports] = useState(() => localStorage.getItem("setting_reports") === "true");

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalType, setModalType] = useState(""); // "email", "password", "role"
  const [newValue, setNewValue] = useState("");
  const [loading, setLoading] = useState(false);

  const toggleTheme = () => {
    const newTheme = !isDark;
    setIsDark(newTheme);
    document.documentElement.classList.toggle("dark", newTheme);
    localStorage.setItem("theme", newTheme ? "dark" : "light");
  };

  const handleToggle = (key, setter, value) => {
    const newValue = !value;
    setter(newValue);
    localStorage.setItem(key, newValue);
  };

  const handleLogout = () => {
    localStorage.clear();
    navigate("/login");
  };

  const handleSettingClick = (type, currentVal = "") => {
    if (type === "Contact Us") return navigate("/contact");
    if (type === "Help Center") return alert("Help Center is currently being indexed...");
    
    setModalType(type);
    setNewValue(currentVal);
    setIsModalOpen(true);
  };

  const handleUpdate = async () => {
    setLoading(true);
    try {
      const updateData = {};
      if (modalType === "Email Address") updateData.email = newValue;
      if (modalType === "Password") updateData.password = newValue;
      
      await authService.updateProfile(updateData);
      
      // Update local state if needed
      if (modalType === "Email Address") setUserData(prev => ({ ...prev, email: newValue }));
      
      setIsModalOpen(false);
      alert(`${modalType} updated successfully in core database.`);
    } catch (err) {
      console.error("Update Failed:", err);
      alert("Update Failed: " + (err.response?.data?.message || "Internal Server Error"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen pb-28 font-sans transition-colors duration-300 bg-[var(--bg-app)] text-[var(--text-main)]">
      
      {/* --- Real Action Modal --- */}
      {isModalOpen && (
        <div className="fixed inset-0 z-[200] flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 animate-in fade-in duration-300">
           <div className="bg-white dark:bg-slate-900 w-full max-w-md rounded-t-[3rem] sm:rounded-[3rem] p-10 border-t-8 sm:border-8 border-slate-900 dark:border-white shadow-[0_-20px_50px_rgba(0,0,0,0.2)] animate-in slide-in-from-bottom-20 duration-500">
              <div className="flex justify-between items-center mb-8">
                 <h2 className="text-3xl font-black italic uppercase tracking-tighter">Update <span className="text-[#0B8ED9]">{modalType.split(' ')[0]}</span></h2>
                 <button onClick={() => setIsModalOpen(false)} className="w-10 h-10 bg-slate-100 dark:bg-slate-800 rounded-full flex items-center justify-center hover:bg-red-50 text-slate-400 hover:text-red-500 transition-all"><FaTimes/></button>
              </div>
              
              <div className="space-y-6">
                 <div className="group">
                    <label className="block mb-2 text-[10px] font-black uppercase tracking-widest text-slate-400">Enter New {modalType}</label>
                    <input 
                      type={modalType === "Password" ? "password" : "text"}
                      className="w-full bg-slate-50 dark:bg-slate-800 border-4 border-slate-900 dark:border-white p-5 rounded-2xl font-bold outline-none focus:ring-4 focus:ring-blue-500/10 transition-all"
                      placeholder={`New ${modalType}...`}
                      value={newValue}
                      onChange={(e) => setNewValue(e.target.value)}
                    />
                 </div>
                 <button 
                   onClick={handleUpdate}
                   disabled={loading}
                   className="w-full py-5 bg-[#0B8ED9] text-white rounded-2xl font-black uppercase italic tracking-widest shadow-[8px_8px_0px_0px_rgba(11,142,217,0.3)] hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all flex items-center justify-center gap-3 disabled:opacity-50"
                 >
                   {loading ? "Syncing..." : "Confirm Update"} <FaArrowRight />
                 </button>
              </div>
           </div>
        </div>
      )}

      {/* Header */}
      <div className="bg-[var(--bg-card)] p-4 flex items-center border-b border-[var(--border)] sticky top-0 z-10">
        <button onClick={() => navigate(-1)} className="text-[#0B8ED9]"><FaChevronLeft size={16} /></button>
        <h1 className="flex-1 text-center font-bold text-lg pr-4 tracking-tight">Settings</h1>
      </div>

      {/* Profile Section */}
      <div className="flex flex-col items-center py-8">
        <div className="w-20 h-20 bg-blue-50 dark:bg-blue-900/20 rounded-[1.8rem] flex items-center justify-center mb-3 shadow-inner">
          <div className="w-12 h-12 bg-[#0B8ED9] rounded-2xl flex items-center justify-center text-white shadow-lg shadow-blue-500/30">
            <FaUserShield size={24} />
          </div>
        </div>
        <h2 className="text-xl font-black">{userData.username}</h2>
        <p className="text-[10px] font-bold text-[var(--text-sub)] uppercase tracking-widest mt-1">Privacy Mode Active</p>
      </div>

      <div className="space-y-6">
        {/* Group: Appearance */}
        <SettingsGroup title="Appearance">
          <ToggleRow 
            icon={<FaMoon />} 
            label="Dark Mode" 
            isEnabled={isDark} 
            onToggle={toggleTheme} 
            color="bg-slate-700" 
            isLast 
          />
        </SettingsGroup>

        {/* Group: Account Settings */}
        <SettingsGroup title="Account Settings">
          <SettingRow icon={<FaAt />} label="Email Address" value={userData.email} color="bg-blue-500" onClick={() => handleSettingClick("Email Address", userData.email)} />
          <SettingRow icon={<FaLock />} label="Password" color="bg-indigo-500" onClick={() => handleSettingClick("Password")} />
          <SettingRow icon={<FaUserShield />} label="User Role" value={userData.role} color="bg-cyan-500" isLast />
        </SettingsGroup>

        {/* Group: Privacy & Security */}
        <SettingsGroup title="Privacy & Security">
          <ToggleRow 
            icon={<FaFingerprint />} 
            label="Biometric Lock" 
            isEnabled={biometric} 
            onToggle={() => handleToggle("setting_biometric", setBiometric, biometric)} 
            color="bg-emerald-500" 
          />
          <SettingRow icon={<FaShareAlt />} label="Data Sharing" color="bg-teal-500" isLast onClick={() => handleSettingClick("Data Sharing")} />
        </SettingsGroup>

        {/* Group: Notifications */}
        <SettingsGroup title="Notification Preferences">
          <ToggleRow 
            icon={<FaBell />} 
            label="App Alerts" 
            isEnabled={appAlerts} 
            onToggle={() => handleToggle("setting_alerts", setAppAlerts, appAlerts)} 
            color="bg-orange-500" 
          />
          <ToggleRow 
            icon={<FaFileAlt />} 
            label="Email Reports" 
            isEnabled={emailReports} 
            onToggle={() => handleToggle("setting_reports", setEmailReports, emailReports)} 
            color="bg-rose-500" 
            isLast 
          />
        </SettingsGroup>

        {/* Group: Support */}
        <SettingsGroup title="Support">
          <SettingRow icon={<FaQuestionCircle />} label="Help Center" color="bg-slate-500" onClick={() => handleSettingClick("Help Center")} />
          <SettingRow icon={<FaEnvelope />} label="Contact Us" color="bg-blue-400" isLast onClick={() => handleSettingClick("Contact Us")} />
        </SettingsGroup>

        {/* Log Out */}
        <div className="px-6 mt-8">
           <button 
             onClick={handleLogout}
             className="w-full py-4 bg-[var(--bg-card)] border border-red-100 dark:border-red-900/30 rounded-2xl text-red-500 font-bold flex items-center justify-center gap-2 active:scale-[0.98] transition-all shadow-sm"
           >
             <FaSignOutAlt className="rotate-180" size={14}/> Log Out
           </button>
        </div>
      </div>

      {/* Bottom Nav */}
      <nav className="fixed bottom-0 left-0 right-0 bg-[var(--bg-card)]/80 backdrop-blur-lg border-t border-[var(--border)] p-3 flex justify-around items-center z-50">
        <NavItem icon={<FaHome size={22} />} label="Home" onClick={() => navigate('/home')} />
        <NavItem icon={<FaHistory size={22} />} label="Analysis" onClick={() => navigate('/new-analysis')} />
        <NavItem icon={<FaCalendarAlt size={22} />} label="Schedule" onClick={() => navigate('/schedule')} />
        <NavItem icon={<FaCog size={22} />} label="Settings" active />
      </nav>
    </div>
  );
}

// --- Helper components for Flat Design system ---

function SettingsGroup({ title, children }) {
  return (
    <div className="px-1">
      <h3 className="text-[10px] font-black text-[var(--text-sub)] uppercase px-5 mb-2 tracking-[0.15em]">{title}</h3>
      <div className="bg-[var(--bg-card)] border-y border-[var(--border)]">{children}</div>
    </div>
  );
}

function SettingRow({ icon, label, value, color, isLast, onClick }) {
  return (
    <div 
      onClick={onClick}
      className={`flex items-center justify-between py-3.5 px-5 active:bg-slate-50 dark:active:bg-slate-800/50 transition-colors cursor-pointer ${!isLast ? 'border-b border-[var(--border)]' : ''}`}
    >
      <div className="flex items-center gap-3">
        <div className={`w-8 h-8 ${color} text-white rounded-[0.6rem] flex items-center justify-center shadow-sm`}>{icon}</div>
        <span className="font-semibold text-[13px]">{label}</span>
      </div>
      <div className="flex items-center gap-2">
        {value && <span className="text-[11px] text-[var(--text-sub)] font-medium">{value}</span>}
        <FaChevronRight className="text-slate-300" size={10} />
      </div>
    </div>
  );
}

function ToggleRow({ icon, label, isEnabled, onToggle, color, isLast }) {
  return (
    <div className={`flex items-center justify-between py-3.5 px-5 ${!isLast ? 'border-b border-[var(--border)]' : ''}`}>
      <div className="flex items-center gap-3">
        <div className={`w-8 h-8 ${color} text-white rounded-[0.6rem] flex items-center justify-center shadow-sm`}>{icon}</div>
        <span className="font-semibold text-[13px]">{label}</span>
      </div>
      <button 
        onClick={onToggle} 
        className={`w-11 h-6 rounded-full relative transition-all duration-300 ${isEnabled ? 'bg-[#4CD964]' : 'bg-slate-200 dark:bg-slate-700'}`}
      >
        <div className={`absolute top-1 w-4 h-4 bg-white rounded-full shadow-sm transition-all duration-300 ${isEnabled ? 'left-6' : 'left-1'}`}></div>
      </button>
    </div>
  );
}

function NavItem({ icon, label, active, onClick }) {
  return (
    <button onClick={onClick} className={`flex flex-col items-center gap-1 p-1 transition-colors ${active ? 'text-[#0B8ED9]' : 'text-slate-300 dark:text-slate-600'}`}>
      {icon}
      <span className="text-[9px] font-black uppercase tracking-tighter">{label}</span>
    </button>
  );
}