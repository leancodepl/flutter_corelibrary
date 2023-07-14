using System.Globalization;
using LeanCode.AzureIdentity;
using LeanCode.OpenTelemetry;
using ExampleApp.Api.Handlers;
using ExampleApp.Core.Services.DataAccess;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Cors.Infrastructure;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Npgsql;
using static ExampleApp.Core.Contracts.Auth;

namespace ExampleApp.Api;

internal static class ApiModule
{
    internal const string ApiCorsPolicy = "Api";

    public static void AddApiServices(this IServiceCollection services, IConfiguration config, IWebHostEnvironment hostEnv)
    {
        services.AddCors(cors => ConfigureCORS(cors, config));
        services.AddRouting();
        services.AddHealthChecks().AddDbContextCheck<CoreDbContext>();

        services
            .AddAuthentication()
            .AddKratos(options =>
            {
                options.NameClaimType = KnownClaims.UserId;
                options.RoleClaimType = KnownClaims.Role;

                options.ClaimsExtractor = (s, o, c) =>
                {
                    c.Add(new(o.RoleClaimType, Roles.User)); // every identity is a valid User

                    if (
                        s.Identity.VerifiableAddresses.Any(
                            kvia =>
                                kvia.Via == "email"
                                && kvia.Value.EndsWith("@leancode.pl", false, CultureInfo.InvariantCulture)
                                && kvia.Verified
                        )
                    )
                    {
                        c.Add(new(o.RoleClaimType, Roles.Admin));
                    }
                };
            });

        services.AddKratosClients(builder =>
        {
            builder.AddFrontendApiClient(Config.Kratos.PublicEndpoint(config));
            builder.AddIdentityApiClient(Config.Kratos.AdminEndpoint(config));
        });

        services.Configure<ForwardedHeadersOptions>(options =>
        {
            options.ForwardedHeaders = ForwardedHeaders.All;
            options.KnownNetworks.Clear();
            options.KnownProxies.Clear();
        });

        var otlp = Config.Telemetry.OtlpEndpoint(config);

        if (!string.IsNullOrWhiteSpace(otlp))
        {
            services
                .AddOpenTelemetry()
                .ConfigureResource(r => r.AddService("ExampleApp.Api", serviceInstanceId: Environment.MachineName))
                .WithTracing(builder =>
                {
                    builder
                        .AddAspNetCoreInstrumentation(
                            opts => opts.Filter = ctx => !ctx.Request.Path.StartsWithSegments("/live")
                        )
                        .AddHttpClientInstrumentation()
                        .AddNpgsql()
                        .AddSource("MassTransit")
                        .AddLeanCodeTelemetry()
                        .AddOtlpExporter(cfg => cfg.Endpoint = new(otlp));
                })
                .WithMetrics(builder =>
                {
                    builder
                        .AddAspNetCoreInstrumentation()
                        .AddHttpClientInstrumentation()
                        .AddOtlpExporter(cfg => cfg.Endpoint = new(otlp));
                });
        }

        services.AddAzureClients(cfg =>
        {
            cfg.AddBlobServiceClient(Config.BlobStorage.ConnectionString(config));

            if (!hostEnv.IsDevelopment())
            {
                cfg.UseCredential(DefaultLeanCodeCredential.Create(config));
            }
        });

        services.AddSingleton<LeanCode.CQRS.Security.IRoleRegistration, AppRoles>();
        services.AddScoped<KratosIdentitySyncHandler>();
        services.AddMappedConfiguration(config, hostEnv);
    }

    private static void ConfigureCORS(CorsOptions opts, IConfiguration config)
    {
        opts.AddPolicy(
            ApiCorsPolicy,
            cfg =>
            {
                cfg.WithOrigins(Config.Services.AllowedOrigins(config))
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .AllowCredentials()
                    .SetPreflightMaxAge(TimeSpan.FromMinutes(60));
            }
        );
    }
}
