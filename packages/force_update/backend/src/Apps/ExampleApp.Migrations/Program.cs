using LeanCode.EFMigrator;
using ExampleApp.Core.Services.DataAccess;
using Npgsql.EntityFrameworkCore.PostgreSQL.Infrastructure;

namespace ExampleApp.Migrations;

public class Program
{
    public static void Main(string[] args)
    {
        MigrationsConfig.ConnectionStringKey = "PostgreSQL:ConnectionString";

        new Migrator().Run(args);
    }
}

internal class Migrator : LeanCode.EFMigrator.Migrator
{
    protected override void MigrateAll()
    {
        Migrate<CoreDbContext, CoreDbContextFactory>();
    }
}

internal class CoreDbContextFactory : BaseFactory<CoreDbContext, CoreDbContextFactory>
{
    protected override void UseAdditionalNpgsqlDbContextOptions(NpgsqlDbContextOptionsBuilder builder)
    {
        builder.SetPostgresVersion(14, 0);
    }
}
