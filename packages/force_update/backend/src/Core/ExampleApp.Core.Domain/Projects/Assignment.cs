using ExampleApp.Core.Domain.Employees;
using LeanCode.DomainModels.Ids;
using LeanCode.DomainModels.Model;

namespace ExampleApp.Core.Domain.Projects;

[TypedId(TypedIdFormat.PrefixedUlid, CustomPrefix = "assignment")]
public readonly partial record struct AssignmentId;

public class Assignment : IIdentifiable<AssignmentId>
{
    public AssignmentId Id { get; private init; }
    public string Name { get; private set; } = default!;
    public AssignmentStatus Status { get; private set; }
    public EmployeeId? AssignedEmployeeId { get; private set; }

    public ProjectId ParentProjectId { get; private init; } = default!;
    public Project ParentProject { get; private init; } = default!;

    private Assignment() { }

    public static Assignment Create(Project parentProject, string name)
    {
        return new Assignment
        {
            Id = AssignmentId.New(),
            Name = name,
            ParentProject = parentProject,
            ParentProjectId = parentProject.Id,
            Status = AssignmentStatus.NotStarted,
        };
    }

    public void Edit(string name)
    {
        Name = name;
    }

    public void AssignEmployee(EmployeeId employeeId)
    {
        AssignedEmployeeId = employeeId;
    }

    public void UnassignEmployee()
    {
        AssignedEmployeeId = null;
    }

    public void ChangeStatus(AssignmentStatus status)
    {
        Status = status;
    }

    public enum AssignmentStatus
    {
        NotStarted,
        InProgress,
        Finished,
    }
}
