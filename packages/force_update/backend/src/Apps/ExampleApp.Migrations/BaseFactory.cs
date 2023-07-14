using LeanCode.AzureIdentity;
using LeanCode.EFMigrator;
using LeanCode.Npgsql.ActiveDirectory;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Npgsql;
using Npgsql.EntityFrameworkCore.PostgreSQL.Infrastructure;

namespace ExampleApp.Migrations;

public abstract class BaseFactory<TContext, TFactory> : IDesignTimeDbContextFactory<TContext>
    where TContext : DbContext
    where TFactory : BaseFactory<TContext, TFactory>
{
    protected virtual string AssemblyName =>
        typeof(TFactory).Assembly.GetName().Name
        ?? throw new InvalidOperationException("This type is not supported on Assembly-less runtimes.");

    protected virtual void UseAdditionalNpgsqlDbContextOptions(NpgsqlDbContextOptionsBuilder builder) { }

    protected virtual void UseAdditionalDbContextOptions(DbContextOptionsBuilder<TContext> builder) { }

    public TContext CreateDbContext(string[] args)
    {
        var connectionString =
            MigrationsConfig.GetConnectionString()
            ?? throw new InvalidOperationException("Failed to find connection string.");

        var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);

        if (dataSourceBuilder.ConnectionStringBuilder.Password is null)
        {
            dataSourceBuilder.UseAzureActiveDirectoryAuthentication(DefaultLeanCodeCredential.CreateFromEnvironment());
        }

        var builder = new DbContextOptionsBuilder<TContext>()
            .UseLoggerFactory(
                new ServiceCollection()
                    .AddLogging(cfg => cfg.AddConsole())
                    .BuildServiceProvider()
                    .GetRequiredService<ILoggerFactory>()
            )
            .UseNpgsql(
                dataSourceBuilder.Build(),
                cfg => UseAdditionalNpgsqlDbContextOptions(cfg.MigrationsAssembly(AssemblyName))
            );

        UseAdditionalDbContextOptions(builder);

        return (TContext?)Activator.CreateInstance(typeof(TContext), builder.Options)
            ?? throw new InvalidOperationException("Failed to create DbContext instance.");
    }
}
