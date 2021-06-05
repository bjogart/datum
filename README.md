# Datum: Customizable dictionaries, sets, and other collections.
This library contains alternatives to the Haxe built-in `Map`. While a great data structure in its own right, it cannot, for example, distinguish between two separate structures that contain the same values. Hence Datum was born:

```haxe
using datum.Core;

final dict = TreeDict.withComparator((s1, s2) -> s1.length - s2.length); // or TreeDict.create() if key has a `key.cmp(otherKey: K): Int` method

dict.set("one", 1);
dict["three"] = 3; // set/get can also be used w/ array syntax
dict["four"] = 4;
dict["one"] = 6; // replaces 1 w/ 6; returns the previous value, e.g. Some(1)

dict.get("one"); // == Some(6)
dict["five"]; // == None, since "five" is not in the dictionary

dict.del("one"); // returns the previous value, e.g. Some(6)
dict.del("eight"); // returns None, since "eight" is not in the dictionary

for (key => _ in dict) trace(key); // "three", "four", sorted by key length
```

- Dictionaries (`Dict`) are included as an alternative to `Map`. Each dictionary has `set`, `get` (lookup) and `del` (delete) methods. `set` and `get` can also be used using array syntax. Readonly dictionaries are also included as `FrozenDict`.
    * `TreeDict` is an implementation of a [left-leaning red-black tree](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.139.282), which has `O(log(n))` time & space complexity for all operations.
- Sets (`Set`) only contain unique values. Each set has `add`, `del`, and `has` methods, as well as the usual `iterator`. Readonly sets are included as `FrozenSet`.
    * `BitSet` stores indices compactly as a vector of bits. It implements the usual set operations, and also elementwise bit operations, such as `and`, `or`, and `not`.
- Buffers are collections with `push`/`pop` semantics; right now, `Stacks` and `Queues` are supported as abstractions over standard library types.
