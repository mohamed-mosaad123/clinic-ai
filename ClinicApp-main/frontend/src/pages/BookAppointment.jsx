import { useState, useEffect } from "react";
import { 
  FaArrowLeft, FaSearch, FaStar, FaMapMarkerAlt, 
  FaClock, FaCheckCircle, FaUserMd, FaCommentDots, FaPhoneAlt, FaAward, FaUsers 
} from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import { useAppointments } from "../context/AppointmentContext.js"; 
import { authService, doctorService, appointmentService } from "../services/api";

export default function BookAppointment() {
  const navigate = useNavigate();
  const { addAppointment } = useAppointments();
  
  const [selectedSpec, setSelectedSpec] = useState("All");
  const [bookingDoc, setBookingDoc] = useState(null); 
  const [viewingDoc, setViewingDoc] = useState(null); 
  const [showSuccess, setShowSuccess] = useState(false);
  const [selectedDate, setSelectedDate] = useState("Today");
  const [selectedSlot, setSelectedSlot] = useState(null);
  const [visitType, setVisitType] = useState("Consultation");

  const [doctors, setDoctors] = useState([]);
  const [patientId, setPatientId] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initPage = async () => {
      setLoading(true);
      try {
        // 1. Fetch Profile to get PatientId
        const profile = await authService.getProfile();
        setPatientId(profile.patientId);

        // 2. Fetch Doctors
        const realDoctors = await doctorService.getAll();
        const mappedDoctors = realDoctors.map(d => ({
          id: d.id,
          name: `Dr. ${d.firstName} ${d.lastName}`,
          spec: d.specialization || "General Medicine",
          rate: "4.5", // Mock since backend doesn't have it
          price: "300 EGP", // Mock
          img: `https://i.pravatar.cc/150?u=${d.id}`,
          bio: "Specialized clinical professional.",
          patients: "100+",
          experience: "5 Yrs",
          reviews: "50"
        }));
        setDoctors(mappedDoctors);
      } catch (err) {
        console.error("Initialization Error:", err);
      } finally {
        setLoading(false);
      }
    };
    initPage();
  }, []);

  const categories = ["All", "Cardiology", "Neurology", "Pediatrics", "Internal Medicine"];
  const dates = [{ label: "Today", date: "15 Mar" }, { label: "Tomorrow", date: "16 Mar" }, { label: "Tue", date: "17 Mar" }];
  const timeSlots = ["09:00 AM", "11:00 AM", "01:30 PM", "04:00 PM", "06:00 PM"];

  const handleConfirmBooking = async () => {
    if (!selectedSlot) return alert("Please select a time slot!");
    if (!patientId) return alert("Unable to identify patient. Please login again.");

    try {
      // 1. Create real appointment in backend
      await appointmentService.create({
        patientId: patientId,
        doctorId: bookingDoc.id
      });

      // 2. Add to local context for UI sync
      addAppointment({
        id: Date.now(),
        doctorName: bookingDoc.name,
        doctorImg: bookingDoc.img,
        spec: bookingDoc.spec,
        date: selectedDate,
        time: selectedSlot,
        type: visitType
      });

      setShowSuccess(true);
      setTimeout(() => {
        setShowSuccess(false);
        setBookingDoc(null);
        setViewingDoc(null);
        navigate('/home');
      }, 2500);
    } catch (err) {
      alert("Failed to book appointment: " + (err.message || "Server Error"));
    }
  };

  const filteredDoctors = selectedSpec === "All" ? doctors : doctors.filter(doc => doc.spec === selectedSpec);

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] pb-10 font-sans relative transition-colors duration-300">
      
      {/* 1. Success Message */}
      {showSuccess && (
        <div className="fixed inset-0 bg-blue-600 z-[100] flex flex-col items-center justify-center text-white text-center p-6">
          <FaCheckCircle className="text-7xl mb-4 animate-bounce" />
          <h2 className="text-3xl font-black italic">BOOKED!</h2>
          <p className="mt-2 font-bold opacity-80 uppercase tracking-widest">{visitType} Confirmed</p>
        </div>
      )}

      {/* 2. Booking Details Modal */}
      {bookingDoc && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[70] flex items-end justify-center">
          <div className="bg-white w-full max-w-xl rounded-t-[3rem] p-8 overflow-y-auto max-h-[90vh] shadow-2xl">
            <div className="w-12 h-1.5 bg-gray-100 rounded-full mx-auto mb-8"></div>
            <div className="flex bg-gray-50 p-1.5 rounded-2xl mb-8">
                {["Consultation", "Follow-up"].map(t => (
                  <button key={t} onClick={() => setVisitType(t)} className={`flex-1 py-3 rounded-xl text-[10px] font-black uppercase transition-all ${visitType === t ? 'bg-white shadow text-blue-600' : 'text-gray-400'}`}>{t}</button>
                ))}
            </div>
            <div className="space-y-8">
              <div>
                <h4 className="text-[10px] font-black uppercase opacity-30 mb-4 tracking-widest">Select Date</h4>
                <div className="flex gap-3">
                  {dates.map(d => (
                    <button key={d.label} onClick={() => setSelectedDate(d.label)} className={`flex-1 p-4 rounded-3xl border-2 transition-all ${selectedDate === d.label ? 'border-blue-600 bg-blue-50' : 'border-transparent bg-gray-50'}`}>
                      <p className="text-[10px] font-black uppercase mb-1">{d.label}</p>
                      <p className="font-bold text-sm">{d.date}</p>
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <h4 className="text-[10px] font-black uppercase opacity-30 mb-4 tracking-widest">Available Slots</h4>
                <div className="grid grid-cols-3 gap-3">
                  {timeSlots.map(s => (
                    <button key={s} onClick={() => setSelectedSlot(s)} className={`py-4 rounded-2xl font-black text-[10px] border-2 transition-all ${selectedSlot === s ? 'bg-blue-600 border-blue-600 text-white' : 'bg-gray-50 border-transparent text-gray-400'}`}>{s}</button>
                  ))}
                </div>
              </div>
            </div>
            <div className="mt-10 pt-6 border-t flex gap-4">
              <button onClick={() => setBookingDoc(null)} className="flex-1 font-black uppercase text-[10px] opacity-30">Cancel</button>
              <button onClick={handleConfirmBooking} className="flex-[2] bg-slate-900 text-white py-5 rounded-2xl font-black uppercase tracking-[0.2em] shadow-xl italic transition-transform active:scale-95">Confirm Booking</button>
            </div>
          </div>
        </div>
      )}

      {/* 3. Advanced Doctor Profile */}
      {viewingDoc && !bookingDoc && (
        <div className="fixed inset-0 bg-white z-[60] overflow-y-auto animate-in slide-in-from-right duration-300">
          {/* Header */}
          <div className="h-48 bg-blue-600 p-6 relative">
            <button onClick={() => setViewingDoc(null)} className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center text-white"><FaArrowLeft /></button>
            <div className="absolute -bottom-12 left-6 right-6 flex items-end gap-4">
              <img src={viewingDoc.img} className="w-32 h-32 rounded-[2.5rem] border-4 border-white shadow-2xl object-cover bg-white" alt="" />
              <div className="mb-2">
                <h2 className="text-2xl font-black italic uppercase tracking-tighter leading-none">{viewingDoc.name}</h2>
                <p className="text-white bg-blue-500/50 backdrop-blur-sm inline-block px-3 py-1 rounded-lg text-[10px] font-black uppercase mt-2 tracking-widest">{viewingDoc.spec}</p>
              </div>
            </div>
          </div>

          <div className="px-6 mt-16 pb-10">
            {/* Stats Row */}
            <div className="flex justify-between items-center bg-gray-50 rounded-[2rem] p-6 mb-8 border border-gray-100">
              <StatItem icon={<FaUsers className="text-blue-500" />} label="Patients" value={viewingDoc.patients} />
              <div className="w-px h-8 bg-gray-200"></div>
              <StatItem icon={<FaAward className="text-yellow-500" />} label="Exp." value={viewingDoc.experience} />
              <div className="w-px h-8 bg-gray-200"></div>
              <StatItem icon={<FaStar className="text-orange-500" />} label="Rating" value={viewingDoc.rate} />
            </div>

            {/* About */}
            <div className="mb-8">
              <h4 className="text-[10px] font-black uppercase opacity-30 mb-4 tracking-widest">About Doctor</h4>
              <p className="text-slate-500 font-medium leading-relaxed italic text-sm">
                "{viewingDoc.bio}"
              </p>
            </div>

            {/* Communication & Action */}
            <div className="space-y-4">
              <div className="flex gap-4">
                <button onClick={() => navigate('/chat')} className="flex-1 bg-blue-50 text-blue-600 py-4 rounded-2xl font-black text-[10px] uppercase flex items-center justify-center gap-2 border-2 border-blue-100 hover:bg-blue-100 transition-all">
                  <FaCommentDots size={16} /> Send Message
                </button>
                <button className="flex-1 bg-green-50 text-green-600 py-4 rounded-2xl font-black text-[10px] uppercase flex items-center justify-center gap-2 border-2 border-green-100 hover:bg-green-100 transition-all">
                  <FaPhoneAlt size={14} /> Voice Call
                </button>
              </div>
              <button 
                onClick={() => setBookingDoc(viewingDoc)} 
                className="w-full bg-slate-900 text-white py-6 rounded-3xl font-black uppercase tracking-[0.2em] shadow-2xl shadow-slate-200 flex items-center justify-center gap-3 transition-transform active:scale-95"
              >
                Book Appointment <span className="opacity-40 italic">| {viewingDoc.price}</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 4. Main UI (Doctor List) */}
      <header className="flex items-center justify-between p-6 bg-white/80 backdrop-blur-md border-b sticky top-0 z-10">
        <button onClick={() => navigate("/home")} className="w-10 h-10 bg-gray-50 rounded-xl flex items-center justify-center text-gray-600"><FaArrowLeft /></button>
        <h1 className="font-black uppercase tracking-tight italic">Find Specialist</h1>
        <div className="w-10"></div>
      </header>

      <main className="p-6 max-w-2xl mx-auto space-y-6">
        <div className="relative">
          <FaSearch className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300" />
          <input type="text" placeholder="Search doctor, specialty..." className="w-full bg-white border border-gray-100 rounded-2xl py-4 pl-12 pr-4 outline-none font-bold text-sm shadow-sm focus:border-blue-300 transition-all" />
        </div>

        <div className="flex gap-2 overflow-x-auto no-scrollbar py-2">
          {categories.map(cat => (
            <button key={cat} onClick={() => setSelectedSpec(cat)} className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase border-2 transition-all whitespace-nowrap ${selectedSpec === cat ? 'bg-blue-600 border-blue-600 text-white shadow-lg shadow-blue-100' : 'bg-white border-transparent text-gray-400'}`}>
              {cat}
            </button>
          ))}
        </div>

        <div className="space-y-4">
          {filteredDoctors.map(doc => (
            <div key={doc.id} onClick={() => setViewingDoc(doc)} className="bg-white p-4 rounded-[2.5rem] border border-gray-100 shadow-sm flex items-center gap-4 cursor-pointer hover:border-blue-200 transition-all group active:scale-[0.98]">
              <img src={doc.img} className="w-16 h-16 rounded-2xl object-cover bg-gray-50" alt="" />
              <div className="flex-1">
                <div className="flex justify-between items-start">
                  <h3 className="font-bold text-sm text-slate-800">{doc.name}</h3>
                  <div className="flex items-center gap-1 text-yellow-500 font-black text-[10px]"><FaStar /> {doc.rate}</div>
                </div>
                <p className="text-[10px] text-blue-500 font-bold uppercase tracking-tighter">{doc.spec}</p>
                <div className="flex justify-between items-center mt-3">
                  <span className="text-[9px] text-gray-300 font-bold uppercase"><FaMapMarkerAlt className="inline mr-1"/> Cairo, Egypt</span>
                  <button 
                    onClick={(e) => { e.stopPropagation(); setBookingDoc(doc); }} 
                    className="bg-slate-900 text-white px-5 py-2.5 rounded-xl text-[9px] font-black uppercase tracking-widest hover:bg-blue-600 transition-colors shadow-md"
                  >
                    Book
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}

// Sub-component for statistics
function StatItem({ icon, label, value }) {
  return (
    <div className="flex flex-col items-center gap-1">
      <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-sm border border-gray-100">{icon}</div>
      <p className="text-[14px] font-black text-slate-800 mt-1">{value}</p>
      <p className="text-[9px] font-bold text-gray-400 uppercase tracking-tighter">{label}</p>
    </div>
  );
}