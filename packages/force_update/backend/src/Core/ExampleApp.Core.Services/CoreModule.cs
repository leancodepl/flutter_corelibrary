using Azure.Core;
using ExampleApp.Core.Domain.Projects;
using ExampleApp.Core.Services.DataAccess;
using ExampleApp.Core.Services.DataAccess.Repositories;
using LeanCode.DomainModels.DataAccess;
using LeanCode.Npgsql.ActiveDirectory;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

namespace ExampleApp.Core.Services;

public static class CoreModuleExtensions
{
    public static void AddCoreServices(this IServiceCollection services, string connectionString)
    {
        services.AddSingleton(sp =>
        {
            var builder = new NpgsqlDataSourceBuilder(connectionString);

            if (builder.ConnectionStringBuilder.Password is null)
            {
                builder.UseAzureActiveDirectoryAuthentication(sp.GetRequiredService<TokenCredential>());
            }

            return builder.Build();
        });

        services.AddDbContext<CoreDbContext>(
            opts =>
                opts
#if DEBUG
                .EnableSensitiveDataLogging()
#endif
                    .UseNpgsql(cfg => cfg.MigrationsAssembly("ExampleApp.Migrations").SetPostgresVersion(14, 0))
        );

        services.AddScoped<ProjectsRepository>();
        services.AddScoped<IRepository<Project, ProjectId>, ProjectsRepository>();
    }
}
