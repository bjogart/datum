package datum.buffers;

import haxe.ds.GenericStack;

using fount.Core;
using datum.Core;

class Stack<T> implements IBuffer<T> {
    public var size(get, never): Int;

    inline function get_size(): Int {
        return _size;
    }

    final stack: GenericStack<T>;
    var _size: Int;

    public inline function new(?vs: Iterable<T>) {
        stack = new GenericStack();
        _size = 0;
        if (vs != null) for (v in vs) push(v);
    }

    public function push(v: T): Void {
        stack.add(v);
        _size++;
    }

    public function pop(): Option<T> {
        return if (_size == 0) {
            None;
        } else {
            _size--;
            @:nullSafety(Off) return Some(stack.pop());
        }
    }

    public inline function peek(): Option<T> {
        return stack.isEmpty() ? None : Some(stack.head.elt);
    }

    public inline function isEmpty(): Bool {
        return stack.isEmpty();
    }

    public inline function isNotEmpty(): Bool {
        return !stack.isEmpty();
    }
}
