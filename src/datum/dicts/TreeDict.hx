package datum.dicts;

using tink.CoreApi;
using fount.Core;
using datum.Core;

class TreeDict<K, V> implements IDictImpl<K, V> {
    final comparator: (K, K) -> Int;
    var root: Option<Node<K, V>>;
    var _size: Int;

    public static inline function create<K: Ord<K>, V>(): Dict<K, V> {
        return new TreeDict((k1: K, k2: K) -> k1.cmp(k2));
    }

    public static inline function withComparator<K, V>(comparator: (K, K) -> Int): Dict<K, V> {
        return new TreeDict(comparator);
    }

    function new(comparator: (K, K) -> Int) {
        this.comparator = comparator;
        root = None;
        _size = 0;
    }

    public var size(get, never): Int;

    inline function get_size(): Int {
        return _size;
    }

    public function clear(): Void {
        root = None;
        _size = 0;
    }

    public function del(key: K): Option<V> {
        final tup = delete(root, key);
        root = tup.replace;
        if (tup.delVal.isSome()) _size--;
        return tup.delVal;
    }

    public inline function keyValueIterator(): KeyValueIterator<K, V> {
        return new TreeIterator(root);
    }

    public function get(key: K): Option<V> {
        return getRec(root, key);
    }

    function getRec(node: Option<Node<K, V>>, key: K): Option<V> {
        return switch node {
            case Some(node):
                final cmp = comparator(key, node.key);
                if (cmp < 0) {
                    getRec(node.left, key);
                } else if (cmp > 0) {
                    getRec(node.right, key);
                } else {
                    Some(node.val);
                }
            case None: None;
        }
    }

    public function set(key: K, val: V): Option<V> {
        final tup = insert(root, key, val);
        root = Some(tup.replace);
        if (tup.prev.isNone()) _size++;
        return tup.prev;
    }

    function insert(node: Option<Node<K, V>>, key: K, val: V): Inserted<K, V> {
        return switch node {
            case None: new Inserted(new Node(key, val), None);
            case Some(node):
                final cmp = comparator(key, node.key);
                final prev = if (cmp < 0) {
                    final tup = insert(node.left, key, val);
                    node.left = Some(tup.replace);
                    tup.prev;
                } else if (cmp > 0) {
                    final tup = insert(node.right, key, val);
                    node.right = Some(tup.replace);
                    tup.prev;
                } else {
                    final prev = node.val;
                    node.val = val;
                    Some(prev);
                }
                new Inserted(balance(node), prev);
        }
    }

    function balance(node: Node<K, V>): Node<K, V> {
        if (isRed(node.right) && !isRed(node.left)) node = rotateLeft(node);

        switch node.left {
            case Some(left) if (!left.isBlack && isRed(left.left)): node = rotateRight(node);
            case _:
        }

        if (isRed(node.left) && isRed(node.right)) flip(node);

        return node;
    }

    inline function isRed(node: Option<Node<K, V>>): Bool {
        return node.mapOr(n -> !n.isBlack, false);
    }

    function rotateLeft(node: Node<K, V>): Node<K, V> {
        final x = node.right.unwrap();
        node.right = x.left;
        x.left = Some(node);
        x.isBlack = node.isBlack;
        node.isBlack = false;
        return x;
    }

    function rotateRight(node: Node<K, V>): Node<K, V> {
        final x = node.left.unwrap();
        node.left = x.right;
        x.right = Some(node);
        x.isBlack = node.isBlack;
        node.isBlack = false;
        return x;
    }

    function flip(node: Node<K, V>): Void {
        node.isBlack = !node.isBlack;

        final left = node.left.unwrap();
        left.isBlack = !left.isBlack;

        final right = node.right.unwrap();
        right.isBlack = !right.isBlack;
    }

