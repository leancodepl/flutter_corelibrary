using System.Diagnostics;
using System.Reflection;
using ExampleApp.Api;
using ExampleApp.Core.Services.DataAccess;
using LeanCode.CQRS.MassTransitRelay;
using LeanCode.CQRS.RemoteHttp.Client;
using LeanCode.IntegrationTestHelpers;
using LeanCode.Logging;
using LeanCode.Startup.MicrosoftDI;
using MassTransit.Testing.Implementations;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Serilog.Events;
using Xunit;

namespace ExampleApp.IntegrationTests
{
    public class ExampleAppTestApp : LeanCodeTestFactory<Startup>
    {
        protected override ConfigurationOverrides Configuration { get; } =
            new(
                connectionStringBase: "PostgreSQL__ConnectionStringBase",
                connectionStringKey: "PostgreSQL:ConnectionString",
                LogEventLevel.Debug,
                true
            );

        static ExampleAppTestApp()
        {
            if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("WAIT_FOR_DEBUGGER")))
            {
                Console.WriteLine("Waiting for debugger to be attached...");

                while (!Debugger.IsAttached)
                {
                    Thread.Sleep(100);
                }
            }
        }

        protected override IEnumerable<Assembly> GetTestAssemblies()
        {
            yield return typeof(ExampleAppTestApp).Assembly;
        }

        protected override IHostBuilder CreateHostBuilder()
        {
            return LeanProgram
                .BuildMinimalHost<Startup>()
                .ConfigureDefaultLogging(
                    projectName: "ExampleApp-tests",
                    destructurers: new[] { typeof(Program).Assembly }
                )
                .UseEnvironment(Environments.Development);
        }

        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            base.ConfigureWebHost(builder);

            builder.ConfigureServices(services =>
            {
                services.RemoveAll<CoreDbContext>();
                services.AddScoped<CoreDbContext, Overrides.CoreDbContext>();
                services.AddHostedService<DbContextInitializer<CoreDbContext>>();
                services.AddBusActivityMonitor();
            });
        }

        public async Task WaitForProcessingAsync()
        {
            using var scope = Services.CreateScope();
            var monitor = scope.ServiceProvider.GetRequiredService<IBusActivityMonitor>();
            // Allow some processing time, selected arbitrarily
            var res = await monitor.AwaitBusInactivity(TimeSpan.FromSeconds(30));
            Assert.True(res, "The service bus should finish processing in allowed time.");
        }
    }

    public class AuthenticatedExampleAppTestApp : ExampleAppTestApp
    {
        private readonly string tokenPayload;

        public HttpQueriesExecutor Query { get; private set; } = default!;
        public HttpCommandsExecutor Command { get; private set; } = default!;
        public HttpOperationsExecutor Operation { get; private set; } = default!;

        public AuthenticatedExampleAppTestApp(string tokenPayload)
        {
            this.tokenPayload = tokenPayload;
        }

        public override async Task InitializeAsync()
        {
            void ConfigureClient(HttpClient hc) => hc.DefaultRequestHeaders.Authorization = new("Test", tokenPayload);

            await base.InitializeAsync();

            Query = CreateQueriesExecutor(ConfigureClient);
            Command = CreateCommandsExecutor(ConfigureClient);
            Operation = CreateOperationsExecutor(ConfigureClient);

            await WaitForProcessingAsync();
        }

        public override async ValueTask DisposeAsync()
        {
            Command = default!;
            Query = default!;
            Operation = default!;
            await base.DisposeAsync();
        }
    }

    public class UnauthenticatedExampleAppTestApp : ExampleAppTestApp
    {
        public HttpQueriesExecutor Query { get; private set; } = default!;
        public HttpCommandsExecutor Command { get; private set; } = default!;
        public HttpOperationsExecutor Operation { get; private set; } = default!;

        public override async Task InitializeAsync()
        {
            await base.InitializeAsync();

            Query = CreateQueriesExecutor();
            Command = CreateCommandsExecutor();
            Operation = CreateOperationsExecutor();

            await WaitForProcessingAsync();
        }

        public override async ValueTask DisposeAsync()
        {
            Command = default!;
            Query = default!;
            Operation = default!;
            await base.DisposeAsync();
        }
    }
}
