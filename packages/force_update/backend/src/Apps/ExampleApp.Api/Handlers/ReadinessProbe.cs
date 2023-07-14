using Microsoft.AspNetCore.Http;

namespace ExampleApp.Api.Handlers;

public static class ReadinessProbe
{
    public static Task HandleAsync(HttpContext ctx)
    {
        ctx.Response.StatusCode = 200;
        return ctx.Response.WriteAsync("Ready");
    }
}
