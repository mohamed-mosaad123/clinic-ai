using Clinic_Project.Data;
using Microsoft.EntityFrameworkCore;

namespace Clinic_Project.Extensions
{
    public static class DatabaseSchemaExtensions
    {
        public static async Task EnsureAiAnalysesTableAsync(this AppDbContext context)
        {
            await context.Database.ExecuteSqlRawAsync(@"
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AiAnalyses' AND xtype='U')
                BEGIN
                    CREATE TABLE [AiAnalyses] (
                        [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                        [PatientId] INT NOT NULL,
                        [Disease] NVARCHAR(100) NOT NULL,
                        [Prediction] INT NOT NULL,
                        [Probability] FLOAT NOT NULL,
                        [RiskLevel] NVARCHAR(50) NOT NULL DEFAULT '',
                        [StatusLevel] NVARCHAR(50) NOT NULL DEFAULT '',
                        [RiskDescription] NVARCHAR(MAX) NOT NULL DEFAULT '',
                        [InputsJson] NVARCHAR(MAX) NOT NULL DEFAULT '{{}}',
                        [ModelVersion] NVARCHAR(50) NULL,
                        [CreatedAt] DATETIME2 NOT NULL,
                        CONSTRAINT [FK_AiAnalyses_Patients] FOREIGN KEY ([PatientId]) REFERENCES [Patients]([Id])
                    );
                    CREATE INDEX [IX_AiAnalyses_PatientId] ON [AiAnalyses]([PatientId]);
                    CREATE INDEX [IX_AiAnalyses_CreatedAt] ON [AiAnalyses]([CreatedAt]);
                END");
        }
    }
}
