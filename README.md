# OpenTypeSwift

Simple API for OpenType tables, extending `CTFont`. Core Text provides access to the raw data, 
this library just makes it nice to use from Swift, with named accessors for all supported values.


## Example

Check if the MATH table is present:

```swift
let helvetica12 = FontMetrics(name: "Helvetica", size: 12.0)
if let metrics = helvetica12.mathMetrics() {
    print("That's surprising!")
}
```

Access a constant, scaled to the font size:

```swift
let lm12 = FontMetrics(name: "Latin Modern Math", size: 12.0)
let metrics = lm12.mathMetrics()!
print("axis height above baseline, in pts: \(metrics.axisHeight)")  // 3.0
```

## Tests

The Latin Modern Math font is required to run the tests. It can be downloaded from 
[CTAN](https://ctan.org/tex-archive/fonts/lm-math).


## Status

OpenType is a very large spec, with many archaic corners. This library isn't intended to be complete by any stretch.

In fact, it currently provides only the MathConstants values from the `MATH` table. If you'd like to see something
else, please submit an issue or PR.


## See also

[CoreTextSwift](https://github.com/krzyzanowskim/CoreTextSwift) uses a similar approach to
expose the existing Core Text APIs in a nice way, and was an inspiration.

Microsoft's [OpenType spec](https://docs.microsoft.com/en-us/typography/opentype/spec)
is the best reference.

