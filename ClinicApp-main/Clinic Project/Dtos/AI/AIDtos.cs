using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Clinic_Project.Dtos.AI
{
    // ── Request ──────────────────────────────────────────────────────────────

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum DiseaseType { diabetes, heart, kidney }

    public class PredictionRequestDto
    {
        [Required]
        [JsonPropertyName("disease")]
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public DiseaseType Disease { get; set; }

        /// <summary>
        /// Patient feature key-value pairs.
        /// Keys depend on the selected disease — refer to FastAPI /docs.
        /// </summary>
        [Required]
        [JsonPropertyName("data")]
        public Dictionary<string, object> Data { get; set; } = [];
    }

    // ── Response ─────────────────────────────────────────────────────────────

    public class PredictionResponseDto
    {
        [JsonPropertyName("disease")]
        public string Disease { get; set; } = string.Empty;

        /// <summary>0 = healthy, 1 = disease likely</summary>
        [JsonPropertyName("prediction")]
        public int Prediction { get; set; }

        [JsonPropertyName("probability")]
        public double Probability { get; set; }

        [JsonPropertyName("risk_level")]
        public string RiskLevel { get; set; } = string.Empty;

        [JsonPropertyName("risk_description")]
        public string RiskDescription { get; set; } = string.Empty;

        [JsonPropertyName("label")]
        public string Label { get; set; } = string.Empty;

        [JsonPropertyName("model_version")]
        public string ModelVersion { get; set; } = string.Empty;
    }

    // ── Health ───────────────────────────────────────────────────────────────

    public class AIHealthResponseDto
    {
        [JsonPropertyName("status")]
        public string Status { get; set; } = string.Empty;

        [JsonPropertyName("version")]
        public string Version { get; set; } = string.Empty;

        [JsonPropertyName("models_loaded")]
        public List<string> ModelsLoaded { get; set; } = [];
    }
}
