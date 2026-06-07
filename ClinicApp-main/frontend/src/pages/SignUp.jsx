import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { FaEnvelope, FaLock, FaUser, FaEye, FaEyeSlash } from "react-icons/fa";
import { authService } from "../services/api";

export default function SignUp() {
  const navigate = useNavigate();
  
  const [formData, setFormData] = useState({
    username: "",
    email: "",
    password: "",
    confirmPassword: ""
  });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  
  const [showPassword, setShowPassword] = useState(false);

  const handleSignUp = async (e) => {
    e.preventDefault();
    setError("");

    if (formData.password !== formData.confirmPassword) {
      setError("Passwords do not match!");
      return;
    }

    setLoading(true);
    try {
      // Split username into first and last name for the backend's Person object
      const nameParts = formData.username.trim().split(" ");
      const firstName = nameParts[0] || "User";
      const lastName = nameParts.slice(1).join(" ") || "Patient";

      const payload = {
        UserName: formData.username.replace(/\s+/g, '_').toLowerCase(),
        Email: formData.email,
        Password: formData.password,
        PhoneNumber: "01000000000", // Default
        Person: {
          FirstName: firstName,
          LastName: lastName,
          DateOfBirth: "1990-01-01", // Default for registration
          Gender: 0, // Male by default
          Address: "Cairo" // Default
        }
      };

      await authService.register(payload);

      alert("Account Created Successfully!");
      navigate("/login");
    } catch (err) {
      console.error("Signup Error Details:", err.response?.data);
      let errorMessage = "Registration failed. Try again.";
      
      if (err.response?.data?.errors) {
        // Handle ASP.NET Core validation errors
        errorMessage = Object.values(err.response.data.errors).flat().join(", ");
      } else if (err.response?.data) {
        errorMessage = typeof err.response.data === 'string' ? err.response.data : JSON.stringify(err.response.data);
      }
      
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F3F4F6] flex flex-col items-center justify-center p-4 font-sans transition-all duration-300">
      
      <div className="w-full max-w-md bg-white rounded-[2.5rem] p-10 shadow-sm border border-gray-100 flex flex-col items-center">
        
        {/* Logo */}
        <div className="flex items-center gap-3 mb-8">
          <h1 className="text-3xl font-black text-[#0B8ED9] tracking-tighter uppercase">HEALIX</h1>
        </div>

        <h2 className="text-2xl font-bold text-[var(--text-main)] mb-8 text-center">Create Account</h2>

        <form onSubmit={handleSignUp} className="w-full space-y-5">
          
          {/* Full Name */}
          <div className="space-y-2">
            <label className="text-[11px] font-bold text-black ml-1 uppercase tracking-tight">Full Name</label>
            <div className="relative">
              <FaUser className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-400" />
              <input 
                type="text" 
                placeholder="Meky Khaled"
                value={formData.username}
                onChange={(e) => setFormData({...formData, username: e.target.value})}
                className="w-full border-2 border-slate-200 dark:border-white/20 rounded-2xl py-4 pl-14 pr-6 text-[var(--text-main)] font-semibold outline-none focus:border-[#0B8ED9] transition-all placeholder:text-gray-300 bg-white dark:bg-slate-800"
                required
              />
            </div>
          </div>

          {/* Email Address */}
          <div className="space-y-2">
            <label className="text-[11px] font-bold text-black ml-1 uppercase tracking-tight">Email Address</label>
            <div className="relative">
              <FaEnvelope className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-400" />
              <input 
                type="email" 
                placeholder="example@email.com"
                value={formData.email}
                onChange={(e) => setFormData({...formData, email: e.target.value})}
                className="w-full border-2 border-black rounded-2xl py-4 pl-14 pr-6 text-black font-semibold outline-none focus:border-[#0B8ED9] transition-all placeholder:text-gray-300"
                required
              />
            </div>
          </div>

          {/* Password */}
          <div className="space-y-2">
            <label className="text-[11px] font-bold text-black ml-1 uppercase tracking-tight">Password</label>
            <div className="relative">
              <FaLock className="absolute left-5 top-1/2 -translate-y-1/2 text-gray-400" />
              <input 
                type={showPassword ? "text" : "password"} 
                placeholder="********"
                value={formData.password}
                onChange={(e) => setFormData({...formData, password: e.target.value})}
                className="w-full border-2 border-black rounded-2xl py-4 pl-14 pr-14 text-black font-semibold outline-none focus:border-[#0B8ED9] transition-all placeholder:text-gray-300"
                required
              />
              <button 
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-black"
              >
                {showPassword ? <FaEyeSlash size={18} /> : <FaEye size={18} />}
              </button>
            </div>
          </div>

          {/* Confirm Password */}
          <div className="space-y-2">
            <label className="text-[11px] font-bold text-black ml-1 uppercase tracking-tight">Confirm Password</label>
            <div className="relative">
              <input 
                type="password" 
                placeholder="********"
                value={formData.confirmPassword}
                onChange={(e) => setFormData({...formData, confirmPassword: e.target.value})}
                className="w-full border-2 border-black rounded-2xl py-4 px-6 text-black font-semibold outline-none focus:border-[#0B8ED9] transition-all placeholder:text-gray-300"
                required
              />
            </div>
          </div>

          {/* Error Message */}
          {error && (
            <div className="p-3 bg-red-50 border-l-4 border-red-500 rounded-lg w-full">
              <p className="text-xs text-red-600 font-bold uppercase">{error}</p>
            </div>
          )}

          <button 
            type="submit" 
            disabled={loading}
            className={`w-full ${loading ? 'bg-gray-400' : 'bg-[#0B8ED9]'} text-white font-black py-4 rounded-2xl mt-4 shadow-lg active:scale-[0.98] transition-all text-lg uppercase tracking-wider`}
          >
            {loading ? "Creating Account..." : "Sign Up"}
          </button>
        </form>

        <p className="mt-8 text-sm text-gray-500 font-medium">
          Already have an account?{" "}
          <Link to="/login" className="text-[#0B8ED9] font-black hover:underline transition-all">
            Log in
          </Link>
        </p>
      </div>
    </div>
  );
}