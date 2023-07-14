using ExampleApp.Core.Contracts.Projects;
using ExampleApp.Core.Domain.Projects;
using ExampleApp.Core.Services.DataAccess;
using LeanCode.CQRS.Execution;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace ExampleApp.Core.Services.CQRS.Projects;

public class ProjectDetailsQH : IQueryHandler<ProjectDetails, ProjectDetailsDTO?>
{
    private readonly CoreDbContext dbContext;

    public ProjectDetailsQH(CoreDbContext dbContext)
    {
        this.dbContext = dbContext;
    }

    public Task<ProjectDetailsDTO?> ExecuteAsync(HttpContext context, ProjectDetails query)
    {
        if (!ProjectId.TryParse(query.Id, out var projectId))
        {
            return null!;
        }

        return dbContext.Projects
            .Where(p => p.Id == projectId)
            .Select(
                p =>
                    new ProjectDetailsDTO
                    {
                        Id = p.Id,
                        Name = p.Name,
                        Assignments = p.Assignments.Select(a => new AssignmentDTO { Name = a.Name }).ToList(),
                    }
            )
            .FirstOrDefaultAsync(context.RequestAborted);
    }
}
