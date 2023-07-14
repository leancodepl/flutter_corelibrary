using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Npgsql;
using Polly;
using Serilog;

namespace ExampleApp.IntegrationTests;

public class DbContextInitializer<T> : IHostedService
    where T : DbContext
{
    private static readonly IAsyncPolicy CreatePolicy = Policy
        .Handle((NpgsqlException e) => e.IsTransient)
        .WaitAndRetryAsync(
            new TimeSpan[3] { TimeSpan.FromSeconds(0.5), TimeSpan.FromSeconds(1.0), TimeSpan.FromSeconds(3.0) }
        );

    private readonly ILogger logger = Log.ForContext<DbContextInitializer<T>>();

    private readonly T context;

    public DbContextInitializer(T context)
    {
        this.context = context;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        logger.Information("Creating database for context {ContextType}", context.GetType());
        await CreatePolicy.ExecuteAsync(
            async (CancellationToken token) =>
            {
                await context.Database.EnsureDeletedAsync(token);
                await context.Database.EnsureCreatedAsync(token);

                if (context.Database.GetDbConnection() is NpgsqlConnection connection)
                {
                    if (connection.State == System.Data.ConnectionState.Closed)
                    {
                        await connection.OpenAsync(token);
                        await connection.ReloadTypesAsync();
                        await connection.CloseAsync();
                    }
                    else
                    {
                        await connection.ReloadTypesAsync();
                    }
                }
            },
            cancellationToken
        );
    }

    public async Task StopAsync(CancellationToken cancellationToken)
    {
        logger.Information("Dropping database for context {ContextType}", context.GetType());
        await context.Database.EnsureDeletedAsync(cancellationToken);
    }
}
