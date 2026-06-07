using Clinic_Project.Data;
using Clinic_Project.Models;
using Clinic_Project.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace Clinic_Project.Repositories.Implementations
{
    public class AiAnalysisRepo : MainRepo<AiAnalysis>, IAiAnalysisRepo
    {
        private readonly AppDbContext _context;

        public AiAnalysisRepo(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public override async Task<IEnumerable<AiAnalysis>?> GetAllAsync()
        {
            return await _context.AiAnalyses
                .Include(a => a.Patient)
                    .ThenInclude(p => p!.Person)
                .OrderByDescending(a => a.CreatedAt)
                .AsNoTracking()
                .ToListAsync();
        }

        public override async Task<AiAnalysis?> GetOneAsync(Expression<Func<AiAnalysis, bool>> predicate)
        {
            return await _context.AiAnalyses
                .Include(a => a.Patient)
                    .ThenInclude(p => p!.Person)
                        .ThenInclude(p => p!.User)
                .AsNoTracking()
                .SingleOrDefaultAsync(predicate);
        }

        public override async Task<IEnumerable<AiAnalysis>?> FindAsync(Expression<Func<AiAnalysis, bool>> predicate)
        {
            return await _context.AiAnalyses
                .Include(a => a.Patient)
                    .ThenInclude(p => p!.Person)
                .Where(predicate)
                .OrderByDescending(a => a.CreatedAt)
                .AsNoTracking()
                .ToListAsync();
        }
    }
}
