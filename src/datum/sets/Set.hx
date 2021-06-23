package datum.sets;

using fount.Core;

@:forward(size, add, del, iterator)
abstract Set<T>(SetImpl<T>) from SetImpl<T> to Iterable<T> {
    @:arrayAccess
    public inline function has(v: T): Bool {
        return this.has(v);
    }
}

@:forward(size, iterator)
abstract FrozenSet<T>(SetImpl<T>) from SetImpl<T> to Iterable<T> {
    @:arrayAccess
    public inline function has(v: T): Bool {
        return this.has(v);
    }
}

typedef SetImpl<T> = {
    > Iterable<T>,
    var size(get, never): Int;
    function add(v: T): Bool;
    function del(v: T): Bool;
    function has(v: T): Bool;
}

interface ISetImpl<T> {
    var size(get, never): Int;
    function iterator(): Iterator<T>;
    function add(v: T): Bool;
    function del(v: T): Bool;
    function has(v: T): Bool;
}
