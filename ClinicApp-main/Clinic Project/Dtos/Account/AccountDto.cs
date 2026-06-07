namespace Clinic_Project.Dtos.Account
{
    public class AccountDto
    {
        public string Id { get; set; } = string.Empty;          
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public int? PatientId { get; set; }
        public int? DoctorId { get; set; }
        public Clinic_Project.Dtos.Person.enGender? Gender { get; set; }
        public List<string>? Roles { get; set; }
    }
}
