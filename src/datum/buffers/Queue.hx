package datum.buffers;

using fount.Core;
using datum.Core;

class Queue<T> implements IBuffer<T> {
    public var size(get, never): Int;

    inline function get_size(): Int {
        return queue.length;
    }

    final queue: List<T>;

    public inline function new(?vs: Iterator<T>) {
        queue = new List();
        if (vs != null) for (v in vs) push(v);
    }

    public inline function push(v: T): Void {
        queue.add(v);
    }

    public inline function pop(): Option<T> {
        @:nullSafety(Off) return size == 0 ? None : Some(queue.pop());
    }

    public inline function peek(): Option<T> {
        @:nullSafety(Off) return size == 0 ? None : Some(queue.first());
    }

    public inline function isEmpty(): Bool {
        return queue.isEmpty();
    }

    public inline function isNotEmpty(): Bool {
        return !queue.isEmpty();
    }
}
