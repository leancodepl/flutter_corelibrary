using LeanCode.Contracts;
using LeanCode.Contracts.Security;

namespace ExampleApp.Core.Contracts.Projects;

[AllowUnauthorized]
public class ProjectDetails : IQuery<ProjectDetailsDTO?>
{
    public string Id { get; set; }
}

public class ProjectDetailsDTO : ProjectDTO
{
    public List<AssignmentDTO> Assignments { get; set; }
}
