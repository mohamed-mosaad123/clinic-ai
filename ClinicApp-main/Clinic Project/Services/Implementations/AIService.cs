using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Clinic_Project.Dtos.AI;
using Clinic_Project.Helpers;
using Clinic_Project.Services.Interfaces;
using Microsoft.Extensions.Logging;

namespace Clinic_Project.Services.Implementations
{
    /// <summary>
    /// Communicates with the ClinicAI FastAPI micro-service via HTTP.
    ///
    /// The HttpClient is injected by the typed-client factory registered in
    /// Program.cs, which applies timeout and retry policies (Polly).
    /// </summary>
    public class AIService : IAIService
    {
        private readonly HttpClient    _http;
        private readonly IConfiguration _config;
        private readonly ILogger<AIService> _logger;

        private static readonly JsonSerializerOptions _jsonOpts = new()
        {
            PropertyNameCaseInsensitive = true,
            Converters = { new JsonStringEnumConverter() }
        };

        public AIService(
            HttpClient         http,
            IConfiguration     config,
            ILogger<AIService> logger)
        {
            _http   = http;
            _config = config;
            _logger = logger;

            // Base address from config; trailing slash required by HttpClient
            var baseUrl = _config["AIService:BaseUrl"]?.TrimEnd('/') + "/";
            _http.BaseAddress = new Uri(baseUrl ?? "http://localhost:8000/");

            // Add Security Header for FastAPI AI service
            var apiKey = _config["AIService:ApiKey"] ?? "clinic_secret_key_2024";
            _http.DefaultRequestHeaders.Add("x-api-key", apiKey);
        }

        // ── Predict ──────────────────────────────────────────────────────────

        public async Task<Result<PredictionResponseDto>> PredictAsync(PredictionRequestDto request)
        {
            try
            {
                _logger.LogInformation(
                    "Calling FastAPI /predict for disease={Disease}", request.Disease);

                var response = await _http.PostAsJsonAsync("api/v1/predict", request, _jsonOpts);

                if (!response.IsSuccessStatusCode)
                {
                    var errorBody = await response.Content.ReadAsStringAsync();
                    _logger.LogWarning(
                        "FastAPI returned {StatusCode}: {Body}",
                        (int)response.StatusCode, errorBody);

                    var errorType = response.StatusCode switch
                    {
                        HttpStatusCode.ServiceUnavailable => enErrorType.BadRequest,
                        HttpStatusCode.UnprocessableEntity => enErrorType.BadRequest,
                        _ => enErrorType.InternalServerError,
                    };

                    return Result<PredictionResponseDto>.Fail(
                        $"AI service error ({(int)response.StatusCode}): {errorBody}",
                        errorType);
                }

                var result = await response.Content
                    .ReadFromJsonAsync<PredictionResponseDto>(_jsonOpts);

                _logger.LogInformation(
                    "Prediction complete: disease={Disease} label={Label} prob={Prob:F4}",
                    result!.Disease, result.Label, result.Probability);

                return Result<PredictionResponseDto>.Ok(result);
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "Network error reaching FastAPI service");
                return Result<PredictionResponseDto>.Fail(
                    "Unable to reach the AI service. Please try again later.",
                    enErrorType.InternalServerError);
            }
            catch (TaskCanceledException)
            {
                _logger.LogWarning("FastAPI request timed out (disease={Disease})", request.Disease);
                return Result<PredictionResponseDto>.Fail(
                    "AI service request timed out.",
                    enErrorType.InternalServerError);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in AIService.PredictAsync");
                return Result<PredictionResponseDto>.Fail(
                    $"Internal error: {ex.Message}",
                    enErrorType.InternalServerError);
            }
        }

        // ── Health ───────────────────────────────────────────────────────────

        public async Task<Result<AIHealthResponseDto>> GetHealthAsync()
        {
            try
            {
                var response = await _http.GetAsync("api/v1/health");
                if (!response.IsSuccessStatusCode)
                    return Result<AIHealthResponseDto>.Fail("AI service is unhealthy.");

                var health = await response.Content
                    .ReadFromJsonAsync<AIHealthResponseDto>(_jsonOpts);

                return Result<AIHealthResponseDto>.Ok(health);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check to FastAPI failed");
                return Result<AIHealthResponseDto>.Fail(
                    "AI service health check failed.",
                    enErrorType.InternalServerError);
            }
        }
    }
}
