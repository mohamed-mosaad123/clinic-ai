import { useNavigate, Link } from "react-router-dom";
import { FaUserInjured, FaUserMd, FaArrowLeft } from "react-icons/fa"; 
import fullLogo from "../assets/full logo update.jpg";

export default function RoleSelection() {
    const navigate = useNavigate();

    // Handle role selection logic
    const handleRoleSelect = (role) => {
        // Store selected role (patient or doctor) for Login page differentiation
        localStorage.setItem("selectedRole", role);
        
        // Redirect to appropriate page based on choice
        if (role === "patient") {
            navigate("/signup");
        } else {
            navigate("/doctor-signup");
        }
    };

    return (
        <div className="min-h-screen bg-[var(--bg-app)] flex items-center justify-center px-4 transition-all duration-300">
            <div className="bg-[var(--bg-card)] w-full max-w-[500px] p-10 rounded-[2.5rem] shadow-2xl shadow-blue-100/50 border border-[var(--border)]">

                {/* Header with Back button */}
                <div className="relative mb-8">
                    <button 
                        onClick={() => navigate("/")} 
                        className="absolute left-0 top-1/2 -translate-y-1/2 p-2 text-gray-400 hover:text-[#0B8ED9] hover:bg-blue-50 rounded-full transition-all"
                    >
                        <FaArrowLeft size={18} />
                    </button>
                    <div className="flex justify-center">
                        <img src={fullLogo} alt="Healix Logo" className="h-24 object-contain" />
                    </div>
                </div>

                <div className="text-center mb-10">
                    <h2 className="text-2xl font-bold text-gray-800 tracking-tight">Choose Your Path</h2>
                    <p className="text-gray-500 mt-2 font-medium">Are you seeking care or providing it?</p>
                </div>

                <div className="flex flex-col sm:flex-row gap-5 justify-center">
                    {/* Patient Card */}
                    <button
                        onClick={() => handleRoleSelect("patient")} // Selection update
                        className="flex-1 group relative flex flex-col items-center justify-center p-8 border-2 border-gray-100 rounded-[2rem] bg-white hover:border-[#0B8ED9] hover:bg-blue-50/30 transition-all duration-500 shadow-sm hover:shadow-xl hover:-translate-y-2"
                    >
                        <div className="w-16 h-16 bg-blue-100 text-[#0B8ED9] rounded-2xl flex items-center justify-center mb-4 group-hover:bg-[#0B8ED9] group-hover:text-white transition-all duration-500">
                            <FaUserInjured size={28} />
                        </div>
                        <span className="text-xl font-bold text-gray-700 group-hover:text-[#0B8ED9]">Patient</span>
                        <p className="text-[10px] text-center text-gray-400 mt-2 opacity-0 group-hover:opacity-100 transition-opacity">Track health & AI diagnosis</p>
                    </button>

                    {/* Doctor Card */}
                    <button
                        onClick={() => handleRoleSelect("doctor")} // Selection update
                        className="flex-1 group relative flex flex-col items-center justify-center p-8 border-2 border-gray-100 rounded-[2rem] bg-white hover:border-[#0B8ED9] hover:bg-blue-50/30 transition-all duration-500 shadow-sm hover:shadow-xl hover:-translate-y-2"
                    >
                        <div className="w-16 h-16 bg-blue-100 text-[#0B8ED9] rounded-2xl flex items-center justify-center mb-4 group-hover:bg-[#0B8ED9] group-hover:text-white transition-all duration-500">
                            <FaUserMd size={28} />
                        </div>
                        <span className="text-xl font-bold text-gray-700 group-hover:text-[#0B8ED9]">Doctor</span>
                        <p className="text-[10px] text-center text-gray-400 mt-2 opacity-0 group-hover:opacity-100 transition-opacity">Manage patients & insights</p>
                    </button>
                </div>

                <p className="text-center mt-12 text-gray-500 text-sm font-semibold">
                    Already have an account?{" "}
                    <Link to="/login" className="text-[#0B8ED9] font-bold hover:underline transition-colors">
                        Log in
                    </Link>
                </p>
            </div>
        </div>
    );
}