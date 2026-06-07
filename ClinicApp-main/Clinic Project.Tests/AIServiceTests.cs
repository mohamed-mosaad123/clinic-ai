using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using Moq.Protected;
using Xunit;
using Clinic_Project.Services.Implementations;
using Clinic_Project.Dtos.AI;
using Clinic_Project.Helpers;

namespace Clinic_Project.Tests
{
    public class AIServiceTests
    {
        [Fact]
        public async Task PredictAsync_ReturnsSuccessResult_WhenApiCallIsSuccessful()
        {
            // 1. Arrange
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            var responseDto = new PredictionResponseDto 
            { 
                Disease = "diabetes", 
                Probability = 0.85,
                Label = "Likely DISEASED ⚠",
                Prediction = 1,
                RiskDescription = "High Risk",
                RiskLevel = "high"
            };

            // Mock the HttpClient response
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>()
                )
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(JsonSerializer.Serialize(responseDto))
                });

            var httpClient = new HttpClient(mockHttpMessageHandler.Object);

            // Mock Configuration
            var inMemorySettings = new Dictionary<string, string?> {
                {"AIService:BaseUrl", "http://localhost:8000"}
            };
            IConfiguration configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(inMemorySettings)
                .Build();

            // Mock Logger
            var mockLogger = new Mock<ILogger<AIService>>();

            var service = new AIService(httpClient, configuration, mockLogger.Object);

            var request = new PredictionRequestDto 
            { 
                Disease = DiseaseType.diabetes, 
                Data = new Dictionary<string, object> { { "age", 50 } } 
            };

            // 2. Act
            var result = await service.PredictAsync(request);

            // 3. Assert
            Assert.True(result.Success);
            Assert.NotNull(result.Data);
            Assert.Equal("Likely DISEASED ⚠", result.Data!.Label);
            Assert.Equal(0.85, result.Data.Probability);
        }

        [Fact]
        public async Task PredictAsync_ReturnsFailResult_WhenApiCallFails()
        {
            // 1. Arrange
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>()
                )
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.ServiceUnavailable,
                    Content = new StringContent("Model not found")
                });

            var httpClient = new HttpClient(mockHttpMessageHandler.Object);

            var inMemorySettings = new Dictionary<string, string?> {
                {"AIService:BaseUrl", "http://localhost:8000"}
            };
            IConfiguration configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(inMemorySettings)
                .Build();

            var mockLogger = new Mock<ILogger<AIService>>();

            var service = new AIService(httpClient, configuration, mockLogger.Object);

            var request = new PredictionRequestDto 
            { 
                Disease = DiseaseType.heart, 
                Data = new Dictionary<string, object>() 
            };

            // 2. Act
            var result = await service.PredictAsync(request);

            // 3. Assert
            Assert.False(result.Success);
            Assert.Equal(enErrorType.BadRequest, result.ErrorType);
            Assert.Contains("AI service error", result.ErrorMessage);
        }
    }
}
