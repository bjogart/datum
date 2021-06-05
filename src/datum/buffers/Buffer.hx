package datum.buffers;

using fount.Core;

typedef Buffer<T> = {
    var size(get, never): Int;
    function push(v: T): Void;
    function pop(): Option<T>;
    function peek(): Option<T>;
}

interface IBuffer<T> {
    var size(get, never): Int;
    function push(v: T): Void;
    function pop(): Option<T>;
    function peek(): Option<T>;
}

class BufferTools {
    public inline function isEmpty<T>(iter: Buffer<T>): Bool {
        return iter.size == 0;
    }

    public inline function isNotEmpty<T>(iter: Buffer<T>): Bool {
        return iter.size > 0;
    }
}
