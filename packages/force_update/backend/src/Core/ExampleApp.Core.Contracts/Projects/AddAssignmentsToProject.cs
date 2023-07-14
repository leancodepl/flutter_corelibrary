using LeanCode.Contracts;
using LeanCode.Contracts.Security;

namespace ExampleApp.Core.Contracts.Projects;

[AllowUnauthorized]
public class AddAssignmentsToProject : ICommand
{
    public string ProjectId { get; set; }
    public List<AssignmentDTO> Assignments { get; set; }

    public static class ErrorCodes
    {
        public const int ProjectIdNotValid = 1;
        public const int ProjectDoesNotExist = 2;
        public const int AssignmentsCannotBeNull = 3;
        public const int AssignmentsCannotBeEmpty = 4;
    }
}

public class AssignmentDTO
{
    public string Name { get; set; }

    public class ErrorCodes
    {
        public const int NameCannotBeEmpty = 101;
        public const int NameTooLong = 102;
    }
}
