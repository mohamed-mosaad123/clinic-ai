import { useState } from "react"; 
import { useNavigate } from "react-router-dom";
import { 
  FaStethoscope, FaMicroscope, FaPills, FaHeartbeat, FaArrowRight,
  FaFacebookF, FaTwitter, FaLinkedinIn, FaInstagram, FaEnvelope, 
  FaPhoneAlt, FaMapMarkerAlt, FaAmbulance, FaChevronDown
} from "react-icons/fa";
import fullLogo from "../assets/full logo update.jpg";

export default function Services() {
  const navigate = useNavigate();
  const [expandedService, setExpandedService] = useState(null);

  const servicesData = [
    {
      id: "ai",
      icon: <FaStethoscope />,
      title: "AI Consultations",
      tag: "Automation",
      desc: "Real-time symptom analysis using our proprietary Healix-V3 engine.",
      details: "Our AI engine analyzes thousands of medical papers in seconds to provide you with a preliminary diagnostic report, connecting you directly to the right specialist.",
      highlight: false
    },
    {
      id: "lab",
      icon: <FaMicroscope />,
      title: "Digital Laboratory",
      tag: "Precision",
      desc: "Advanced bloodwork and imaging analysis with 99.9% precision.",
      details: "Get your results in record time. Our digital lab is integrated with cloud technology, allowing you to track your bio-markers over time with interactive charts.",
      highlight: true
    },
    {
      id: "pharmacy",
      icon: <FaPills />,
      title: "Smart Pharmacy",
      tag: "Logistics",
      desc: "Automated prescription management and delivery system.",
      details: "Never miss a dose. Our system syncs with your doctor's prescriptions and automatically schedules deliveries to your doorstep before you run out.",
      highlight: false
    },
    {
      id: "monitoring",
      icon: <FaHeartbeat />,
      title: "Vitals Monitoring",
      tag: "Live Sync",
      desc: "24/7 remote monitoring for chronic conditions with emergency protocols.",
      details: "Using IoT wearable integration, our medical team monitors your heart rate and oxygen levels in real-time, intervening instantly if any anomaly is detected.",
      highlight: false
    }
  ];

  const toggleDetails = (id) => {
    setExpandedService(expandedService === id ? null : id);
  };

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
                          className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group"
                        >
                          About
                          <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span>
                          
                        </button>
            
                        <button 
                          onClick={() => navigate('/services')}
                          className="font-black uppercase italic text-sm tracking-tighter text-[#0B8ED9] relative group"
                        >
                          Services
                          <span className="absolute -bottom-1 left-0 w-full h-1.5 bg-[#0B8ED9] rounded-full"></span>
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
        {/* Header Section */}
        <section className="max-w-7xl mx-auto px-8 py-24 text-center space-y-8">
          <div className="inline-flex items-center gap-3 bg-white border-2 border-slate-900 px-6 py-2 rounded-full font-black uppercase italic text-[10px] shadow-[4px_4px_0px_0px_#0B8ED9]">
             <FaStethoscope className="text-[#0B8ED9] animate-bounce" /> Our Capabilities
          </div>
          <h1 className="text-6xl md:text-9xl font-black italic tracking-tighter uppercase leading-[0.8]">
            Advanced <br /><span className="text-[#0B8ED9] not-italic">Medical</span> Solutions
          </h1>
        </section>

        {/* Services Grid */}
        <section className="max-w-7xl mx-auto px-8 pb-48">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
            {servicesData.map((service) => (
              <ServiceCard 
                key={service.id}
                {...service}
                isExpanded={expandedService === service.id}
                onToggle={() => toggleDetails(service.id)}
              />
            ))}
          </div>
        </section>

        {/* Info Cards */}
        <section className="px-6 md:px-12 -mb-24 relative z-20 translate-y-[-50%]">
          <div className="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-3 border-4 border-slate-900 rounded-[3.5rem] overflow-hidden shadow-[25px_25px_0px_0px_rgba(15,23,42,1)] bg-white">
            <EnhancedInfoCard icon={<FaPhoneAlt />} title="Emergency" detail="122" primary />
            <EnhancedInfoCard icon={<FaMapMarkerAlt />} title="location" detail="6th October, Giza" />
            <EnhancedInfoCard icon={<FaAmbulance />} title="Ambulance" detail="123" primary />
          </div>
        </section>
      </main>

      {/* 4. Professional Mega Footer */}
      <footer className="bg-white dark:bg-slate-900 border-t-8 border-slate-900 dark:border-white pt-40 pb-10">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12">
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

// --- Sub Components ---

function ServiceCard({ icon, title, desc, details, tag, highlight, isExpanded, onToggle }) {
  return (
    <div className={`group p-12 rounded-[4rem] border-4 border-slate-900 dark:border-white transition-all duration-500 shadow-[12px_12px_0px_0px_rgba(15,23,42,1)] dark:shadow-[12px_12px_0px_0px_white] ${highlight ? 'bg-[#0B8ED9] text-white' : 'bg-[var(--bg-card)] text-[var(--text-main)]'}`}>
      <div className="flex justify-between items-start mb-12">
        <div className={`w-20 h-20 rounded-[2rem] flex items-center justify-center text-4xl border-4 border-slate-900 shadow-[6px_6px_0px_0px_rgba(0,0,0,0.1)] ${highlight ? 'bg-white text-[#0B8ED9]' : 'bg-[#0B8ED9] text-white'}`}>
          {icon}
        </div>
        <span className={`text-[9px] font-black uppercase tracking-widest px-4 py-1.5 rounded-full border-2 ${highlight ? 'border-white/40 text-white' : 'border-slate-900 text-slate-900'}`}>
          {tag}
        </span>
      </div>
      
      <h3 className="text-4xl font-black uppercase italic tracking-tighter mb-6 leading-none">{title}</h3>
      <p className={`text-xs font-bold uppercase italic tracking-widest leading-relaxed ${isExpanded ? 'mb-4' : 'mb-10'} ${highlight ? 'text-white/80' : 'text-slate-500'}`}>
        {desc}
      </p>

      <div className={`overflow-hidden transition-all duration-500 ${isExpanded ? 'max-h-40 opacity-100 mb-10' : 'max-h-0 opacity-0'}`}>
        <p className={`p-6 rounded-3xl border-2 border-slate-900/20 text-[11px] font-bold uppercase italic leading-loose ${highlight ? 'bg-white/10 text-white' : 'bg-slate-50 text-slate-700'}`}>
          {details}
        </p>
      </div>

      <div 
        onClick={onToggle}
        className={`flex items-center gap-2 text-[10px] font-black uppercase tracking-[0.2em] cursor-pointer hover:gap-4 transition-all w-fit ${highlight ? 'text-white underline underline-offset-4' : 'text-[#0B8ED9]'}`}
      >
        {isExpanded ? 'Show Less' : 'Get Details'} <FaChevronDown className={`transition-transform duration-300 ${isExpanded ? 'rotate-180' : ''}`} />
      </div>
    </div>
  );
}

function NavLink({ label, active, onClick }) {
  return (
    <button onClick={onClick} className={`text-[10px] font-black uppercase tracking-[0.3em] transition-all relative py-2 ${active ? 'text-slate-900 dark:text-white' : 'text-slate-400 hover:text-slate-900 dark:hover:text-white'}`}>
      {label}
      <span className={`absolute bottom-0 left-1/2 -translate-x-1/2 h-1 bg-[#0B8ED9] rounded-full transition-all duration-500 ${active ? 'w-8' : 'w-0 group-hover:w-4'}`}></span>
    </button>
  );
}

function EnhancedInfoCard({ icon, title, detail, primary }) {
  return (
    <div className={`relative p-12 md:p-16 flex flex-col items-center lg:items-start gap-8 group transition-all duration-500 ${primary ? 'bg-[#0B8ED9] text-white' : 'bg-white text-slate-900'} lg:border-r-4 border-b-4 lg:border-b-0 border-slate-900 last:border-0`}>
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