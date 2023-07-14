using ExampleApp.Core.Contracts.Projects;
using ExampleApp.Core.Services.DataAccess;
using LeanCode.CQRS.Execution;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace ExampleApp.Core.Services.CQRS.Projects;

public class AllProjectsQH : IQueryHandler<AllProjects, List<ProjectDTO>>
{
    private readonly CoreDbContext dbContext;

    public AllProjectsQH(CoreDbContext dbContext)
    {
        this.dbContext = dbContext;
    }

    public Task<List<ProjectDTO>> ExecuteAsync(HttpContext context, AllProjects query)
    {
        var q = dbContext.Projects.Select(p => new ProjectDTO { Id = p.Id, Name = p.Name, });

        q = query.SortByNameDescending ? q.OrderByDescending(p => p.Name) : q.OrderBy(p => p.Name);

        return q.ToListAsync(context.RequestAborted);
    }
}
