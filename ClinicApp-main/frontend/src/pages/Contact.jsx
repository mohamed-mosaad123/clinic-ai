import React, { useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import emailjs from "@emailjs/browser";
import { 
  FaFacebookF, FaTwitter, FaLinkedinIn, FaInstagram, 
  FaArrowRight, FaEnvelope, FaPhoneAlt, FaMapMarkerAlt, FaPaperPlane, FaClock
} from "react-icons/fa";
import fullLogo from "../assets/full logo update.jpg";

export default function Contact() {
  const navigate = useNavigate();
  const formRef = useRef();
  const [loading, setLoading] = useState(false);

  const sendEmail = (e) => {
    e.preventDefault();
    setLoading(true);

    const formData = new FormData(formRef.current);
    const templateParams = {
      name: formData.get('name'),     
      email: formData.get('email'),   
      title: formData.get('title'),   
      message: formData.get('message') 
    };

    emailjs.send(
      'service_kab086p',    
      'template_6irbl38',   
      templateParams, 
      'r7o3qnd5OuBbScau1'   
    )
    .then(() => {
        alert("MESSAGE SENT SUCCESFULLY");
        e.target.reset();
    }, (error) => {
        console.error("EmailJS Error:", error);
        alert("FAILED PLEASE TRY AGAIN");
    })
    .finally(() => setLoading(false));
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
                                className="font-black uppercase italic text-sm tracking-tighter hover:text-[#0B8ED9] transition-all relative group"
                              >
                                Services
                                
                                <span className="absolute -bottom-1 left-0 w-0 h-1.5 bg-[#0B8ED9] transition-all group-hover:w-full rounded-full"></span>
                              </button>
                  
                              <button 
                                onClick={() => navigate('/contact')}
                                
                                className="font-black uppercase italic text-sm tracking-tighter text-[#0B8ED9] relative group"
                              >
                                Contact
                                
                                <span className="absolute -bottom-1 left-0 w-full h-1.5 bg-[#0B8ED9] rounded-full"></span>
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
        <section className="max-w-7xl mx-auto px-8 py-24 text-center">
          <span className="px-6 py-2 bg-[var(--bg-card)] border-2 border-[var(--text-main)] rounded-full font-black uppercase italic text-[10px] shadow-[4px_4px_0px_0px_#0B8ED9] mb-8 inline-block text-[var(--text-main)]">
            Get In Touch
          </span>
          <h1 className="text-7xl md:text-9xl font-black italic tracking-tighter leading-[0.8] uppercase mb-10">
            Let's Start a <br /><span className="text-[#0B8ED9] not-italic">Conversation</span>
          </h1>
        </section>

        {/* Content Section */}
        <section className="max-w-7xl mx-auto px-8 pb-32">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">
            <div className="bg-[var(--bg-card)] dark:bg-slate-900 border-4 border-[var(--text-main)] dark:border-white p-10 md:p-14 rounded-[3.5rem] shadow-[20px_20px_0px_0px_rgba(15,23,42,0.05)] dark:shadow-[20px_20px_0px_0px_rgba(255,255,255,0.1)]">
              <h2 className="text-4xl font-black uppercase italic mb-10 tracking-tighter underline decoration-[#0B8ED9] decoration-8 underline-offset-4">Send a Message</h2>
              <form ref={formRef} onSubmit={sendEmail} className="space-y-8">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                  <InputField label="Your Name" name="name" placeholder="MOHAMMED KHALED" required />
                  <InputField label="Email Address" name="email" placeholder="MEKY@HEALIX.AI" type="email" required />
                </div>
                <InputField label="Subject" name="title" placeholder="HOW CAN WE HELP?" required />
                <div className="space-y-4">
                  <label className="text-[10px] font-black uppercase tracking-widest ml-2 opacity-60">Message</label>
                  <textarea 
                    name="message"
                    rows="5" 
                    required
                    placeholder="WRITE YOUR MESSAGE HERE..." 
                    className="w-full bg-[var(--input-bg)] dark:bg-slate-800 border-4 border-[var(--border)] dark:border-white p-6 rounded-3xl font-bold italic outline-none focus:shadow-[6px_6px_0px_0px_#0B8ED9] transition-all text-[var(--text-main)]"
                  ></textarea>
                </div>
                <button 
                  type="submit"
                  disabled={loading}
                  className="w-full bg-[#0B8ED9] text-white py-6 rounded-3xl font-black uppercase italic text-xl border-4 border-[var(--text-main)] dark:border-white shadow-[8px_8px_0px_0px_rgba(15,23,42,0.1)] dark:shadow-[8px_8px_0px_0px_rgba(255,255,255,0.1)] hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all flex items-center justify-center gap-4 group disabled:opacity-50"
                >
                  {loading ? "SENDING..." : "Send Message"} <FaPaperPlane className="group-hover:translate-x-2 group-hover:-translate-y-2 transition-transform" />
                </button>
              </form>
            </div>

            <div className="flex flex-col gap-10">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <ContactInfoCard icon={<FaPhoneAlt />} title="Call Us" detail="+20 100 000 000" />
                <ContactInfoCard icon={<FaEnvelope />} title="Email Us" detail="hello@healix.ai" />
                <ContactInfoCard 
                  icon={<FaMapMarkerAlt />} 
                  title="Location" 
                  detail="6th October University, Giza" 
                  isLink 
                  link="https://www.google.com/maps/search/6th+October+University" 
                />
                <ContactInfoCard icon={<FaClock />} title="Hours" detail="24/7 Availability" />
              </div>

              <a 
                href="https://www.google.com/maps/search/6th+October+University" 
                target="_blank" 
                rel="noreferrer"
                className="flex-grow bg-[#0B8ED9] dark:bg-slate-900 rounded-[3.5rem] border-4 border-[var(--text-main)] dark:border-white relative overflow-hidden group shadow-[20px_20px_0px_0px_#0B8ED9] min-h-[300px] cursor-pointer"
              >
                <div className="absolute inset-0 bg-white/10 dark:bg-[#0B8ED9]/20 group-hover:bg-transparent transition-colors duration-700"></div>
                <div className="absolute inset-0 flex items-center justify-center text-center">
                    <div>
                        <FaMapMarkerAlt className="text-white text-6xl mb-4 animate-bounce mx-auto" />
                        <p className="text-white font-black uppercase italic tracking-widest">Visit us @ O6U Campus</p>
                        <p className="text-white/80 dark:text-[#0B8ED9] text-xs font-bold uppercase mt-2">Click to open Maps</p>
                    </div>
                </div>
              </a>
            </div>
          </div>
        </section>
      </main>

      {/* 4. Professional Mega Footer */}
      <footer className="bg-white dark:bg-slate-900 border-t-8 border-slate-900 dark:border-white pt-20 pb-10 mt-20">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-20">
            <div className="space-y-6">
              <img src={fullLogo} alt="Logo" className="h-16 w-auto rounded-xl border-2 border-slate-900 dark:border-white shadow-[4px_4px_0px_0px_#0B8ED9]" />
              <p className="font-bold italic uppercase text-sm leading-relaxed opacity-70 text-slate-900 dark:text-slate-300">
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
              <h4 className="font-black uppercase italic text-xl mb-8 underline decoration-[#0B8ED9] decoration-4 underline-offset-8 text-slate-900 dark:text-white">Quick Links</h4>
              <ul className="space-y-4 font-bold uppercase italic text-sm text-slate-600 dark:text-slate-400">
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
              <h4 className="font-black uppercase italic text-xl mb-8 underline decoration-[#0B8ED9] decoration-4 underline-offset-8 text-slate-900 dark:text-white">Support</h4>
              <ul className="space-y-4 font-bold uppercase italic text-sm text-slate-600 dark:text-slate-400">
                <li className="flex items-center gap-3"><FaEnvelope className="text-[#0B8ED9]" /> support@healix.ai</li>
                <li className="flex items-center gap-3"><FaPhoneAlt className="text-[#0B8ED9]" /> +20 100 000 000</li>
                <li className="flex items-center gap-3"><FaMapMarkerAlt className="text-[#0B8ED9]" /> Giza, Egypt</li>
              </ul>
            </div>

            
          </div>

          <div className="border-t-4 border-slate-900 dark:border-white pt-10 flex flex-col md:flex-row items-center justify-between gap-6">
            <p className="font-black uppercase italic text-xs tracking-widest opacity-40 text-slate-900 dark:text-white">
              © 2026 HEALIX MEDICAL SYSTEMS | DESIGNED BY HEALIX TEAM
            </p>
            <div className="flex gap-8 text-[10px] font-black uppercase italic opacity-40 text-slate-900 dark:text-white">
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

function NavLink({ label, active, onClick }) {
  return (
    <button onClick={onClick} className={`text-sm font-black uppercase italic tracking-widest transition-all hover:text-[#0B8ED9] ${active ? 'text-[#0B8ED9] border-b-2 border-[#0B8ED9]' : 'text-slate-600 dark:text-slate-400'}`}>
      {label}
    </button>
  );
}

function ContactInfoCard({ icon, title, detail, isLink, link }) {
  const content = (
    <div className="bg-[var(--bg-card)] dark:bg-slate-900 border-4 border-[var(--text-main)] dark:border-white p-8 rounded-[2.5rem] shadow-[10px_10px_0px_0px_#0B8ED9] hover:translate-y-[-5px] transition-transform h-full">
      <div className="text-[#0B8ED9] text-2xl mb-4">{icon}</div>
      <h3 className="font-black uppercase italic text-xs mb-1 opacity-60">{title}</h3>
      <p className="font-bold text-sm">{detail}</p>
    </div>
  );
  return isLink ? <a href={link} target="_blank" rel="noreferrer">{content}</a> : content;
}

function InputField({ label, placeholder, name, type = "text", required }) {
  return (
    <div className="space-y-4">
      <label className="text-[10px] font-black uppercase tracking-widest ml-2 opacity-60">{label}</label>
      <input name={name} type={type} required={required} placeholder={placeholder} className="w-full bg-[#F8FAFC] dark:bg-slate-800 border-4 border-slate-900 dark:border-white p-6 rounded-3xl font-bold italic outline-none focus:shadow-[6px_6px_0px_0px_#0B8ED9] transition-all text-slate-900 dark:text-white" />
    </div>
  );
}

function SocialIcon({ icon }) {
  return (
    <a href="#" className="w-12 h-12 bg-white dark:bg-slate-800 border-2 border-slate-900 dark:border-white rounded-xl flex items-center justify-center shadow-[3px_3px_0px_0px_#0B8ED9] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-none transition-all text-slate-900 dark:text-white">
      {icon}
    </a>
  );
}