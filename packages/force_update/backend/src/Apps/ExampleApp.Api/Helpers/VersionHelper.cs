using System.Reflection;

namespace ExampleApp.Api.Helpers;

public static class VersionHelper
{
    public static readonly string Version;

    static VersionHelper()
    {
        var self = Assembly.GetExecutingAssembly();
        var version = self.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "0.0.0";
        var name = self.GetName().Name;
        Version = $"{name} {version}";
    }
}
