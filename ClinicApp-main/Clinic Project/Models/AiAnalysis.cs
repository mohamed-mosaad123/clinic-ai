using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Clinic_Project.Models
{
    public class AiAnalysis
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Patient))]
        public int PatientId { get; set; }
        public Patient? Patient { get; set; }

        [Required]
        [MaxLength(100)]
        public string Disease { get; set; } = string.Empty;

        public int Prediction { get; set; }

        public double Probability { get; set; }

        [MaxLength(50)]
        public string RiskLevel { get; set; } = string.Empty;

        [MaxLength(50)]
        public string StatusLevel { get; set; } = string.Empty;

        public string RiskDescription { get; set; } = string.Empty;

        public string InputsJson { get; set; } = "{}";

        [MaxLength(50)]
        public string? ModelVersion { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