    function delete(node: Option<Node<K, V>>, key: K): Deleted<K, V> {
        return switch node {
            case None: new Deleted(node, None);
            case Some(node):
                final del = if (comparator(key, node.key) < 0) {
                    if (node.left.isNone()) return new Deleted(Some(node), None);

                    switch node.left {
                        case Some(left) if (left.isBlack && !isRed(left.left)): node = moveRedLeft(node);
                        case _:
                    }

                    final tup = delete(node.left, key);
                    node.left = tup.replace;
                    tup.delVal;
                } else {
                    if (isRed(node.left)) node = rotateRight(node);

                    switch node.right {
                        case None if (comparator(key, node.key) == 0): return new Deleted(None, Some(node.val));
                        case Some(right) if (right.isBlack && !isRed(right.left)): node = moveRedRight(node);
                        case _:
                    }

                    if (comparator(key, node.key) == 0) {
                        final del = node.val;
                        final tup = deleteSuccessor(node.right.unwrap());
                        node.key = tup.successor.key;
                        node.val = tup.successor.val;
                        node.right = tup.replace;
                        Some(del);
                    } else {
                        final tup = delete(node.right, key);
                        node.right = tup.replace;
                        tup.delVal;
                    }
                }

                new Deleted(Some(balance(node)), del);
        }
    }

    function deleteSuccessor(node: Node<K, V>): DelSuccessor<K, V> {
        if (node.left.isNone()) return new DelSuccessor(None, node);

        switch node.left {
            case Some(left) if (left.isBlack && !isRed(left.left)): node = moveRedLeft(node);
            case _:
        }

        final tup = deleteSuccessor(node.left.unwrap());
        node.left = tup.replace;
        return new DelSuccessor(Some(balance(node)), tup.successor);
    }

    function moveRedLeft(node: Node<K, V>): Node<K, V> {
        flip(node);
        final right = node.right.unwrap();
        if (isRed(right.left)) {
            node.right = Some(rotateRight(right));
            node = rotateLeft(node);
            flip(node);
        }
        return node;
    }

    function moveRedRight(node: Node<K, V>): Node<K, V> {
        flip(node);
        if (isRed(node.left.unwrap().left)) {
            node = rotateRight(node);
            flip(node);
        }
        return node;
    }
}

@:forward.new
abstract Inserted<K, V>(Pair<Node<K, V>, Option<V>>) {
    public var replace(get, never): Node<K, V>;
    public var prev(get, never): Option<V>;

    inline function get_replace(): Node<K, V> {
        return this.a;
    }

    inline function get_prev(): Option<V> {
        return this.b;
    }
}

@:forward.new
abstract Deleted<K, V>(Pair<Option<Node<K, V>>, Option<V>>) {
    public var replace(get, never): Option<Node<K, V>>;
    public var delVal(get, never): Option<V>;

    inline function get_replace(): Option<Node<K, V>> {
        return this.a;
    }

    inline function get_delVal(): Option<V> {
        return this.b;
    }
}

@:forward.new
abstract DelSuccessor<K, V>(Pair<Option<Node<K, V>>, Node<K, V>>) {
    public var replace(get, never): Option<Node<K, V>>;
    public var successor(get, never): Node<K, V>;

    inline function get_replace(): Option<Node<K, V>> {
        return this.a;
    }

    inline function get_successor(): Node<K, V> {
        return this.b;
    }
}

private class Node<K, V> {
    public var key: K;
    public var val: V;
    public var left: Option<Node<K, V>>;
    public var right: Option<Node<K, V>>;
    public var isBlack: Bool;

    public function new(k: K, v: V) {
        this.key = k;
        this.val = v;
        this.isBlack = false;
        this.left = None;
        this.right = None;
    }
}

private class TreeIterator<K, V> {
    final nodes: Stack<Node<K, V>>;

    public inline function new(root: Option<Node<K, V>>) {
        this.nodes = new Stack();

        traverseMin(root);
    }

    function traverseMin(node: Option<Node<K, V>>): Void {
        switch node {
            case None:
            case Some(node):
                nodes.push(node);
                traverseMin(node.left);
        }
    }

    public inline function hasNext(): Bool {
        return !nodes.isEmpty();
    }

    public function next(): { key: K, value: V } {
        final node = nodes.pop().unwrap();
        traverseMin(node.right);
        return { key: node.key, value: node.val };
    }
}
