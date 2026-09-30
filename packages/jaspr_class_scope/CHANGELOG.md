## 0.1.1

- Add `ClassScope.root`, the component's own class, named after the component
  in kebab case.
- Let `ClassName +` take a nullable class; adding `null` adds nothing.
- Add `+` on `ClassName?` too, so a sum may start with a class that can be
  null. It is null only when both sides are.

## 0.1.0

- Initial release.
