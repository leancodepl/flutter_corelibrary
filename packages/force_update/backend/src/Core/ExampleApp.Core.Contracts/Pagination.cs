using LeanCode.Contracts;

namespace ExampleApp.Core.Contracts;

public abstract class PaginatedQuery<TResult> : IQuery<PaginatedResult<TResult>>
{
    public const int MinPageSize = 1;
    public const int MaxPageSize = 100;

    /// <remarks>Zero-based.</remarks>
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
}

public abstract class SortedQuery<TResult, TSort> : PaginatedQuery<TResult>
{
    public TSort SortBy { get; set; }
    public bool SortByDescending { get; set; }
}

public class PaginatedResult<TResult>
{
    public List<TResult> Items { get; set; }
    public int TotalCount { get; set; }
}
