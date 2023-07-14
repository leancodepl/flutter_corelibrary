using System.Text.RegularExpressions;
using ExampleApp.Core.Contracts;
using ExampleApp.Core.Contracts.Identities;
using ExampleApp.Core.Services.DataAccess;
using LeanCode.CQRS.Execution;
using Microsoft.AspNetCore.Http;

namespace ExampleApp.Core.Services.CQRS.Projects;

public class SearchIdentitiesQH : IQueryHandler<SearchIdentities, PaginatedResult<KratosIdentityDTO>>
{
    private readonly CoreDbContext dbContext;

    public SearchIdentitiesQH(CoreDbContext dbContext)
    {
        this.dbContext = dbContext;
    }

    public Task<PaginatedResult<KratosIdentityDTO>> ExecuteAsync(HttpContext context, SearchIdentities query)
    {
        return dbContext.KratosIdentities
            .ConditionalWhere(ki => ki.SchemaId == query.SchemaId, query.SchemaId is not null)
            .ConditionalWhere(
                ki => Regex.IsMatch(ki.Traits.GetProperty("email").GetString()!, query.EmailPattern!),
                query.EmailPattern is not null
            )
            .ConditionalWhere(
                ki => Regex.IsMatch(ki.Traits.GetProperty("given_name").GetString()!, query.GivenNamePattern!),
                query.GivenNamePattern is not null
            )
            .ConditionalWhere(
                ki => Regex.IsMatch(ki.Traits.GetProperty("family_name").GetString()!, query.FamilyNamePattern!),
                query.FamilyNamePattern is not null
            )
            .OrderBy(ki => ki.Traits.GetProperty("email").GetString())
            .Select(
                ki =>
                    new KratosIdentityDTO
                    {
                        Id = ki.Id,
                        CreatedAt = ki.CreatedAt,
                        UpdatedAt = ki.UpdatedAt,
                        SchemaId = ki.SchemaId,
                        Email = ki.Email,
                        Traits = ki.Traits,
                    }
            )
            .ToPaginatedResultAsync(query, context.RequestAborted);
    }
}
