package datum.dicts;

using fount.Core;

@:forward(size, del, clear, keyValueIterator, toStr, toRepr)
abstract Dict<K, V>(DictImpl<K, V>) from DictImpl<K, V> to KeyValueIterable<K, V> {
    @:arrayAccess
    public inline function get(key: K): Option<V> {
        return this.get(key);
    }

    @:arrayAccess
    public inline function set(key: K, val: V): Option<V> {
        return this.set(key, val);
    }
}

@:forward(size, keyValueIterator, toStr, toRepr)
abstract FrozenDict<K, V>(Dict<K, V>) from Dict<K, V> to KeyValueIterable<K, V> {
    @:arrayAccess
    public inline function get(key: K): Option<V> {
        return this.get(key);
    }
}

typedef DictImpl<K, V> = {
    > KeyValueIterable<K, V>,
    var size(get, never): Int;
    function del(key: K): Option<V>;
    function get(key: K): Option<V>;
    function set(key: K, val: V): Option<V>;
    function clear(): Void;
}

interface IDictImpl<K, V> {
    var size(get, never): Int;
    function keyValueIterator(): KeyValueIterator<K, V>;
    function del(key: K): Option<V>;
    function get(key: K): Option<V>;
    function set(key: K, val: V): Option<V>;
    function clear(): Void;
}

class DictTools {
    public static function getOrSet<K, V>(dict: Dict<K, V>, key: K, defVal: () -> V): V {
        return switch dict[key] {
            case Some(val): val;
            case None:
                final val = defVal();
                dict[key] = val;
                return val;
        }
    }
}
