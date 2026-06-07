import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { 
  FaEnvelope, FaLock, FaEye, FaEyeSlash, 
  FaArrowLeft, FaShieldAlt, FaArrowRight, FaFingerprint, FaExclamationTriangle
} from "react-icons/fa";
import fullLogo from "../assets/full logo update.jpg"; 
import { authService } from "../services/api";

export default function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const data = await authService.login(email, password);
      
      if (data && data.accessToken) {
        // Fetch profile to check roles and name
        const profile = await authService.getProfile();
        const role = profile.roles?.[0] || "Patient";
        const name = profile.userName || profile.email?.split('@')[0];
        
        // Save to localStorage so LandingPage and others can see it
        localStorage.setItem("user_role", role);
        localStorage.setItem("user_name", name);
        
        if (role === "Doctor") {
          navigate("/doctor-home");
        } else {
          navigate("/home");
        }
      }
    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || err.message || err || "Invalid email or password.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] flex flex-col items-center justify-center p-6 font-sans relative overflow-hidden">
      
      {/* Background Elements & Grid */}
      <div className="absolute top-[-20%] right-[-10%] w-[600px] h-[600px] bg-[#0B8ED9]/10 rounded-full blur-[120px] animate-pulse"></div>
      <div className="absolute bottom-[-20%] left-[-10%] w-[600px] h-[600px] bg-[#0B8ED9]/5 rounded-full blur-[120px]"></div>
      <div className="absolute inset-0 opacity-[0.05] pointer-events-none" 
           style={{ backgroundImage: `linear-gradient(#0B8ED9 1.5px, transparent 1.5px), linear-gradient(90deg, #0B8ED9 1.5px, transparent 1.5px)`, backgroundSize: '50px 50px' }}></div>

      {/* Back Button */}
      <button 
        onClick={() => navigate('/')}
        className="absolute top-8 left-8 flex items-center gap-3 font-black uppercase italic text-[10px] border-2 border-slate-200 px-6 py-3 rounded-full bg-white/70 backdrop-blur-md hover:border-[#0B8ED9] hover:text-[#0B8ED9] transition-all z-[100] tracking-[0.2em] shadow-sm"
      >
        <FaArrowLeft /> System.Exit()
      </button>

      {/* Main Container */}
      <div className="relative w-full max-w-[480px] z-10 group">
        <div className="absolute -inset-1 bg-gradient-to-r from-[#0B8ED9]/20 to-transparent rounded-[3.5rem] blur-xl opacity-50 transition duration-1000"></div>

        <div className="relative w-full bg-white border-2 border-white rounded-[3rem] p-10 md:p-14 shadow-[0_20px_50px_rgba(0,0,0,0.05)] overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-[2px] bg-gradient-to-r from-transparent via-[#0B8ED9]/50 to-transparent animate-scan"></div>

          {/* Logo & Header */}
          <div className="flex flex-col items-center mb-12">
            <div className="w-24 h-24 bg-white border-2 border-slate-100 rounded-3xl flex items-center justify-center mb-6 shadow-2xl transition-transform duration-500 hover:scale-105">
                <img src={fullLogo} alt="Healix" className="h-16 w-auto object-contain rounded-xl" onError={(e) => e.target.style.display = 'none'} />
            </div>
            <h2 className="text-3xl md:text-4xl font-black italic tracking-tighter uppercase leading-none text-slate-800 text-center">
              Login To <span className="text-[#0B8ED9] block text-xl tracking-[0.2em] not-italic mt-2 opacity-90">Your Account</span>
            </h2>
          </div>

          {/* Error Message Box */}
          {error && (
            <div className="mb-8 p-4 bg-red-50 border-l-4 border-red-500 rounded-xl flex items-center gap-4 animate-bounce-short">
              <FaExclamationTriangle className="text-red-500 shrink-0" />
              <p className="text-[10px] font-black uppercase italic text-red-600 tracking-tighter leading-tight">
                {error}
              </p>
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-7">
            <div className="space-y-2">
              <div className="flex justify-between items-center px-2">
                <span className="text-[10px] font-black uppercase tracking-[0.3em] text-slate-400">Email</span>
                <span className="text-[10px] text-[#0B8ED9] font-mono font-bold tracking-tighter">NODE_ID: 0x1</span>
              </div>
              <div className="relative group">
                <FaEnvelope className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-[#0B8ED9] transition-colors" />
                <input 
                  type="email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@healix.ai"
                  className={`w-full bg-slate-50 border-2 rounded-2xl py-5 pl-14 pr-6 text-sm font-bold outline-none transition-all placeholder:text-slate-300 ${error ? 'border-red-200' : 'border-slate-100 focus:border-[#0B8ED9] focus:bg-white focus:shadow-[0_0_20px_rgba(11,142,217,0.1)]'}`}
                  required
                />
              </div>
            </div>

            <div className="space-y-2">
              <div className="flex justify-between items-center px-2">
                <span className="text-[10px] font-black uppercase tracking-[0.3em] text-slate-400">Password</span>
                <FaShieldAlt className="text-[10px] text-[#0B8ED9]/40 animate-pulse" />
              </div>
              <div className="relative group">
                <FaLock className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-300 group-focus-within:text-[#0B8ED9] transition-colors" />
                <input 
                  type={showPassword ? "text" : "password"} 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className={`w-full bg-slate-50 border-2 rounded-2xl py-5 pl-14 pr-16 text-sm font-bold outline-none transition-all placeholder:text-slate-300 ${error ? 'border-red-200' : 'border-slate-100 focus:border-[#0B8ED9] focus:bg-white focus:shadow-[0_0_20px_rgba(11,142,217,0.1)]'}`}
                  required
                />
                <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-5 top-1/2 -translate-y-1/2 text-slate-300 hover:text-[#0B8ED9]">
                  {showPassword ? <FaEyeSlash size={18} /> : <FaEye size={18} />}
                </button>
              </div>
              <div className="flex justify-end px-2">
                <Link to="/forgot-password" size="10" className="text-[11px] font-bold text-[#0B8ED9] hover:underline transition-all italic uppercase">Forget Password?</Link>
              </div>
            </div>

            <button type="submit" className="group relative w-full bg-[#0B8ED9] py-6 rounded-2xl font-black uppercase italic tracking-[0.2em] overflow-hidden transition-all shadow-[0_10px_25px_rgba(11,142,217,0.3)] hover:shadow-[0_15px_35px_rgba(11,142,217,0.4)] active:scale-95 text-white">
              <div className="absolute inset-0 bg-white/10 -translate-x-full group-hover:translate-x-0 transition-transform duration-500"></div>
              <span className="relative z-10 flex items-center justify-center gap-4 text-lg">
                Login <FaFingerprint className="text-2xl" />
              </span>
            </button>
          </form>

          {/* Footer - Sign Up */}
          <div className="mt-12 flex flex-col items-center gap-6">
            <Link to="/select-role" className="group text-[12px] font-black uppercase tracking-widest text-slate-400 hover:text-[#0B8ED9] transition-colors">
              Don't have an account? <span className="text-[#0B8ED9] group-hover:underline">Sign up</span>
            </Link>
            <div className="flex gap-2">
              {[1, 2, 3, 4].map(i => (
                <div key={i} className="w-8 h-1 bg-slate-100 rounded-full overflow-hidden">
                  <div className={`h-full bg-[#0B8ED9]/40 animate-loading-${i}`}></div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="mt-12 text-center space-y-2 opacity-40">
        <p className="font-black uppercase italic text-[10px] tracking-[0.8em] text-slate-500">Healix Core v3.1</p>
        <p className="text-[9px] font-mono text-slate-400 tracking-tighter italic">Verified Dev Environment: MEKY_NODE</p>
      </div>

      <style dangerouslySetInnerHTML={{ __html: `
        @keyframes scan { 0% { transform: translateY(0); opacity: 0; } 50% { opacity: 1; } 100% { transform: translateY(600px); opacity: 0; } }
        .animate-scan { animation: scan 4s linear infinite; }
        @keyframes bounce-short { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-5px); } }
        .animate-bounce-short { animation: bounce-short 0.5s ease-in-out; }
        ${[1, 2, 3, 4].map(i => `
          @keyframes loading-${i} { 0% { width: 0%; } ${i * 20}% { width: 100%; } 100% { width: 100%; } }
          .animate-loading-${i} { animation: loading-${i} 2s infinite alternate ease-in-out; }
        `).join('')}
      `}} />
    </div>
  );
}