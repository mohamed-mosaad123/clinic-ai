using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Clinic_Project.Dtos.AI
{
    public class AiAnalysisWriteDto
    {
        [Required]
        public int PatientId { get; set; }

        [Required]
        public string Disease { get; set; } = string.Empty;

        public int Prediction { get; set; }

        public double Probability { get; set; }

        public string RiskLevel { get; set; } = string.Empty;

        public string StatusLevel { get; set; } = string.Empty;

        public string RiskDescription { get; set; } = string.Empty;

        public Dictionary<string, object> Inputs { get; set; } = [];

        public string? ModelVersion { get; set; }
    }

    public class AiAnalysisReadDto
    {
        public int Id { get; set; }
        public int PatientId { get; set; }
        public string PatientName { get; set; } = string.Empty;
        public string Disease { get; set; } = string.Empty;
        public int Prediction { get; set; }
        public double Probability { get; set; }

        [JsonPropertyName("riskScore")]
        public double RiskScore => Probability;

        [JsonPropertyName("riskLevel")]
        public string RiskLevel { get; set; } = string.Empty;

        [JsonPropertyName("statusLevel")]
        public string StatusLevel { get; set; } = string.Empty;

        [JsonPropertyName("riskDescription")]
        public string RiskDescription { get; set; } = string.Empty;

        public Dictionary<string, object> Inputs { get; set; } = [];

        public string? ModelVersion { get; set; }

        [JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; }

        [JsonPropertyName("timestamp")]
        public string Timestamp => CreatedAt.ToString("o");
    }
}
