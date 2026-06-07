import { useNavigate } from "react-router-dom";
import { 
  FaRocket, FaShieldAlt, FaMicroscope, FaCode, FaUsers, 
  FaFacebookF, FaTwitter, FaLinkedinIn, FaInstagram, FaPaperPlane, 
  FaArrowRight, FaEnvelope, FaPhoneAlt, FaMapMarkerAlt, FaAmbulance, FaPhone
} from "react-icons/fa";
import fullLogo from "../assets/full logo update.jpg";

export default function About() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] font-sans flex flex-col animate-in fade-in duration-1000">
      
      {/* 1. Navigation Bar */}
            <nav className="sticky top-0 z-[100] bg-[var(--bg-card)]/80 backdrop-blur-2xl border-b-4 border-[var(--text-main)] px-6 md:px-16 py-4">
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
                  {/* Navigation update: Buttons are mapped individually for granular control and navigation logic */}
                  <button 
                    onClick={() => navigate('/')}
                    className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group"   
                  >
                    Home
                    <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span>
                  </button>
      
                  <button 
                    onClick={() => navigate('/about')}
                    className="font-black uppercase italic text-sm tracking-tighter text-[#0B8ED9] relative group"
                  >
                    About
                    
                    <span className="absolute -bottom-1 left-0 w-full h-1.5 bg-[#0B8ED9] rounded-full"></span>
                  </button>
      
                  <button 
                    onClick={() => navigate('/services')}
                    className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group"
                  >
                    Services
                    <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span>
                  </button>
      
                  <button 
                    onClick={() => navigate('/contact')}
                    className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group"
                  >
                    Contact
                    <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span>
                  </button>
                </div>
      
                <button 
                  onClick={() => navigate('/login')}
                  className="bg-[#0B8ED9] text-white px-10 py-3 rounded-xl font-black uppercase italic text-sm border-2 border-[var(--text-main)] shadow-[5px_5px_0px_0px_var(--text-main)] hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all active:scale-95"
                >
                  Login
                </button>
              </div>
            </nav>

      <main className="flex-grow">
        {/* Hero Section */}
        <section className="max-w-7xl mx-auto px-8 py-32 text-center relative">
          <div className="inline-flex items-center gap-3 bg-white border-2 border-slate-900 px-6 py-2 rounded-full font-black uppercase italic text-[10px] shadow-[4px_4px_0px_0px_#0B8ED9] mb-10">
             <FaRocket className="text-[#0B8ED9] animate-bounce" /> The Future of Health
          </div>
          <h1 className="text-7xl md:text-9xl font-black italic tracking-tighter leading-[0.8] uppercase mb-10">
            Redefining <span className="text-[#0B8ED9] not-italic">Medicine</span> <br /> Through Tech
          </h1>
          <p className="max-w-2xl mx-auto text-slate-500 dark:text-slate-400 text-sm font-bold uppercase italic tracking-widest leading-relaxed">
            Healix isn't just a medical platform; it's a precision-engineered ecosystem designed to merge advanced AI diagnostics with human-centric healthcare.
          </p>
        </section>

        {/* Mission & Values Grid */}
        <section className="max-w-7xl mx-auto px-8 pb-32">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-10">
            <ValueCard 
              icon={<FaRocket />} 
              title="Our Vision" 
              desc="Empowering patients and doctors with real-time data and AI-driven insights to make every second count." 
            />
            <ValueCard 
              icon={<FaShieldAlt />} 
              title="Security Hub" 
              desc="Engineered with top-tier cybersecurity protocols to ensure your medical records remain private and immutable." 
              active
            />
            <ValueCard 
              icon={<FaCode />} 
              title="Clean Logic" 
              desc="Built on a robust tech stack for 99.9% uptime, ensuring your health data is always accessible when needed." 
            />
          </div>
        </section>

        {/* Technical Showcase Section */}
        <section className="bg-[#0B8ED9] dark:bg-slate-900 py-32 relative overflow-hidden border-y-8 border-[var(--text-main)] dark:border-white">
          <div className="max-w-7xl mx-auto px-8 grid grid-cols-1 lg:grid-cols-2 gap-20 items-center">
            <div className="space-y-10">
              <h2 className="text-6xl md:text-8xl font-black italic text-white uppercase tracking-tighter leading-none">
                Engineered for <br /><span className="text-[#0B8ED9] not-italic">Excellence</span>
              </h2>
              <div className="space-y-6">
                <TechDetail title="AI Core Diagnostics" detail="Automated analysis of medical history and symptoms." />
                <TechDetail title="Full-Stack Stability" detail="React & Node.js architecture for seamless performance." />
                <TechDetail title="Smart Scheduling" detail="Adaptive appointment systems that respect your time." />
              </div>
            </div>
            <div className="relative">
              <div className="aspect-square bg-[#0B8ED9]/20 rounded-[4rem] border-4 border-[#0B8ED9] flex items-center justify-center backdrop-blur-3xl group transition-all duration-700 hover:rotate-3 shadow-[20px_20px_0px_0px_#0B8ED9]">
                 <FaMicroscope className="text-[#0B8ED9] text-9xl group-hover:scale-110 transition-transform" />
                 <div className="absolute -bottom-10 -right-10 p-10 bg-white rounded-[3rem] shadow-2xl border-4 border-slate-900">
                    <p className="text-4xl font-black italic text-[var(--text-main)]">V3.1</p>
                    <p className="text-[10px] font-black uppercase text-[#0B8ED9] tracking-widest">Stable Release</p>
                 </div>
              </div>
            </div>
          </div>
        </section>

        {/* 3. Emergency & Location Cards */}
        <section className="px-6 md:px-12 py-32 relative z-20">
          <div className="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-3 border-4 border-[var(--text-main)] dark:border-white rounded-[3.5rem] overflow-hidden shadow-[25px_25px_0px_0px_rgba(15,23,42,0.1)] dark:shadow-[25px_25px_0px_0px_rgba(255,255,255,0.1)] bg-[var(--bg-card)]">
            <EnhancedInfoCard icon={<FaPhoneAlt />} title="Emergency" detail="122" primary />
            <EnhancedInfoCard icon={<FaMapMarkerAlt />} title="location" detail="6th October, Giza" />
            <EnhancedInfoCard icon={<FaAmbulance />} title="Ambulance" detail="123" primary />
          </div>
        </section>
      </main>

      {/* 4. Professional Mega Footer */}
      <footer className="bg-white dark:bg-slate-900 border-t-8 border-slate-900 dark:border-white pt-24 pb-10">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12">
          {/* Standard Footer content */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-20">
            <div className="space-y-6">
              <img src={fullLogo} alt="Logo" className="h-16 w-auto rounded-xl border-2 border-slate-900 dark:border-white shadow-[4px_4px_0px_0px_#0B8ED9]" />
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
              <h4 className="font-black uppercase italic text-xl mb-8 underline decoration-[#0B8ED9] decoration-4 underline-offset-8">Quick Links</h4>
              <ul className="space-y-4 font-bold uppercase italic text-sm">
                {['Home', 'About', 'Services', 'Contact'].map(item => (
                  <li key={item} onClick={() => navigate(`/${item.toLowerCase() === 'home' ? '' : item.toLowerCase()}`)} className="hover:text-[#0B8ED9] cursor-pointer transition-colors flex items-center gap-2 group">
                    <FaArrowRight className="text-[10px] opacity-0 group-hover:opacity-100 transition-all" /> {item}
                  </li>
                ))}
              </ul>
            </div>

            <div>
              <h4 className="font-black uppercase italic text-xl mb-8 underline decoration-[#0B8ED9] decoration-4 underline-offset-8">Support</h4>
              <ul className="space-y-4 font-bold uppercase italic text-sm">
                <li className="flex items-center gap-3"><FaEnvelope className="text-[#0B8ED9]" /> support@healix.ai</li>
                <li className="flex items-center gap-3"><FaPhoneAlt className="text-[#0B8ED9]" /> +20 100 000 000</li>
                <li className="flex items-center gap-3"><FaMapMarkerAlt className="text-[#0B8ED9]" /> Giza, Egypt</li>
              </ul>
            </div>

            
          </div>

          <div className="border-t-4 border-slate-900 dark:border-white pt-10 flex flex-col md:flex-row items-center justify-between gap-6">
            <p className="font-black uppercase italic text-xs tracking-widest opacity-40">
              © 2026 HEALIX MEDICAL SYSTEMS | DESIGNED BY HEALIX TEAM
            </p>
            <div className="flex gap-8 text-[10px] font-black uppercase italic opacity-40">
              <span className="hover:opacity-100 cursor-pointer">Privacy Policy</span>
              <span className="hover:opacity-100 cursor-pointer">Terms of Service</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

// --- Helpers (unchanged) ---
function NavLink({ label, active, onClick }) {
  return (
    <button onClick={onClick} className={`text-[10px] font-black uppercase tracking-[0.3em] transition-all relative py-2 ${active ? 'text-slate-900 dark:text-white' : 'text-slate-400 hover:text-slate-900 dark:hover:text-white'}`}>
      {label}
      <span className={`absolute bottom-0 left-1/2 -translate-x-1/2 h-1 bg-[#0B8ED9] rounded-full transition-all duration-500 ${active ? 'w-8' : 'w-0 group-hover:w-4'}`}></span>
    </button>
  );
}

function ValueCard({ icon, title, desc, active }) {
  return (
    <div className={`p-12 rounded-[4rem] border-4 border-[var(--text-main)] dark:border-white transition-all duration-500 shadow-[12px_12px_0px_0px_rgba(15,23,42,0.1)] dark:shadow-[12px_12px_0px_0px_rgba(255,255,255,0.1)] ${active ? 'bg-[#0B8ED9] text-white border-[#0B8ED9]' : 'bg-[var(--bg-card)] text-[var(--text-main)]'}`}>
      <div className={`w-20 h-20 rounded-[2rem] flex items-center justify-center text-4xl mb-12 border-4 border-[var(--text-main)] dark:border-white shadow-[6px_6px_0px_0px_rgba(0,0,0,0.1)] ${active ? 'bg-white text-[#0B8ED9]' : 'bg-[#0B8ED9] text-white'}`}>
        {icon}
      </div>
      <h3 className="text-4xl font-black uppercase italic tracking-tighter mb-6 leading-none">{title}</h3>
      <p className={`text-xs font-bold uppercase italic tracking-widest leading-relaxed opacity-80`}>{desc}</p>
    </div>
  );
}

function EnhancedInfoCard({ icon, title, detail, primary }) {
  return (
    <div className={`relative p-12 md:p-16 flex flex-col items-center lg:items-start gap-8 group transition-all duration-500 ${primary ? 'bg-[#0B8ED9] text-white border-[#0B8ED9]' : 'bg-[var(--bg-card)] text-[var(--text-main)]'} lg:border-r-4 border-b-4 lg:border-b-0 border-[var(--text-main)] dark:border-white last:border-0`}>
      <div className={`w-24 h-24 rounded-3xl flex items-center justify-center text-4xl border-4 border-slate-900 shadow-[8px_8px_0px_0px_rgba(15,23,42,1)] transition-all duration-500 group-hover:-rotate-12 ${primary ? 'bg-white text-[#0B8ED9]' : 'bg-[#0B8ED9] text-white'}`}>
        {icon}
      </div>
      <div>
        <h3 className="font-black uppercase italic text-3xl mb-2 tracking-tighter">{title}</h3>
        <p className="font-bold text-xl opacity-80 uppercase tracking-tighter">{detail}</p>
      </div>
    </div>
  );
}

function SocialIcon({ icon }) {
  return (
    <div className="w-10 h-10 bg-white dark:bg-slate-800 border-2 border-slate-900 dark:border-white flex items-center justify-center rounded-lg shadow-[3px_3px_0px_0px_#0B8ED9] hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 transition-all cursor-pointer text-slate-900 dark:text-white hover:text-[#0B8ED9]">
      {icon}
    </div>
  );
}

function TechDetail({ title, detail }) {
  return (
    <div className="flex items-center gap-6 group">
      <div className="w-2 h-12 bg-[#0B8ED9] border-2 border-slate-900 group-hover:scale-y-110 transition-all shadow-[3px_3px_0px_0px_rgba(0,0,0,0.5)]" />
      <div>
        <h4 className="text-white text-sm font-black uppercase italic tracking-widest">{title}</h4>
        <p className="text-slate-400 text-[10px] font-bold uppercase italic">{detail}</p>
      </div>
    </div>
  );
}