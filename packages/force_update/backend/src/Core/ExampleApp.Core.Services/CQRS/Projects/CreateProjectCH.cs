using ExampleApp.Core.Contracts.Projects;
using ExampleApp.Core.Domain.Projects;
using FluentValidation;
using LeanCode.CQRS.Execution;
using LeanCode.CQRS.Validation.Fluent;
using LeanCode.DomainModels.DataAccess;
using Microsoft.AspNetCore.Http;

namespace ExampleApp.Core.Services.CQRS.Projects;

public class CreateProjectCV : AbstractValidator<CreateProject>
{
    public CreateProjectCV()
    {
        RuleFor(cmd => cmd.Name)
            .NotEmpty()
            .WithCode(CreateProject.ErrorCodes.NameCannotBeEmpty)
            .MaximumLength(500)
            .WithCode(CreateProject.ErrorCodes.NameTooLong);
    }
}

public class CreateProjectCH : ICommandHandler<CreateProject>
{
    private readonly Serilog.ILogger logger = Serilog.Log.ForContext<CreateProjectCH>();

    private readonly IRepository<Project, ProjectId> projects;

    public CreateProjectCH(IRepository<Project, ProjectId> projects)
    {
        this.projects = projects;
    }

    public Task ExecuteAsync(HttpContext context, CreateProject command)
    {
        var project = Project.Create(command.Name);
        projects.Add(project);

        logger.Information("Project {ProjectId} added", project.Id);

        return Task.CompletedTask;
    }
}
