import { Link, useNavigate } from "react-router-dom";
import { authService } from "../services/api";
import {
  FaArrowLeft,
  FaUserMd,
  FaEnvelope,
  FaIdCard,
  FaEye,
  FaEyeSlash,
  FaCalendarAlt,
  FaLock,
} from "react-icons/fa";
import { useState } from "react";
import fullLogo from "../assets/full logo update.jpg";

export default function DoctorSignUp() {
  const navigate = useNavigate();
  const [showPass, setShowPass] = useState(false);
  
  const [formData, setFormData] = useState({
    username: "",
    email: "",
    licenseNumber: "",
    dob: "",
    password: "",
    verifyPassword: ""
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (formData.password !== formData.verifyPassword) {
      alert("Passwords do not match!");
      return;
    }

    try {
      await authService.registerDoctor({
        username: formData.username,
        email: formData.email,
        password: formData.password,
        dob: formData.dob,
        specializationId: parseInt(formData.specializationId || "1")
      });

      alert("Practitioner Account Created Successfully! Please Login.");
      navigate("/login");
    } catch (err) {
      alert("Registration failed: " + (err.message || "Server error"));
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-6">
      <div className="w-full max-w-[540px] bg-white rounded-[2.5rem] shadow-2xl shadow-blue-100/50 overflow-hidden border border-gray-100">

        {/* Header */}
        <div className="p-8 pb-4 flex items-center justify-between border-b border-gray-50">
          <button 
            onClick={() => navigate("/select-role")} 
            className="p-2.5 text-gray-400 hover:text-[#0B8ED9] hover:bg-blue-50 rounded-full transition-all"
          >
            <FaArrowLeft size={18} />
          </button>
          <img src={fullLogo} alt="Healix Logo" className="h-14 object-contain" />
          <div className="w-10"></div>
        </div>

        <div className="px-10 pb-10 pt-6">
          <div className="text-center mb-8">
            <h2 className="text-3xl font-extrabold text-gray-800 tracking-tight">
              Practitioner Portal
            </h2>
            <p className="text-gray-500 mt-2 font-medium">
              Empower your practice with Healix AI
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Full Name */}
            <div className="group">
              <label className="block mb-1.5 text-sm font-bold text-gray-700 ml-1 uppercase">Full Name</label>
              <div className="relative">
                <FaUserMd className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#0B8ED9] transition-colors" />
                <input
                  type="text"
                  name="username"
                  required
                  placeholder="Dr. Meky Khaled"
                  className="w-full py-3.5 pl-12 pr-4 bg-gray-50 border border-gray-200 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-400/50 focus:bg-white transition-all shadow-sm font-semibold"
                  onChange={handleChange}
                />
              </div>
            </div>

            {/* Email & License - Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="group">
                <label className="block mb-1.5 text-sm font-bold text-gray-700 ml-1 uppercase text-[11px]">Email Address</label>
                <div className="relative">
                  <FaEnvelope className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#0B8ED9]" />
                  <input
                    type="email"
                    name="email"
                    required
                    placeholder="jane@clinic.com"
                    className="w-full py-3.5 pl-11 pr-4 bg-gray-50 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all shadow-sm font-semibold"
                    onChange={handleChange}
                  />
                </div>
              </div>
              <div className="group">
                <label className="block mb-1.5 text-sm font-bold text-gray-700 ml-1 uppercase text-[11px]">License No.</label>
                <div className="relative">
                  <FaIdCard className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#0B8ED9]" />
                  <input
                    type="text"
                    name="licenseNumber"
                    required
                    placeholder="ID-123456"
                    className="w-full py-3.5 pl-11 pr-4 bg-gray-50 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all shadow-sm font-semibold"
                    onChange={handleChange}
                  />
                </div>
              </div>
            </div>

            {/* Specialization & Date of Birth */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="group">
                <label className="block mb-1.5 text-sm font-bold text-gray-700 ml-1 uppercase text-[11px]">Specialization</label>
                <div className="relative">
                  <FaUserMd className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#0B8ED9]" />
                  <select
                    name="specializationId"
                    required
                    className="w-full py-3.5 pl-11 pr-4 bg-gray-50 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all shadow-sm font-semibold appearance-none"
                    onChange={handleChange}
                  >
                    <option value="1">Cardiology</option>
                    <option value="2">Pediatrics</option>
                    <option value="3">Neurology</option>
                    <option value="4">Internal Medicine</option>
                  </select>
                </div>
              </div>
              <div className="group">
                <label className="block mb-1.5 text-sm font-bold text-gray-700 ml-1 uppercase text-[11px]">Date of Birth</label>
                <div className="relative">
                  <FaCalendarAlt className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#0B8ED9]" />
                  <input
                    type="date"
                    name="dob"
                    required
                    className="w-full py-3.5 pl-11 pr-4 bg-gray-50 border border-gray-200 rounded-2xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all shadow-sm font-semibold text-gray-500"
                    onChange={handleChange}
                  />
                </div>
              </div>
            </div>

            {/* Passwords - Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="group">
                <label className="block mb-1.5 text-sm font-bold text-gray-700 ml-1 uppercase text-[11px]">Password</label>
                <div className="relative">
                  <FaLock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#0B8ED9]" />
                  <input
                    type={showPass ? "text" : "password"}
                    name="password"
                    required
                    placeholder="••••••••"
                    className="w-full py-3.5 pl-11 pr-4 bg-gray-50 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all shadow-sm font-semibold"
                    onChange={handleChange}
                  />
                </div>
              </div>
              <div className="group">
                <label className="block mb-1.5 text-sm font-bold text-gray-700 ml-1 uppercase text-[11px]">Confirm</label>
                <div className="relative">
                  <FaLock className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-[#0B8ED9]" />
                  <input
                    type={showPass ? "text" : "password"}
                    name="verifyPassword"
                    required
                    placeholder="••••••••"
                    className="w-full py-3.5 pl-11 pr-12 bg-gray-50 border border-gray-200 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all shadow-sm font-semibold"
                    onChange={handleChange}
                  />
                  <button
                    type="button"
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-[#0B8ED9] p-1 transition-colors"
                    onClick={() => setShowPass(!showPass)}
                  >
                    {showPass ? <FaEyeSlash size={16} /> : <FaEye size={16} />}
                  </button>
                </div>
              </div>
            </div>

            <button 
              type="submit"
              className="w-full bg-[#0B8ED9] hover:bg-[#097bbd] active:scale-[0.98] transition-all text-white py-4 rounded-2xl font-black mt-4 shadow-lg shadow-blue-100 uppercase tracking-wider"
            >
              Complete Registration
            </button>

            <div className="pt-4 border-t border-gray-50 text-center">
              <p className="text-sm text-gray-600 font-medium">
                Already a member?{" "}
                <Link to="/login" className="text-[#0B8ED9] font-black hover:underline transition-all">
                  Login here
                </Link>
              </p>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}