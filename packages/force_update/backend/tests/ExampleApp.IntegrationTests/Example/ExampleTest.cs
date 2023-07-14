using ExampleApp.Core.Contracts.Projects;
using Xunit;

namespace ExampleApp.IntegrationTests.Example
{
    public class ExampleTest : TestsBase<UnauthenticatedExampleAppTestApp>
    {
        [Fact]
        public async Task Example_test()
        {
            var result = await App.Command.RunAsync(new CreateProject { Name = "Project" });

            Assert.True(result.WasSuccessful);

            var projects = await App.Query.GetAsync(new AllProjects());
            var project = Assert.Single(projects);

            Assert.Equal("Project", project.Name);
            Assert.Matches("^project_[0-7][0-9A-HJKMNP-TV-Z]{25}$", project.Id);

            var projectDetails = await App.Query.GetAsync(new ProjectDetails { Id = project.Id });

            Assert.NotNull(projectDetails);
            Assert.Equal(project.Id, projectDetails.Id);
            Assert.Equal(project.Name, projectDetails.Name);
            Assert.Empty(projectDetails.Assignments);
        }
    }
}
