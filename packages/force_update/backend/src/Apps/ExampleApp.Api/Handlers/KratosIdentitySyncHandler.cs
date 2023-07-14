using System.Text.Json;
using System.Text.Json.Serialization;
using MassTransit;
using Microsoft.AspNetCore.Http;
using LeanCode.Kratos;
using LeanCode.Kratos.Model;
using LeanCode.TimeProvider;
using ExampleApp.Core.Services.Processes.Kratos;

namespace ExampleApp.Api.Handlers;

public partial class KratosIdentitySyncHandler : KratosWebHookHandlerBase
{
    private readonly Serilog.ILogger logger = Serilog.Log.ForContext<KratosIdentitySyncHandler>();

    private readonly IBus bus;

    public KratosIdentitySyncHandler(KratosWebHookHandlerConfig config, IBus bus)
        : base(config)
    {
        this.bus = bus;
    }

    protected override async Task HandleCoreAsync(HttpContext ctx)
    {
        var body = await JsonSerializer.DeserializeAsync(
            ctx.Request.Body,
            KratosIdentitySyncHandlerContext.Default.RequestBody,
            ctx.RequestAborted
        );

        var identity = body.Identity;

        if (identity is null)
        {
            logger.Error("Identity is null");
            await WriteErrorResponseAsync(
                ctx,
                new(1) { new(null, new(1) { new(1, "identity is null", "error", null) }) },
                422
            );
            return;
        }
        else if (identity.Id == default)
        {
            logger.Error("Identity Id is empty");
            await WriteErrorResponseAsync(
                ctx,
                new(1) { new(null, new(1) { new(2, "identity.id is empty", "error", null) }) },
                422
            );
            return;
        }

        await bus.Publish(
            new KratosIdentityUpdated(Guid.NewGuid(), Time.Now, identity),
            ctx.RequestAborted
        );
        ctx.Response.StatusCode = 200;

        logger.Information("Successfully processed sync webhook for identity {IdentityId}", identity.Id);
    }

    public record struct RequestBody([property: JsonPropertyName("identity")] Identity? Identity);

    [JsonSourceGenerationOptions(PropertyNamingPolicy = JsonKnownNamingPolicy.SnakeCaseLower)]
    [JsonSerializable(typeof(RequestBody))]
    private partial class KratosIdentitySyncHandlerContext : JsonSerializerContext { }
}
