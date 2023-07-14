using System.Linq.Expressions;
using ExampleApp.Core.Contracts;
using Microsoft.EntityFrameworkCore;

namespace ExampleApp.Core.Services;

public static class CollectionExtensions
{
    public static IQueryable<T> ConditionalWhere<T>(
        this IQueryable<T> queryable,
        Expression<Func<T, bool>> predicate,
        bool condition
    )
    {
        return condition ? queryable.Where(predicate) : queryable;
    }

    public static IEnumerable<T> ConditionalWhere<T>(
        this IEnumerable<T> enumerable,
        Func<T, bool> predicate,
        bool condition
    )
    {
        return condition ? enumerable.Where(predicate) : enumerable;
    }

    public static IOrderedQueryable<TSource> OrderBy<TSource, TKey>(
        this IQueryable<TSource> queryable,
        Expression<Func<TSource, TKey>> selector,
        bool descending
    )
    {
        return descending ? queryable.OrderByDescending(selector) : queryable.OrderBy(selector);
    }

    public static IOrderedEnumerable<TSource> OrderBy<TSource, TKey>(
        this IEnumerable<TSource> queryable,
        Func<TSource, TKey> selector,
        bool descending
    )
    {
        return descending ? queryable.OrderByDescending(selector) : queryable.OrderBy(selector);
    }

    public static IQueryable<TResult> LeftJoin<TLeft, TRight, TKey, TResult>(
        this IQueryable<TLeft> left,
        IQueryable<TRight> right,
        Expression<Func<TLeft, TKey>> leftKeySelector,
        Expression<Func<TRight, TKey>> rightKeySelector,
        Expression<Func<TLeft, TRight?, TResult>> resultSelector
    )
    {
        var g = Expression.Parameter(typeof(Grouping<TLeft, TRight>), "g");
        var r = Expression.Parameter(typeof(TRight), "r");

        var keyAccessor = Expression.Property(g, Grouping<TLeft, TRight>.KeyPropertyInfo);
        var selectorInvocation = Expression.Invoke(resultSelector, keyAccessor, r);

        var lambda = Expression.Lambda<Func<Grouping<TLeft, TRight>, TRight?, TResult>>(selectorInvocation, g, r);

        return left.GroupJoin(
                right,
                leftKeySelector,
                rightKeySelector,
                (l, r) => new Grouping<TLeft, TRight> { Key = l, Values = r, }
            )
            .SelectMany(g => g.Values.DefaultIfEmpty(), lambda);
    }

    public static IEnumerable<TResult> LeftJoin<TLeft, TRight, TKey, TResult>(
        this IEnumerable<TLeft> left,
        IEnumerable<TRight> right,
        Func<TLeft, TKey> leftKeySelector,
        Func<TRight, TKey> rightKeySelector,
        Func<TLeft, TRight?, TResult> resultSelector
    )
    {
        return left.GroupJoin(
                right,
                leftKeySelector,
                rightKeySelector,
                (l, r) => new Grouping<TLeft, TRight> { Key = l, Values = r, }
            )
            .SelectMany(g => g.Values.DefaultIfEmpty(), (g, r) => resultSelector(g.Key, r));
    }

    private struct Grouping<TKey, TValue>
    {
        public TKey Key { get; set; }
        public IEnumerable<TValue> Values { get; set; }

        public static System.Reflection.PropertyInfo KeyPropertyInfo = typeof(Grouping<TKey, TValue>).GetProperty(
            nameof(Key)
        )!;
    }

    public static async Task<PaginatedResult<T>> ToPaginatedResultAsync<T>(
        this IQueryable<T> queryable,
        PaginatedQuery<T> query,
        CancellationToken cancellationToken = default
    )
    {
        var takeItems = Math.Clamp(query.PageSize, PaginatedQuery<T>.MinPageSize, PaginatedQuery<T>.MaxPageSize);

        var count = await queryable.CountAsync(cancellationToken);

        var items = await queryable
            .Skip(checked(Math.Max(query.PageNumber, 0) * takeItems))
            .Take(takeItems)
            .ToListAsync(cancellationToken);

        return new() { Items = items, TotalCount = count, };
    }
}
