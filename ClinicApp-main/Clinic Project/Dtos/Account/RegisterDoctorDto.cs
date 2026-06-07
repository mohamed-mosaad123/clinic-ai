using Clinic_Project.Dtos.Person;
using System.ComponentModel.DataAnnotations;

namespace Clinic_Project.Dtos.Account
{
    public class RegisterDoctorDto : RegisterDto
    {
        [Required]
        public int SpecializationId { get; set; }
    }
}
