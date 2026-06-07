using System.Net;
using System.Net.Http.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;
using Clinic_Project.Services.Implementations;
using Clinic_Project.Dtos.AI;
using Clinic_Project.Helpers;

namespace Clinic_Project.Tests
{
    /// <summary>
    /// Integration Test to verify real communication between .NET and FastAPI.
    /// Requirements: FastAPI service must be running at http://localhost:8000
    /// </summary>
    public class AIIntegrationTests
    {
        private readonly AIService _aiService;
        private const string RealApiKey = "clinic_secret_key_2024";

        public AIIntegrationTests()
        {
            // Build real configuration for Integration Test
            var inMemorySettings = new Dictionary<string, string?> {
                {"AIService:BaseUrl", "http://localhost:8000"},
                {"AIService:ApiKey", RealApiKey}
            };
            IConfiguration configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(inMemorySettings)
                .Build();

            // Use a real HttpClient but we need to ensure it has the correct headers
            // In AIService, it doesn't currently add the header automatically from config
            // So we will pass an HttpClient that already has the header for this test.
            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("X-API-Key", RealApiKey);

            var mockLogger = new Mock<ILogger<AIService>>();

            _aiService = new AIService(httpClient, configuration, mockLogger.Object);
        }

        [Fact]
        public async Task RealApi_PredictDiabetes_ReturnsSuccess()
        {
            // 1. Arrange
            var request = new PredictionRequestDto 
            { 
                Disease = DiseaseType.diabetes, 
                Data = new Dictionary<string, object> 
                { 
                    { "HbA1c_level", 6.5 },
                    { "blood_glucose_level", 150 },
                    { "age", 55.0 },
                    { "bmi", 28.5 },
                    { "smoking_history", "never" },
                    { "hypertension", 0 },
                    { "gender", "Female" },
                    { "heart_disease", 0 }
                } 
            };

            // 2. Act
            var result = await _aiService.PredictAsync(request);

            // 3. Assert
            Assert.True(result.Success, $"API failed: {result.ErrorMessage}");
            Assert.NotNull(result.Data);
            Assert.Contains("Likely", result.Data!.Label);
        }

        [Fact]
        public async Task RealApi_HealthCheck_ReturnsOk()
        {
            // Act
            var result = await _aiService.GetHealthAsync();

            // Assert
            Assert.True(result.Success);
            Assert.Equal("ok", result.Data!.Status);
        }
    }
}
