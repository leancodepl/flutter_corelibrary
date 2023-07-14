using ExampleApp.Core.Domain.Projects;
using LeanCode.DomainModels.EF;
using LeanCode.DomainModels.Model;
using LeanCode.TimeProvider;
using Microsoft.EntityFrameworkCore;

namespace ExampleApp.Core.Services.DataAccess.Repositories;

public class ProjectsRepository : EFRepository<Project, ProjectId, CoreDbContext>
{
    public ProjectsRepository(CoreDbContext dbContext)
        : base(dbContext) { }

    public override void Add(Project entity)
    {
        ((IOptimisticConcurrency)entity).DateModified = Time.NowWithOffset.UtcDateTime;
        DbSet.Add(entity);
    }

    public override void Delete(Project entity)
    {
        ((IOptimisticConcurrency)entity).DateModified = Time.NowWithOffset.UtcDateTime;
        DbSet.Remove(entity);
    }

    public override void DeleteRange(IEnumerable<Project> entities)
    {
        foreach (var item in entities)
        {
            ((IOptimisticConcurrency)item).DateModified = Time.NowWithOffset.UtcDateTime;
        }
        DbSet.RemoveRange(entities);
    }

    public override void Update(Project entity)
    {
        ((IOptimisticConcurrency)entity).DateModified = Time.NowWithOffset.UtcDateTime;
    }

    public override Task<Project?> FindAsync(ProjectId id, CancellationToken cancellationToken = default)
    {
        return DbSet.AsTracking().FirstOrDefaultAsync(p => p.Id == id, cancellationToken)!;
    }
}
