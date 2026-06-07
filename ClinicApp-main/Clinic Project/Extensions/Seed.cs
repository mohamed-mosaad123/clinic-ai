using Clinic_Project.Data;
using Clinic_Project.Dtos.Person;
using Clinic_Project.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Clinic_Project.Extensions
{
    public static class Seed
    {
        public static async Task SeedRolesAsync(RoleManager<IdentityRole> roleManager)
        {
            string[] roleNames = { "Admin", "Doctor", "Patient" };
            foreach (var role in roleNames)
            {
                if (!await roleManager.RoleExistsAsync(role))
                    await roleManager.CreateAsync(new IdentityRole(role));
            }
        }

        /// <summary>
        /// Seeds a demo Patient and Doctor account for testing the full AI pipeline.
        /// Credentials: patient@demo.com / Demo@123  |  doctor@demo.com / Demo@123
        /// </summary>
        public static async Task SeedDemoUsersAsync(
            UserManager<AppUser> userManager,
            AppDbContext db)
        {
            // ── 1. Ensure a demo Specialization exists ───────────────────────
            var specialization = await db.Specializations
                .FirstOrDefaultAsync(s => s.Name == "General Practice");

            if (specialization == null)
            {
                specialization = new Specialization { Name = "General Practice" };
                db.Specializations.Add(specialization);
                await db.SaveChangesAsync();
            }

            // ── 2. Demo Patient ──────────────────────────────────────────────
            const string patientEmail = "patient@demo.com";
            if (await userManager.FindByEmailAsync(patientEmail) == null)
            {
                var patientPerson = new Person
                {
                    FirstName   = "Demo",
                    LastName    = "Patient",
                    DateOfBirth = new DateTime(1995, 6, 15),
                    Gender      = enGender.Male,
                    Email       = patientEmail,
                    Phone       = "+201000000001",
                    Address     = "1 Demo Street, Cairo"
                };
                var patient = new Patient { Person = patientPerson };
                db.Patients.Add(patient);
                await db.SaveChangesAsync();

                var patientUser = new AppUser
                {
                    UserName       = "demo_patient",
                    Email          = patientEmail,
                    EmailConfirmed = true,
                    PhoneNumber    = "+201000000001",
                    PersonId       = patientPerson.Id
                };
                var result = await userManager.CreateAsync(patientUser, "Demo@123");
                if (result.Succeeded)
                    await userManager.AddToRoleAsync(patientUser, "Patient");
            }

            // ── 3. Demo Doctor ───────────────────────────────────────────────
            const string doctorEmail = "doctor@demo.com";
            if (await userManager.FindByEmailAsync(doctorEmail) == null)
            {
                var doctorPerson = new Person
                {
                    FirstName   = "Demo",
                    LastName    = "Doctor",
                    DateOfBirth = new DateTime(1980, 3, 20),
                    Gender      = enGender.Male,
                    Email       = doctorEmail,
                    Phone       = "+201000000002",
                    Address     = "2 Demo Street, Cairo"
                };
                var doctor = new Doctor
                {
                    Person           = doctorPerson,
                    SpecializationId = specialization.Id
                };
                db.Doctors.Add(doctor);
                await db.SaveChangesAsync();

                var doctorUser = new AppUser
                {
                    UserName       = "demo_doctor",
                    Email          = doctorEmail,
                    EmailConfirmed = true,
                    PhoneNumber    = "+201000000002",
                    PersonId       = doctorPerson.Id
                };
                var result = await userManager.CreateAsync(doctorUser, "Demo@123");
                if (result.Succeeded)
                    await userManager.AddToRoleAsync(doctorUser, "Doctor");
            }
        }
    }
}
