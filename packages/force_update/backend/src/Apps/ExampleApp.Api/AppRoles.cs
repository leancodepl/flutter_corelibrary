using LeanCode.CQRS.Security;

using R = ExampleApp.Core.Contracts.Auth.Roles;

namespace ExampleApp.Api;

internal class AppRoles : IRoleRegistration
{
    public IEnumerable<Role> Roles { get; } = new[] { new Role(R.User, R.User), new Role(R.Admin, R.Admin), };
}
