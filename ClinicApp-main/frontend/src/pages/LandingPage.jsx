import { useNavigate } from "react-router-dom";
import { 
  FaArrowRight, FaPhoneAlt, FaMapMarkerAlt, FaAmbulance, 
  FaCheckCircle, FaUserMd, FaHospital, FaStethoscope, FaMicroscope,
  FaFacebookF, FaTwitter, FaLinkedinIn, FaInstagram, FaEnvelope
} from "react-icons/fa";
import { useEffect, useState } from "react";

import fullLogo from "../assets/full logo update.jpg";
import doctorsBg from "../assets/doctors-team.jpg"; 

export default function LandingPage() {
  const navigate = useNavigate();
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userRole, setUserRole] = useState(null);

  useEffect(() => {
    const token = localStorage.getItem('token');
    const role = localStorage.getItem('user_role');
    if (token) {
      setIsLoggedIn(true);
      setUserRole(role);
    }
  }, []);

  const handleDashboardRedirect = () => {
    if (userRole === "Doctor") navigate("/doctor-home");
    else navigate("/home");
  };

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] font-sans selection:bg-[#0B8ED9] selection:text-white overflow-x-hidden">
      
      {/* 1. Navigation Bar */}
      <nav className="fixed top-0 left-0 w-full z-[100] bg-[var(--bg-card)]/80 backdrop-blur-2xl border-b-4 border-[var(--text-main)] px-6 md:px-16 py-4">
        <div className="max-w-[1920px] mx-auto flex justify-between items-center">
          <div className="flex items-center group cursor-pointer" onClick={() => navigate('/')}>
            <div className="relative">
              <div className="absolute -inset-1 bg-[#0B8ED9] rounded-xl blur opacity-20 group-hover:opacity-60 transition duration-500"></div>
              <img 
                src={fullLogo} 
                alt="Healix" 
                className="relative h-12 md:h-16 w-auto rounded-xl border-2 border-[var(--text-main)] shadow-[4px_4px_0px_0px_var(--text-main)] group-hover:-translate-y-1 transition-all"
              />
            </div>
          </div>

          <div className="hidden lg:flex items-center gap-12">
            <button onClick={() => navigate('/')} className="font-black uppercase italic text-sm tracking-tighter text-[#0B8ED9] relative group">Home <span className="absolute -bottom-1 left-0 w-full h-1.5 bg-[#0B8ED9] rounded-full"></span></button>
            <button onClick={() => navigate('/about')} className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group">About <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span></button>
            <button onClick={() => navigate('/services')} className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group">Services <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span></button>
            <button onClick={() => navigate('/contact')} className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group">Contact <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span></button>
          </div>

          {isLoggedIn ? (
            <button 
              onClick={handleDashboardRedirect}
              className="bg-slate-900 text-white px-8 py-3 rounded-xl font-black uppercase italic text-sm border-2 border-[var(--text-main)] shadow-[5px_5px_0px_0px_#0B8ED9] hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all active:scale-95"
            >
              Dashboard
            </button>
          ) : (
            <button 
              onClick={() => navigate('/login')}
              className="bg-[#0B8ED9] text-white px-10 py-3 rounded-xl font-black uppercase italic text-sm border-2 border-[var(--text-main)] shadow-[5px_5px_0px_0px_var(--text-main)] hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all active:scale-95"
            >
              Login
            </button>
          )}
        </div>
      </nav>

      {/* Hero Section - Added pt-24 to prevent content from being hidden under Fixed Nav */}
      <main className="pt-24 md:pt-32">
        <section className="relative min-h-[95vh] flex items-center overflow-hidden border-b-8 border-[var(--text-main)] bg-[var(--bg-card)]">
          <div 
            className="absolute inset-0 z-0 opacity-30 grayscale-[30%] scale-105"
            style={{ backgroundImage: `url(${doctorsBg})`, backgroundSize: 'cover', backgroundPosition: 'center' }}
          ></div>
          <div className="absolute inset-0 z-[1] bg-gradient-to-r from-[var(--bg-card)] via-[var(--bg-card)]/90 to-transparent"></div>

          <div className="relative z-10 w-full max-w-[1400px] mx-auto px-6 md:px-12 grid lg:grid-cols-5 items-center gap-12 py-20">
            <div className="lg:col-span-3 space-y-10">
              <div className="inline-flex items-center gap-3 bg-[var(--bg-card)] text-[var(--text-main)] border-2 border-[var(--text-main)] px-6 py-2 rounded-full font-black uppercase italic text-[10px] md:text-xs shadow-[4px_4px_0px_0px_#0B8ED9]">
                <FaStethoscope className="text-[#0B8ED9] animate-bounce" /> Next-Gen AI Medicine
              </div>
              <h1 className="text-6xl md:text-[9.5rem] font-black uppercase italic leading-[0.75] tracking-[-0.06em] text-[var(--text-main)]">
                Pure <br />
                <span className="text-[#0B8ED9] relative inline-block">
                  Genius
                  <span className="absolute -bottom-2 left-0 w-full h-4 bg-[var(--text-main)]/10 -z-10"></span>
                </span> <br />
                Health
              </h1>
              <p className="text-lg md:text-2xl font-bold max-w-xl italic uppercase leading-tight text-[var(--text-main)] opacity-80">
                // Healix is not just a clinic; it's an ecosystem of <span className="text-[#0B8ED9]">intelligent diagnostics</span> and premium care.
              </p>
              <button 
                onClick={isLoggedIn ? handleDashboardRedirect : () => navigate('/login')}
                className="group bg-[var(--text-main)] text-white px-12 py-7 rounded-[2rem] font-black uppercase italic text-xl shadow-[12px_12px_0px_0px_#0B8ED9] hover:shadow-none hover:translate-x-2 hover:translate-y-2 transition-all flex items-center gap-4"
              >
                {isLoggedIn ? "Enter Dashboard" : "Start Journey"} <FaArrowRight className="group-hover:translate-x-3 transition-transform" />
              </button>
            </div>

            <div className="lg:col-span-2 hidden lg:flex flex-col gap-6 items-end relative">
               <FloatingBadge icon={<FaUserMd />} text="Top Specialists" delay="0s" />
               <FloatingBadge icon={<FaHospital />} text="Premium Labs" delay="0.2s" />
               <FloatingBadge icon={<FaMicroscope />} text="AI Precision" delay="0.4s" />
            </div>
          </div>
        </section>

        {/* 3. Info Cards */}
        <section className="px-6 md:px-12 -mt-24 relative z-20">
          <div className="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-3 border-4 border-[var(--text-main)] rounded-[3.5rem] overflow-hidden shadow-[25px_25px_0px_0px_var(--text-main)] bg-[var(--bg-card)]">
            <EnhancedInfoCard icon={<FaPhoneAlt />} title="Emergency" detail="122" primary />
            <EnhancedInfoCard icon={<FaMapMarkerAlt />} title="location" detail="6th October, Giza" />
            <EnhancedInfoCard icon={<FaAmbulance />} title="Ambulance" detail="123" primary />
          </div>
        </section>
      </main>

      {/* 4. Professional Mega Footer */}
      <footer className="bg-[var(--bg-card)] border-t-8 border-[var(--text-main)] pt-20 pb-10 mt-20">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-20">
            <div className="space-y-6">
              <img src={fullLogo} alt="Logo" className="h-16 w-auto rounded-xl border-2 border-[var(--text-main)] shadow-[4px_4px_0px_0px_var(--text-main)]" />
              <p className="font-bold italic uppercase text-sm leading-relaxed opacity-70">
                Building the future of healthcare with cutting-edge AI and human touch.
              </p>
              <div className="flex gap-4">
                <SocialIcon icon={<FaFacebookF />} />
                <SocialIcon icon={<FaTwitter />} />
                <SocialIcon icon={<FaLinkedinIn />} />
                <SocialIcon icon={<FaInstagram />} />
              </div>
            </div>

            <div>
              <h4 className="font-black uppercase italic text-xl mb-8 underline decoration-[#0B8ED9] decoration-4 underline-offset-8 text-[var(--text-main)]">Quick Links</h4>
              <ul className="space-y-4 font-bold uppercase italic text-sm">
                <li onClick={() => navigate('/')} className="hover:text-[#0B8ED9] cursor-pointer transition-colors flex items-center gap-2 group">
                  <FaArrowRight className="text-[10px] opacity-0 group-hover:opacity-100 transition-all" /> HOME
                </li>
                <li onClick={() => navigate('/about')} className="hover:text-[#0B8ED9] cursor-pointer transition-colors flex items-center gap-2 group">
                  <FaArrowRight className="text-[10px] opacity-0 group-hover:opacity-100 transition-all" /> ABOUT
                </li>
                <li onClick={() => navigate('/services')} className="hover:text-[#0B8ED9] cursor-pointer transition-colors flex items-center gap-2 group">
                  <FaArrowRight className="text-[10px] opacity-0 group-hover:opacity-100 transition-all" /> SERVICES
                </li>
                <li onClick={() => navigate('/contact')} className="hover:text-[#0B8ED9] cursor-pointer transition-colors flex items-center gap-2 group">
                  <FaArrowRight className="text-[10px] opacity-0 group-hover:opacity-100 transition-all" /> Contact
                </li>
              </ul>
            </div>

            <div>
              <h4 className="font-black uppercase italic text-xl mb-8 underline decoration-[#0B8ED9] decoration-4 underline-offset-8 text-[var(--text-main)]">Support</h4>
              <ul className="space-y-4 font-bold uppercase italic text-sm">
                <li className="flex items-center gap-3"><FaEnvelope className="text-[#0B8ED9]" /> support@healix.ai</li>
                <li className="flex items-center gap-3"><FaPhoneAlt className="text-[#0B8ED9]" /> +20 100 000 000</li>
                <li className="flex items-center gap-3"><FaMapMarkerAlt className="text-[#0B8ED9]" /> Giza, Egypt</li>
              </ul>
            </div>
          </div>

          <div className="border-t-4 border-[var(--text-main)] pt-10 flex flex-col md:flex-row items-center justify-between gap-6">
            <p className="font-black uppercase italic text-xs tracking-widest opacity-40 text-[var(--text-main)]">
              © 2026 HEALIX MEDICAL SYSTEMS | DESIGNED BY HEALIX TEAM
            </p>
            <div className="flex gap-8 text-[10px] font-black uppercase italic opacity-40 text-[var(--text-main)]">
              <span className="hover:opacity-100 cursor-pointer">Privacy Policy</span>
              <span className="hover:opacity-100 cursor-pointer">Terms of Service</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

// Components
function FloatingBadge({ icon, text, delay }) {
  return (
    <div style={{ animationDelay: delay }} className="bg-[var(--bg-card)] border-4 border-[var(--text-main)] p-6 rounded-2xl shadow-[8px_8px_0px_0px_#0B8ED9] flex items-center gap-4 animate-bounce-slow hover:scale-110 transition-transform cursor-default">
      <div className="text-3xl text-[#0B8ED9]">{icon}</div>
      <span className="font-black uppercase italic text-sm text-[var(--text-main)]">{text}</span>
    </div>
  );
}

function EnhancedInfoCard({ icon, title, detail, primary }) {
  return (
    <div className={`relative p-12 md:p-16 flex flex-col items-center lg:items-start gap-8 group transition-all duration-500 ${primary ? 'bg-[#0B8ED9] text-white' : 'bg-[var(--bg-card)] text-[var(--text-main)]'} lg:border-r-4 border-b-4 lg:border-b-0 border-[var(--text-main)] last:border-0`}>
      <div className={`w-24 h-24 rounded-3xl flex items-center justify-center text-4xl border-4 border-[var(--text-main)] shadow-[8px_8px_0px_0px_var(--text-main)] transition-all duration-500 group-hover:-rotate-12 ${primary ? 'bg-white text-[#0B8ED9]' : 'bg-[#0B8ED9] text-white'}`}>
        {icon}
      </div>
      <div>
        <h3 className="font-black uppercase italic text-3xl mb-2 tracking-tighter">{title}</h3>
        <p className="font-bold text-xl opacity-80">{detail}</p>
      </div>
    </div>
  );
}

function SocialIcon({ icon }) {
  return (
    <div className="w-10 h-10 bg-[var(--bg-card)] border-2 border-[var(--text-main)] flex items-center justify-center rounded-lg shadow-[3px_3px_0px_0px_var(--text-main)] hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 transition-all cursor-pointer text-[var(--text-main)] hover:text-[#0B8ED9]">
      {icon}
    </div>
  );
}