using Clinic_Project.Dtos.AI;
using Clinic_Project.Helpers;

namespace Clinic_Project.Services.Interfaces
{
    public interface IAIService
    {
        /// <summary>
        /// Send patient features to the FastAPI micro-service and return a prediction.
        /// </summary>
        Task<Result<PredictionResponseDto>> PredictAsync(PredictionRequestDto request);

        /// <summary>
        /// Ping the FastAPI /health endpoint.
        /// </summary>
        Task<Result<AIHealthResponseDto>> GetHealthAsync();
    }
}
