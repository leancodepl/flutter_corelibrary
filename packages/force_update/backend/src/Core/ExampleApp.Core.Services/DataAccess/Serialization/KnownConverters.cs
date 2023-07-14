using System.Text.Json;
using System.Text.Json.Serialization;

namespace ExampleApp.Core.Services.DataAccess.Serialization;

public static class KnownConverters
{
    public static IEnumerable<JsonConverter> All { get; } = Array.Empty<JsonConverter>();

    public static JsonSerializerOptions AddAll(JsonSerializerOptions settings)
    {
        // MassTransit uses static configuration (singleton) so we need not to stomp on our feet
        lock (settings.Converters)
        {
            foreach (var c in All)
            {
                if (!settings.Converters.Contains(c))
                {
                    settings.Converters.Add(c);
                }
            }
        }

        return settings;
    }
}
