using System.Diagnostics.CodeAnalysis;
using System.Text.Json;
using LeanCode.DomainModels.Model;

namespace ExampleApp.Core.Services.DataAccess.Entities;

public class KratosIdentity : IIdentifiable<Guid>
{
    private readonly List<KratosIdentityAddress> recoveryAddresses = new();
    private readonly List<KratosIdentityVerifiableAddress> verifiableAddresses = new();

    public Guid Id { get; private init; }
    public DateTime CreatedAt { get; private init; }

    public DateTime UpdatedAt { get; private set; }
    public string SchemaId { get; private set; }
    public string Email { get; private set; }
    public JsonElement Traits { get; private set; }
    public JsonElement? MetadataPublic { get; private set; }
    public JsonElement? MetadataAdmin { get; private set; }

    public IReadOnlyCollection<KratosIdentityAddress> RecoveryAddresses => recoveryAddresses;
    public IReadOnlyCollection<KratosIdentityVerifiableAddress> VerifiableAddresses => verifiableAddresses;

    private KratosIdentity()
    {
        SchemaId = null!;
        Email = null!;
    }

    public KratosIdentity(LeanCode.Kratos.Model.Identity identity)
    {
        Id = identity.Id;
        CreatedAt = identity.CreatedAt;

        UpdatedAt = identity.UpdatedAt;
        SchemaId = identity.SchemaId;

        Traits = identity.Traits;
        MetadataPublic = identity.MetadataPublic;
        MetadataAdmin = identity.MetadataAdmin;

        ExtractEmailFromTraits();

        CopyRecoveryAddresses(identity.RecoveryAddresses);
        CopyVerifiableAddresses(identity.VerifiableAddresses);
    }

    public void Update(LeanCode.Kratos.Model.Identity identity)
    {
        if (Id != identity.Id)
        {
            throw new InvalidOperationException("ID does not match.");
        }

        UpdatedAt = identity.UpdatedAt;
        SchemaId = identity.SchemaId;

        Traits = identity.Traits;
        MetadataPublic = identity.MetadataPublic;
        MetadataAdmin = identity.MetadataAdmin;

        ExtractEmailFromTraits();

        recoveryAddresses.Clear();
        CopyRecoveryAddresses(identity.RecoveryAddresses);

        verifiableAddresses.Clear();
        CopyVerifiableAddresses(identity.VerifiableAddresses);
    }

    private void CopyRecoveryAddresses(List<LeanCode.Kratos.Model.RecoveryIdentityAddress>? addresses)
    {
        if (addresses is null)
        {
            return;
        }

        recoveryAddresses.AddRange(
            addresses.Select(
                kria =>
                    new KratosIdentityAddress
                    {
                        IdentityId = Id,
                        Id = kria.Id,
                        CreatedAt = kria.CreatedAt,
                        UpdatedAt = kria.UpdatedAt,
                        Via = kria.Via.ToString().ToLowerInvariant(),
                        Value = kria.Value,
                    }
            )
        );
    }

    private void CopyVerifiableAddresses(List<LeanCode.Kratos.Model.VerifiableIdentityAddress>? addresses)
    {
        if (addresses is null)
        {
            return;
        }

        verifiableAddresses.AddRange(
            addresses.Select(
                kvia =>
                    new KratosIdentityVerifiableAddress
                    {
                        IdentityId = Id,
                        Id = kvia.Id,
                        CreatedAt = kvia.CreatedAt,
                        UpdatedAt = kvia.UpdatedAt,
                        Via = kvia.Via.ToString().ToLowerInvariant(),
                        Value = kvia.Value,
                        VerifiedAt = kvia.Verified ? kvia.VerifiedAt : null,
                    }
            )
        );
    }

    [MemberNotNull(nameof(Email))]
    private void ExtractEmailFromTraits()
    {
        Email =
            Traits.GetProperty("email").GetString()
            ?? throw new InvalidOperationException("Failed to read email trait.");
    }
}

public class KratosIdentityAddress : IIdentifiable<Guid>
{
    public Guid IdentityId { get; init; }
    public Guid Id { get; init; }
    public DateTime CreatedAt { get; init; }
    public DateTime UpdatedAt { get; init; }
    public string Via { get; init; } = null!;
    public string Value { get; init; } = null!;
}

public class KratosIdentityVerifiableAddress : KratosIdentityAddress
{
    public DateTime? VerifiedAt { get; init; }
}
