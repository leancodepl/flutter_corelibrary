using LeanCode.AzureIdentity;
using LeanCode.Logging;
using LeanCode.Startup.MicrosoftDI;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace ExampleApp.Api;

public class Program
{
    public static Task Main() => CreateWebHostBuilder().Build().RunAsync();

    public static IHostBuilder CreateWebHostBuilder()
    {
        return LeanProgram
            .BuildMinimalHost<Startup>()
            .AddAppConfigurationFromAzureKeyVaultOnNonDevelopmentEnvironment()
            .ConfigureDefaultLogging("ExampleApp", new[] { typeof(Program).Assembly });
    }
}
