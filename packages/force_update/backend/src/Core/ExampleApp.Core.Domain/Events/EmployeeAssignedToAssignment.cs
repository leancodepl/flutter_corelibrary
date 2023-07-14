using System.Text.Json.Serialization;
using ExampleApp.Core.Domain.Employees;
using ExampleApp.Core.Domain.Projects;
using LeanCode.DomainModels.Model;
using LeanCode.TimeProvider;

namespace ExampleApp.Core.Domain.Events;

public class EmployeeAssignedToAssignment : IDomainEvent
{
    public Guid Id { get; private init; }
    public DateTime DateOccurred { get; private init; }

    public AssignmentId AssignmentId { get; private init; }
    public EmployeeId EmployeeId { get; private init; }

    public EmployeeAssignedToAssignment(AssignmentId assignmentId, EmployeeId employeeId)
    {
        Id = Guid.NewGuid();
        DateOccurred = Time.NowWithOffset.UtcDateTime;

        AssignmentId = assignmentId;
        EmployeeId = employeeId;
    }

    [JsonConstructor]
    public EmployeeAssignedToAssignment(
        Guid id,
        DateTime dateOccurred,
        AssignmentId assignmentId,
        EmployeeId employeeId
    )
    {
        Id = id;
        DateOccurred = dateOccurred;

        AssignmentId = assignmentId;
        EmployeeId = employeeId;
    }
}
