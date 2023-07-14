using ExampleApp.Core.Domain.Employees;
using ExampleApp.Core.Domain.Projects;
using ExampleApp.Core.Services.DataAccess.Entities;
using LeanCode.DomainModels.EF;
using Microsoft.EntityFrameworkCore;
using MassTransit;

namespace ExampleApp.Core.Services.DataAccess;

public class CoreDbContext : DbContext
{
    public DbSet<KratosIdentity> KratosIdentities => Set<KratosIdentity>();

    public DbSet<Employee> Employees => Set<Employee>();
    public DbSet<Project> Projects => Set<Project>();

    public CoreDbContext(DbContextOptions<CoreDbContext> options)
        : base(options) { }

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        configurationBuilder
            .Properties<EmployeeId>()
            .HaveColumnType("dbo.employee_id")
            .HaveConversion<PrefixedTypedIdConverter<EmployeeId>, PrefixedTypedIdComparer<EmployeeId>>();

        configurationBuilder
            .Properties<ProjectId>()
            .HaveColumnType("dbo.project_id")
            .HaveConversion<PrefixedTypedIdConverter<ProjectId>, PrefixedTypedIdComparer<ProjectId>>();

        configurationBuilder
            .Properties<AssignmentId>()
            .HaveColumnType("dbo.assignment_id")
            .HaveConversion<PrefixedTypedIdConverter<AssignmentId>, PrefixedTypedIdComparer<AssignmentId>>();
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.HasPostgresExtension("public", "citext");
        builder.HasDefaultSchema("dbo");

        builder.AddInboxStateEntity();
        builder.AddOutboxStateEntity();
        builder.AddOutboxMessageEntity();

        builder.Entity<KratosIdentity>(e =>
        {
            e.OwnsMany(
                ki => ki.RecoveryAddresses,
                b =>
                {
                    b.WithOwner().HasForeignKey(a => a.IdentityId);
                    b.HasKey(a => a.Id);
                    b.ToTable("KratosIdentityRecoveryAddresses");
                }
            );

            e.OwnsMany(
                ki => ki.VerifiableAddresses,
                b =>
                {
                    b.WithOwner().HasForeignKey(a => a.IdentityId);
                    b.HasKey(a => a.Id);
                    b.ToTable("KratosIdentityVerifiableAddresses");
                }
            );

            e.Property<uint>("xmin").IsRowVersion();
        });

        builder.Entity<Employee>(e =>
        {
            e.HasKey(t => t.Id);

            e.IsOptimisticConcurrent(addRowVersion: false);
            e.Property<uint>("xmin").IsRowVersion();
        });

        builder.Entity<Project>(e =>
        {
            e.HasKey(t => t.Id);

            e.OwnsMany(
                p => p.Assignments,
                inner =>
                {
                    inner.WithOwner(a => a.ParentProject).HasForeignKey(a => a.ParentProjectId);

                    inner.ToTable("Assignments");
                }
            );

            e.IsOptimisticConcurrent(addRowVersion: false);
            e.Property<uint>("xmin").IsRowVersion();
        });
    }
}
