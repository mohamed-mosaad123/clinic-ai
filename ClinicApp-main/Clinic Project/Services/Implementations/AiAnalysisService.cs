using AutoMapper;
using Clinic_Project.Dtos.AI;
using Clinic_Project.Helpers;
using Clinic_Project.Models;
using Clinic_Project.Repositories.Interfaces;
using Clinic_Project.Services.Interfaces;
using System.Text.Json;

namespace Clinic_Project.Services.Implementations
{
    public class AiAnalysisService : IAiAnalysisService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public AiAnalysisService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<Result<AiAnalysisReadDto>?> CreateAsync(
            AiAnalysisWriteDto dto, string currentUserId, bool isPatient, bool isAdmin)
        {
            if (!await _unitOfWork.Patients.IsExistAsync(p => p.Id == dto.PatientId))
                return Result<AiAnalysisReadDto>.Fail("Patient not found", enErrorType.NotFound);

            if (isPatient && !isAdmin)
            {
                var patient = await _unitOfWork.Patients.GetOneAsync(p => p.Id == dto.PatientId);
                if (patient?.Person?.User?.Id != currentUserId)
                    return Result<AiAnalysisReadDto>.Fail("You can only save analyses for your own account.", enErrorType.Forbiden);
            }

            var entity = new AiAnalysis
            {
                PatientId = dto.PatientId,
                Disease = dto.Disease,
                Prediction = dto.Prediction,
                Probability = dto.Probability,
                RiskLevel = dto.RiskLevel,
                StatusLevel = dto.StatusLevel,
                RiskDescription = dto.RiskDescription,
                InputsJson = JsonSerializer.Serialize(dto.Inputs),
                ModelVersion = dto.ModelVersion,
                CreatedAt = DateTime.UtcNow,
            };

            await _unitOfWork.AiAnalyses.AddAsync(entity);
            await _unitOfWork.CommitChangesAsync();

            entity = await _unitOfWork.AiAnalyses.GetOneAsync(a => a.Id == entity.Id);
            return Result<AiAnalysisReadDto>.Ok(_mapper.Map<AiAnalysisReadDto>(entity));
        }

        public async Task<Result<IEnumerable<AiAnalysisReadDto>?>> GetByPatientIdAsync(
            int patientId, string currentUserId, bool isDoctor, bool isAdmin)
        {
            if (!await _unitOfWork.Patients.IsExistAsync(p => p.Id == patientId))
                return Result<IEnumerable<AiAnalysisReadDto>?>.Fail("Patient not found", enErrorType.NotFound);

            if (!isDoctor && !isAdmin)
            {
                var patient = await _unitOfWork.Patients.GetOneAsync(p => p.Id == patientId);
                if (patient?.Person?.User?.Id != currentUserId)
                    return Result<IEnumerable<AiAnalysisReadDto>?>.Fail("You are not allowed to view these analyses.", enErrorType.Forbiden);
            }

            var analyses = await _unitOfWork.AiAnalyses.FindAsync(a => a.PatientId == patientId);
            var dtos = _mapper.Map<IEnumerable<AiAnalysisReadDto>>(analyses ?? []);
            return Result<IEnumerable<AiAnalysisReadDto>?>.Ok(dtos);
        }

        public async Task<Result<IEnumerable<AiAnalysisReadDto>?>> GetAllAsync()
        {
            var analyses = await _unitOfWork.AiAnalyses.GetAllAsync();
            var dtos = _mapper.Map<IEnumerable<AiAnalysisReadDto>>(analyses ?? []);
            return Result<IEnumerable<AiAnalysisReadDto>?>.Ok(dtos);
        }

        public async Task<Result<AiAnalysisReadDto>?> GetByIdAsync(
            int id, string currentUserId, bool isDoctor, bool isAdmin)
        {
            var analysis = await _unitOfWork.AiAnalyses.GetOneAsync(a => a.Id == id);
            if (analysis == null)
                return Result<AiAnalysisReadDto>.Fail("Analysis not found", enErrorType.NotFound);

            if (!isDoctor && !isAdmin)
            {
                if (analysis.Patient?.Person?.User?.Id != currentUserId)
                    return Result<AiAnalysisReadDto>.Fail("You are not allowed to view this analysis.", enErrorType.Forbiden);
            }

            return Result<AiAnalysisReadDto>.Ok(_mapper.Map<AiAnalysisReadDto>(analysis));
        }
    }
}
