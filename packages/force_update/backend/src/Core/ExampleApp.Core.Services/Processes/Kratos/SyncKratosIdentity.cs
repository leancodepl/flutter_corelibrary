using ExampleApp.Core.Services.DataAccess;
using LeanCode.DomainModels.Model;
using LeanCode.Kratos.Model;
using MassTransit;

namespace ExampleApp.Core.Services.Processes.Kratos;

public sealed record class KratosIdentityUpdated(Guid Id, DateTime DateOccurred, Identity Identity) : IDomainEvent;

public class SyncKratosIdentity : IConsumer<KratosIdentityUpdated>
{
    private readonly Serilog.ILogger logger = Serilog.Log.ForContext<SyncKratosIdentity>();

    private readonly CoreDbContext dbContext;

    public SyncKratosIdentity(CoreDbContext dbContext)
    {
        this.dbContext = dbContext;
    }

    public async Task Consume(ConsumeContext<KratosIdentityUpdated> context)
    {
        var kratosIdentity = context.Message.Identity;
        var identityId = kratosIdentity.Id;

        var dbIdentity = await dbContext.KratosIdentities.FindAsync(
            keyValues: new[] { (object)identityId },
            context.CancellationToken
        );

        if (dbIdentity is null)
        {
            dbIdentity = new(kratosIdentity);
            dbContext.KratosIdentities.Add(dbIdentity);

            logger.Information("Identity {IdentityId} replicated", identityId);
        }
        else
        {
            dbIdentity.Update(kratosIdentity);
            dbContext.KratosIdentities.Update(dbIdentity);

            logger.Information("Replica of Identity {IdentityId} updated", identityId);
        }
    }
}
