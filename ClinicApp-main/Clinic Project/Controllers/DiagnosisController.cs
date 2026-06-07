using Clinic_Project.Dtos.AI;
using Clinic_Project.Helpers;
using Clinic_Project.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Clinic_Project.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class DiagnosisController : ControllerBase
    {
        private readonly IAIService _aiService;
        private readonly IAiAnalysisService _aiAnalysisService;

        public DiagnosisController(IAIService aiService, IAiAnalysisService aiAnalysisService)
        {
            _aiService = aiService;
            _aiAnalysisService = aiAnalysisService;
        }

        /// <summary>
        /// Run a disease prediction via the FastAPI AI service.
        /// </summary>
        /// <remarks>
        /// Send the disease type and patient features. The backend forwards the
        /// request to the internal FastAPI micro-service and returns the result.
        ///
        /// **Diabetes features:** HbA1c_level, blood_glucose_level, age, bmi,
        /// smoking_history, hypertension, gender, heart_disease
        ///
        /// **Heart features:** HadAngina, ChestScan, HadStroke, DifficultyWalking,
        /// HadDiabetes, GeneralHealth, HadArthritis, PneumoVaxEver,
        /// RemovedTeeth, AgeCategory, SmokerStatus, BMI, HadKidneyDisease, HadCOPD
        ///
        /// **Kidney features:** age, bp, sg, al, su, rbc, pc, pcc, ba,
        /// bgr, bu, sc, sod, pot, hemo, pcv, wc, rc,
        /// htn, dm, cad, appet, pe, ane
        /// </remarks>
        [AllowAnonymous]
        [HttpPost("predict")]
        [ProducesResponseType(typeof(PredictionResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status503ServiceUnavailable)]
        public async Task<IActionResult> Predict([FromBody] PredictionRequestDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _aiService.PredictAsync(request);

            if (!result.Success)
            {
                return result.ErrorType switch
                {
                    Helpers.enErrorType.BadRequest => BadRequest(result.ErrorMessage),
                    _ => StatusCode(StatusCodes.Status503ServiceUnavailable, result.ErrorMessage),
                };
            }

            return Ok(result.Data);
        }

        /// <summary>
        /// Check whether the FastAPI AI service is reachable and which models are loaded.
        /// </summary>
        [HttpGet("health")]
        [ProducesResponseType(typeof(AIHealthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status503ServiceUnavailable)]
        public async Task<IActionResult> Health()
        {
            var result = await _aiService.GetHealthAsync();

            if (!result.Success)
                return StatusCode(StatusCodes.Status503ServiceUnavailable, result.ErrorMessage);

            return Ok(result.Data);
        }

        /// <summary>
        /// Save a patient's AI analysis result to the database.
        /// </summary>
        [HttpPost("analyses")]
        [Authorize(Roles = $"{RoleName.Patient},{RoleName.Admin}")]
        [ProducesResponseType(typeof(AiAnalysisReadDto), StatusCodes.Status201Created)]
        public async Task<IActionResult> SaveAnalysis([FromBody] AiAnalysisWriteDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var isAdmin = User.IsInRole(RoleName.Admin);
            var isPatient = User.IsInRole(RoleName.Patient);

            var result = await _aiAnalysisService.CreateAsync(dto, userId, isPatient, isAdmin);

            if (!result.Success)
            {
                return result.ErrorType switch
                {
                    enErrorType.Forbiden => Forbid(),
                    enErrorType.NotFound => NotFound(result.ErrorMessage),
                    _ => BadRequest(result.ErrorMessage),
                };
            }

            return CreatedAtAction(nameof(GetAnalysisById), new { id = result.Data!.Id }, result.Data);
        }

        /// <summary>
        /// Get all AI analyses for a specific patient (doctors and admins can view any patient).
        /// </summary>
        [HttpGet("analyses/patient/{patientId}")]
        [ProducesResponseType(typeof(IEnumerable<AiAnalysisReadDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAnalysesByPatient(int patientId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var isDoctor = User.IsInRole(RoleName.Doctor);
            var isAdmin = User.IsInRole(RoleName.Admin);

            var result = await _aiAnalysisService.GetByPatientIdAsync(patientId, userId, isDoctor, isAdmin);

            if (!result.Success)
            {
                return result.ErrorType switch
                {
                    enErrorType.Forbiden => Forbid(),
                    enErrorType.NotFound => NotFound(result.ErrorMessage),
                    _ => BadRequest(result.ErrorMessage),
                };
            }

            return Ok(result.Data);
        }

        /// <summary>
        /// Get all AI analyses across all patients (doctors and admins only).
        /// </summary>
        [HttpGet("analyses")]
        [Authorize(Roles = $"{RoleName.Doctor},{RoleName.Admin}")]
        [ProducesResponseType(typeof(IEnumerable<AiAnalysisReadDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllAnalyses()
        {
            var result = await _aiAnalysisService.GetAllAsync();
            return Ok(result.Data);
        }

        /// <summary>
        /// Get a single AI analysis by ID.
        /// </summary>
        [HttpGet("analyses/{id}")]
        [ProducesResponseType(typeof(AiAnalysisReadDto), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAnalysisById(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var isDoctor = User.IsInRole(RoleName.Doctor);
            var isAdmin = User.IsInRole(RoleName.Admin);

            var result = await _aiAnalysisService.GetByIdAsync(id, userId, isDoctor, isAdmin);

            if (!result.Success)
            {
                return result.ErrorType switch
                {
                    enErrorType.Forbiden => Forbid(),
                    enErrorType.NotFound => NotFound(result.ErrorMessage),
                    _ => BadRequest(result.ErrorMessage),
                };
            }

            return Ok(result.Data);
        }
    }
}
