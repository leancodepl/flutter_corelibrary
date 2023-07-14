using ExampleApp.Core.Domain.Employees;
using ExampleApp.Core.Domain.Projects;
using Microsoft.EntityFrameworkCore;

namespace ExampleApp.IntegrationTests.Overrides;

public class CoreDbContext : Core.Services.DataAccess.CoreDbContext
{
    public CoreDbContext(DbContextOptions<Core.Services.DataAccess.CoreDbContext> options)
        : base(options) { }

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        base.ConfigureConventions(configurationBuilder);

        configurationBuilder.Properties<EmployeeId>().HaveColumnType("citext");
        configurationBuilder.Properties<ProjectId>().HaveColumnType("citext");
        configurationBuilder.Properties<AssignmentId>().HaveColumnType("citext");
    }
}
