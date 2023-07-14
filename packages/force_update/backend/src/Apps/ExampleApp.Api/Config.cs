using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Serilog.Events;

namespace ExampleApp.Api;

public static class Config
{
    public static class Kratos
    {
        public static string PublicEndpoint(IConfiguration cfg) => cfg.GetString("Kratos:PublicEndpoint");

        public static string AdminEndpoint(IConfiguration cfg) => cfg.GetString("Kratos:AdminEndpoint");

        public static string WebhookApiKey(IConfiguration cfg) => cfg.GetString("Kratos:WebhookApiKey");
    }

    public static class PostgreSQL
    {
        public static string ConnectionString(IConfiguration cfg) => cfg.GetString("PostgreSQL:ConnectionString");
    }

    public static class BlobStorage
    {
        public static string ConnectionString(IConfiguration cfg) => cfg.GetString("BlobStorage:ConnectionString");
    }

    public static class MassTransit
    {
        public static class AzureServiceBus
        {
            public static string Endpoint(IConfiguration cfg) => cfg.GetString("MassTransit:AzureServiceBus:Endpoint");
        }
    }

    public static class Services
    {
        public static string[] AllowedOrigins(IConfiguration cfg) =>
            ExternalApps(cfg).Concat(Array.Empty<string>()).ToArray();

        public static string[] ExternalApps(IConfiguration cfg) =>
            cfg?.GetSection("CORS:External").Get<string[]>() ?? Array.Empty<string>();
    }

    public static class Logging
    {
        public static bool EnableDetailedInternalLogs(IConfiguration cfg) =>
            cfg.GetBool("Logging:EnableDetailedInternalLogs");

        public static LogEventLevel MinimumLevel(IConfiguration cfg) =>
            cfg.GetValue("Logging:MinimumLevel", LogEventLevel.Verbose);
    }

    public static class Telemetry
    {
        public static string? OtlpEndpoint(IConfiguration cfg) => cfg.GetString("Telemetry:OtlpEndpoint");
    }

    private static string GetString(this IConfiguration configuration, string key)
    {
        return configuration.GetValue<string>(key)!;
    }

    private static bool GetBool(this IConfiguration configuration, string key)
    {
        return configuration.GetValue<bool>(key)!;
    }

    public static void AddMappedConfiguration(
        this IServiceCollection services,
        IConfiguration config,
        IWebHostEnvironment hostEnv
    )
    {
        services.AddSingleton(new LeanCode.Kratos.KratosWebHookHandlerConfig(Kratos.WebhookApiKey(config)));
    }
}
