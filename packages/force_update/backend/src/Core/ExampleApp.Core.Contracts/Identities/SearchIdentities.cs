using LeanCode.Contracts;
using LeanCode.Contracts.Security;

namespace ExampleApp.Core.Contracts.Identities;

[AuthorizeWhenHasAnyOf(Auth.Roles.Admin)]
public class SearchIdentities : PaginatedQuery<KratosIdentityDTO>
{
    public string? SchemaId { get; private set; }
    public string? EmailPattern { get; set; }
    public string? GivenNamePattern { get; set; }
    public string? FamilyNamePattern { get; set; }
}

public class KratosIdentityDTO
{
    public Guid Id { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    public string SchemaId { get; set; }
    public string Email { get; set; }

    [ExcludeFromContractsGeneration]
    public object Traits { get; set; }
}
