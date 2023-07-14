using LeanCode.DomainModels.Ids;
using LeanCode.DomainModels.Model;

namespace ExampleApp.Core.Domain.Employees;

[TypedId(TypedIdFormat.PrefixedUlid, CustomPrefix = "employee")]
public readonly partial record struct EmployeeId;

public class Employee : IAggregateRoot<EmployeeId>
{
    public EmployeeId Id { get; private init; }
    public string Name { get; private set; } = default!;
    public string Email { get; private set; } = default!;

    DateTime IOptimisticConcurrency.DateModified { get; set; }

    private Employee() { }

    public static Employee Create(string name, string email)
    {
        return new Employee
        {
            Id = EmployeeId.New(),
            Name = name,
            Email = email,
        };
    }
}
