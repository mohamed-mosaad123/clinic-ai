import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  FaArrowLeft, FaUserEdit, FaIdCard, FaHistory, 
  FaTint, FaFlask, FaFileMedicalAlt, FaSignOutAlt, FaCamera, FaSave, FaTimes, FaDownload, FaCalendarAlt, FaPlus, FaStethoscope, FaSearch
} from 'react-icons/fa';
import { authService } from "../services/api";

export default function PatientProfile() {
  const navigate = useNavigate();
  
  // Mock doctor accounts for search demonstration
  const availableDoctors = [
    { name: "Dr. Ahmed Mansour", specialty: "Internal Medicine" },
    { name: "Dr. Sarah Khaled", specialty: "Gastroenterology" },
    { name: "Dr. Mohamed El-Sayed", specialty: "Nephrology" },
    { name: "Dr. Laila Hassan", specialty: "Endocrinology" },
    { name: "Dr. Omar Gamal", specialty: "Rheumatology" }
  ];

  const [userData, setUserData] = useState({
      username: "Patient User",
      email: "",
      bloodType: "Not Set",
      allergies: "None",
      insuranceId: "HLX-PENDING",
      weight: "0",
      height: "0",
      profileImg: null,
      phone: ""
  });

  const [medicalRecords, setMedicalRecords] = useState(() => {
    const saved = localStorage.getItem("patient_medical_records");
    return saved ? JSON.parse(saved) : { history: [], labs: [], prescriptions: [] };
  });

  const [activeModal, setActiveModal] = useState(null);
  const [tempData, setTempData] = useState(userData);
  const [newItem, setNewItem] = useState({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchProfile = async () => {
      const token = localStorage.getItem('token');
      if (!token) {
        navigate('/login');
        return;
      }
      
      setLoading(true);
      try {
        const profile = await authService.getProfile();
        setUserData(prev => ({
          ...prev,
          username: profile.userName,
          email: profile.email,
          phone: profile.phone || prev.phone,
          roles: profile.roles,
          gender: profile.gender === 1 ? "Female" : profile.gender === 0 ? "Male" : prev.gender,
          id: profile.patientId || profile.doctorId || prev.id
        }));
      } catch (err) {
        console.error("Failed to fetch real profile:", err);
        if (err.status === 401 || err.toString().includes('401')) {
          localStorage.clear();
          navigate('/login');
        }
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, [navigate]);

  useEffect(() => {
    localStorage.setItem("patient_full_data", JSON.stringify(userData));
  }, [userData]);

  useEffect(() => {
    localStorage.setItem("patient_medical_records", JSON.stringify(medicalRecords));
  }, [medicalRecords]);

  const handleImageUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => setUserData(prev => ({ ...prev, profileImg: reader.result }));
      reader.readAsDataURL(file);
    }
  };

  const handleAddItem = (category) => {
    if (!newItem.doctor || !newItem.clinic) return alert("Please select doctor and clinic");
    const id = Date.now();
    setMedicalRecords(prev => ({
      ...prev,
      [category]: [{ id, ...newItem }, ...prev[category]]
    }));
    setNewItem({});
  };

  return (
    <div className="min-h-screen bg-[var(--bg-app)] text-[var(--text-main)] p-6 md:p-16 transition-colors duration-500 font-sans">
      
      {/* --- Dynamic Modal System --- */}
      {activeModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-slate-900/90 backdrop-blur-md p-4">
          <div className="bg-white dark:bg-slate-900 border-[6px] border-slate-900 dark:border-white p-8 rounded-[3rem] w-full max-w-2xl max-h-[85vh] overflow-y-auto shadow-[25px_25px_0px_0px_#2563eb]">
            
            <div className="flex justify-between items-center mb-8">
              <h2 className="text-3xl font-black italic uppercase dark:text-white leading-none">
                {activeModal === 'edit' && <>Update <span className="text-blue-600">Vitals</span></>}
                {activeModal === 'history' && <>Booking <span className="text-blue-600">Logs</span></>}
                {activeModal === 'labs' && <>Lab <span className="text-blue-600">Analysis</span></>}
                {activeModal === 'prescriptions' && <>Medical <span className="text-blue-600">Orders</span></>}
              </h2>
              <button onClick={() => {setActiveModal(null); setNewItem({});}} className="text-slate-400 hover:text-red-500 transition-colors"><FaTimes size={24} /></button>
            </div>

            {/* Content: Edit Vitals */}
            {activeModal === 'edit' && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <InputGroup label="Name" value={tempData.username} onChange={(v) => setTempData({...tempData, username: v})} />
                <InputGroup label="Blood" value={tempData.bloodType} onChange={(v) => setTempData({...tempData, bloodType: v})} />
                <InputGroup label="Weight (kg)" value={tempData.weight} onChange={(v) => setTempData({...tempData, weight: v})} />
                <InputGroup label="Height (cm)" value={tempData.height} onChange={(v) => setTempData({...tempData, height: v})} />
                <button onClick={() => { setUserData(tempData); setActiveModal(null); }} className="md:col-span-2 bg-blue-600 text-white p-5 rounded-2xl font-black uppercase italic shadow-lg hover:bg-blue-700 transition-all">
                  Update Health Profile
                </button>
              </div>
            )}

            {/* Content: Session Logs (START BOOKING) */}
            {activeModal === 'history' && (
              <div className="space-y-6">
                <div className="bg-blue-50 dark:bg-blue-900/10 p-6 rounded-[2rem] border-2 border-dashed border-blue-200">
                  <p className="text-[10px] font-black uppercase text-blue-600 mb-4 tracking-widest">Start New Booking</p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-3">
                    {/* Doctor Search Field */}
                    <div className="relative">
                      <input 
                        list="doctor-accounts"
                        type="text" 
                        placeholder="Search Doctor Account..." 
                        className="w-full p-3 rounded-xl border dark:bg-slate-800 text-sm focus:border-blue-600 outline-none"
                        onChange={(e)=>setNewItem({...newItem, doctor: e.target.value, status: "Scheduled", date: new Date().toLocaleDateString()})} 
                      />
                      <datalist id="doctor-accounts">
                        {availableDoctors.map((doc, index) => (
                          <option key={index} value={doc.name}>{doc.specialty}</option>
                        ))}
                      </datalist>
                      <FaSearch className="absolute right-3 top-4 text-slate-300 pointer-events-none" />
                    </div>

                    {/* Internal Medicine Specialities */}
                    <select className="p-3 rounded-xl border dark:bg-slate-800 text-sm focus:border-blue-600 outline-none" onChange={(e)=>setNewItem({...newItem, clinic: e.target.value})}>
                      <option value="">Internal Medicine Clinic</option>
                      <option>General Internal Medicine</option>
                      <option>Gastroenterology & Hepatology</option>
                      <option>Nephrology (Kidney)</option>
                      <option>Endocrinology (Diabetes)</option>
                      <option>Rheumatology</option>
                    </select>
                  </div>
                  <button onClick={() => handleAddItem('history')} className="w-full bg-blue-600 text-white py-3 rounded-xl font-black text-xs uppercase flex items-center justify-center gap-2 hover:bg-blue-700 transition-all"><FaCalendarAlt/> Confirm Appointment</button>
                </div>
                
                {medicalRecords.history.length === 0 ? <EmptyState msg="No bookings yet" /> : medicalRecords.history.map(item => (
                  <div key={item.id} className="p-5 border-4 border-slate-100 dark:border-slate-800 rounded-2xl flex justify-between items-center group hover:border-blue-600 transition-all">
                    <div>
                      <p className="text-[10px] font-black text-blue-600 uppercase mb-1">{item.date}</p>
                      <h4 className="font-black text-slate-900 dark:text-white uppercase leading-none">{item.doctor}</h4>
                      <p className="text-[10px] text-slate-500 font-bold mt-1 uppercase italic">{item.clinic}</p>
                    </div>
                    <span className="bg-blue-100 text-blue-600 text-[10px] font-black px-3 py-1 rounded-full uppercase">{item.status}</span>
                  </div>
                ))}
              </div>
            )}

            {/* Content: Lab Results Form */}
            {activeModal === 'labs' && (
              <div className="space-y-6">
                <div className="bg-slate-100 dark:bg-slate-800/50 p-6 rounded-[2rem] space-y-4">
                  <div className="grid grid-cols-2 gap-3">
                    <select className="p-3 rounded-xl border dark:bg-slate-700 text-sm" onChange={(e)=>setNewItem({...newItem, name: e.target.value, date: new Date().toLocaleDateString()})}>
                      <option>Test Type</option>
                      <option>Complete Blood Count (CBC)</option>
                      <option>Blood Glucose</option>
                      <option>Liver Function</option>
                      <option>Lipid Profile</option>
                    </select>
                    <input type="text" placeholder="Result (e.g. 110 mg/dL)" className="p-3 rounded-xl border dark:bg-slate-700 text-sm" onChange={(e)=>setNewItem({...newItem, result: e.target.value})} />
                  </div>
                  <button onClick={() => handleAddItem('labs')} className="w-full bg-slate-900 dark:bg-blue-600 text-white py-3 rounded-xl font-black text-xs uppercase transition-all hover:scale-[1.02]"><FaPlus/> Save Analysis</button>
                </div>
                {medicalRecords.labs.length === 0 ? <EmptyState msg="No lab records" /> : medicalRecords.labs.map(lab => (
                  <div key={lab.id} className="p-6 bg-slate-50 dark:bg-slate-800/30 rounded-3xl flex justify-between items-center border-2 border-transparent hover:border-blue-600 transition-all">
                    <div>
                      <h4 className="font-black text-slate-900 dark:text-white text-sm uppercase">{lab.name}</h4>
                      <p className="text-[11px] font-black text-blue-600 mt-1 uppercase italic">Value: {lab.result}</p>
                    </div>
                    <FaFlask className="text-slate-300" />
                  </div>
                ))}
              </div>
            )}

            {/* Content: Prescription Form */}
            {activeModal === 'prescriptions' && (
              <div className="space-y-6">
                <div className="bg-red-50 dark:bg-red-900/5 p-6 rounded-[2rem] border-2 border-red-100">
                  <input type="text" placeholder="Medication Name (e.g. Augmentin 1g)" className="w-full p-3 rounded-xl border dark:bg-slate-800 text-sm mb-3" onChange={(e)=>setNewItem({...newItem, med: e.target.value})} />
                  <div className="grid grid-cols-2 gap-3 mb-3">
                    <input type="text" placeholder="Dose (e.g. 2/day)" className="p-3 rounded-xl border dark:bg-slate-800 text-sm" onChange={(e)=>setNewItem({...newItem, dose: e.target.value})} />
                    <input type="text" placeholder="Duration (e.g. 7 days)" className="p-3 rounded-xl border dark:bg-slate-800 text-sm" onChange={(e)=>setNewItem({...newItem, duration: e.target.value})} />
                  </div>
                  <button onClick={() => handleAddItem('prescriptions')} className="w-full bg-red-600 text-white py-3 rounded-xl font-black text-xs uppercase hover:bg-red-700 transition-all"><FaPlus/> Add to Treatment Plan</button>
                </div>
                {medicalRecords.prescriptions.length === 0 ? <EmptyState msg="No active prescriptions" /> : medicalRecords.prescriptions.map(p => (
                  <div key={p.id} className="p-6 border-l-8 border-red-500 bg-slate-50 dark:bg-slate-800/50 rounded-2xl relative overflow-hidden">
                    <div className="absolute right-[-10px] top-[-10px] text-red-500/5 text-6xl rotate-12"><FaFileMedicalAlt /></div>
                    <h4 className="font-black text-slate-900 dark:text-white uppercase italic">{p.med}</h4>
                    <div className="flex gap-4 mt-2">
                      <p className="text-[10px] font-black text-slate-500 uppercase flex items-center gap-1"><FaCalendarAlt size={10}/> {p.dose}</p>
                      <p className="text-[10px] font-black text-blue-600 uppercase italic">⏱ {p.duration}</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {/* --- Rest of Layout --- */}
      <div className="max-w-6xl mx-auto flex justify-between items-center mb-16">
        <button onClick={() => navigate(-1)} className="group flex items-center gap-3 font-black uppercase italic text-[10px] tracking-[0.3em] text-slate-500 hover:text-blue-600">
          <div className="p-2 border-2 border-slate-200 dark:border-slate-800 rounded-lg group-hover:border-blue-600 transition-colors"><FaArrowLeft /></div>
          Back to Core
        </button>
        <button onClick={() => { localStorage.clear(); navigate('/login'); }} className="bg-red-50 text-red-600 px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-red-600 hover:text-white transition-all">
          <FaSignOutAlt /> Terminate
        </button>
      </div>

      <div className="max-w-6xl mx-auto">
        <header className="mb-20 flex flex-col md:flex-row md:items-end justify-between gap-8">
          <div>
            <div className="flex items-center gap-4 mb-4">
              <span className="h-[2px] w-12 bg-blue-600"></span>
              <span className="text-blue-600 font-black text-[10px] uppercase tracking-[0.4em]">Integrated Health System</span>
            </div>
            <h1 className="text-6xl md:text-9xl font-black italic tracking-tighter text-slate-900 dark:text-white uppercase leading-[0.8]">
              {userData.username} <br/>
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-indigo-600 not-italic">Dashboard.</span>
            </h1>
          </div>
          
          <div className="relative group">
            <input type="file" accept="image/*" onChange={handleImageUpload} className="hidden" id="profilePic" />
            <label htmlFor="profilePic" className="cursor-pointer block relative">
              <div className="w-32 h-32 md:w-44 md:h-44 bg-slate-200 dark:bg-slate-800 rounded-[2.5rem] border-[6px] border-[var(--text-main)] dark:border-white overflow-hidden shadow-[12px_12px_0px_0px_#2563eb]">
                {userData.profileImg ? <img src={userData.profileImg} alt="Profile" className="w-full h-full object-cover transition-transform group-hover:scale-110" /> : <div className="w-full h-full flex items-center justify-center text-slate-400"><FaCamera size={40} /></div>}
              </div>
              <div className="absolute -bottom-2 -right-2 bg-blue-600 text-white p-3 rounded-xl border-4 border-white dark:border-slate-950 group-hover:scale-110 transition-transform"><FaCamera size={14} /></div>
            </label>
          </div>
        </header>

        <div className="grid grid-cols-12 gap-8">
          <div className="col-span-12 lg:col-span-7 space-y-8">
            <div className="bg-[var(--bg-card)] dark:bg-slate-900 border-[6px] border-[var(--text-main)] dark:border-white p-10 rounded-[3.5rem] shadow-[20px_20px_0px_0px_#0B8ED9] relative overflow-hidden">
              <div className="absolute top-[-20px] right-[-20px] text-[12rem] text-slate-50 dark:text-slate-800 font-black -z-0 opacity-40 italic select-none">ID</div>
              <div className="relative z-10 space-y-10">
                <div className="flex justify-between items-start">
                   <div className="w-20 h-20 bg-[#0B8ED9] dark:bg-blue-600 rounded-[2rem] flex items-center justify-center text-white text-3xl shadow-xl"><FaIdCard /></div>
                   <div className="text-right">
                     <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.3em]">Patient-UID</p>
                     <p className="font-mono font-bold dark:text-white uppercase text-xl">{userData.insuranceId}</p>
                   </div>
                </div>
                <div className="grid grid-cols-2 gap-10">
                  <InfoBlock label="Full Name" value={userData.username} />
                  <InfoBlock label="Blood Group" value={userData.bloodType} icon={<FaTint className="text-red-500" />} />
                  <InfoBlock label="Allergies" value={userData.allergies} />
                  <InfoBlock label="Status" value="Verified Account" highlight />
                </div>
              </div>
            </div>

            <div className="grid grid-cols-3 gap-6">
              <StatBox label="Weight" value={userData.weight} unit="kg" />
              <StatBox label="Height" value={userData.height} unit="cm" />
              <StatBox label="BMI Score" value={((userData.weight / ((userData.height/100)**2)).toFixed(1))} />
            </div>
          </div>

          <div className="col-span-12 lg:col-span-5 space-y-5">
            <h3 className="text-[10px] font-black uppercase tracking-[0.5em] text-slate-400 ml-4 mb-2">Clinical Management</h3>
            <EnhancedActionBtn onClick={() => { setTempData(userData); setActiveModal('edit'); }} icon={<FaUserEdit />} title="Vital Parameters" sub="Edit physical data" />
            <EnhancedActionBtn onClick={() => setActiveModal('history')} icon={<FaStethoscope />} title="Start Booking" sub="Log clinical visits" color="blue" />
            <EnhancedActionBtn onClick={() => setActiveModal('labs')} icon={<FaFlask />} title="Laboratory Results" sub="Manual lab entry" />
            <EnhancedActionBtn onClick={() => setActiveModal('prescriptions')} icon={<FaFileMedicalAlt />} title="Treatment Plan" sub="Active medications" />
          </div>
        </div>
      </div>
    </div>
  );
}

// --- Helper UI Components ---
function EmptyState({ msg }) {
  return (
    <div className="py-10 text-center border-2 border-dashed border-slate-200 dark:border-slate-800 rounded-3xl">
      <p className="text-xs font-black uppercase text-slate-400 italic tracking-widest">{msg}</p>
    </div>
  );
}

function InputGroup({ label, value, onChange }) {
  return (
    <div className="space-y-2">
      <label className="text-[10px] font-black uppercase tracking-widest text-slate-400">{label}</label>
      <input type="text" value={value} onChange={(e) => onChange(e.target.value)}
        className="w-full bg-slate-50 dark:bg-slate-800 border-2 border-slate-200 dark:border-slate-700 p-4 rounded-xl font-bold dark:text-white focus:border-blue-600 outline-none transition-all"
      />
    </div>
  );
}

function InfoBlock({ label, value, icon, highlight }) {
  return (
    <div className="space-y-1">
      <p className="text-[9px] font-black uppercase text-slate-400 tracking-[0.2em] flex items-center gap-2">{icon} {label}</p>
      <p className={`text-lg font-black uppercase italic tracking-tighter ${highlight ? 'text-blue-600' : 'text-slate-900 dark:text-white'}`}>{value}</p>
    </div>
  );
}

function StatBox({ label, value, unit }) {
  return (
    <div className="bg-slate-100 dark:bg-slate-800/50 p-6 rounded-[2.5rem] border-2 border-transparent hover:border-slate-900 dark:hover:border-white transition-all text-center">
      <p className="text-[9px] font-black uppercase text-slate-400 tracking-widest mb-1">{label}</p>
      <p className="text-3xl font-black italic text-slate-900 dark:text-white">
        {value}<span className="text-xs ml-1 opacity-50 not-italic">{unit}</span>
      </p>
    </div>
  );
}

function EnhancedActionBtn({ icon, title, sub, color, onClick }) {
  const isBlue = color === 'blue';
  return (
    <button onClick={onClick} className={`w-full group p-6 rounded-[2.5rem] border-4 border-[var(--text-main)] dark:border-white flex items-center justify-between transition-all hover:-translate-y-1 hover:shadow-[12px_12px_0px_0px_#2563eb] ${isBlue ? 'bg-blue-600 text-white border-blue-700' : 'bg-[var(--bg-card)] dark:bg-slate-900 text-[var(--text-main)]'}`}>
      <div className="flex items-center gap-5">
        <div className={`w-12 h-12 rounded-2xl flex items-center justify-center text-xl transition-transform group-hover:rotate-12 ${isBlue ? 'bg-white/20' : 'bg-slate-100 dark:bg-slate-800 text-blue-600'}`}>{icon}</div>
        <div className="text-left">
          <p className="font-black uppercase italic text-sm leading-none mb-1">{title}</p>
          <p className={`text-[9px] font-bold uppercase opacity-60 ${isBlue ? 'text-white' : ''}`}>{sub}</p>
        </div>
      </div>
      <FaPlus className="opacity-0 group-hover:opacity-100 transition-all" />
    </button>
  );
}