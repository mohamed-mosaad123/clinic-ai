using Clinic_Project.Dtos.AI;
using Clinic_Project.Helpers;

namespace Clinic_Project.Services.Interfaces
{
    public interface IAiAnalysisService
    {
        Task<Result<AiAnalysisReadDto>?> CreateAsync(AiAnalysisWriteDto dto, string currentUserId, bool isPatient, bool isAdmin);
        Task<Result<IEnumerable<AiAnalysisReadDto>?>> GetByPatientIdAsync(int patientId, string currentUserId, bool isDoctor, bool isAdmin);
        Task<Result<IEnumerable<AiAnalysisReadDto>?>> GetAllAsync();
        Task<Result<AiAnalysisReadDto>?> GetByIdAsync(int id, string currentUserId, bool isDoctor, bool isAdmin);
    }
}
