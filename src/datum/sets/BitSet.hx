package datum.sets;

import haxe.Exception;
import haxe.Int32;
import haxe.ds.Vector;

using fount.Core;
using datum.Core;

@:forward(size, capacity, iterator, hash, toStr, toRepr)
abstract BitSet(BitSetImpl) to Set<Int> {
    public static inline function create(capacity: Int): Set<Int> {
        return new BitSet(capacity);
    }

    public inline function new(capacity: Int) {
        this = new BitSetImpl(capacity);
    }

    public inline function add(i: Int): Bool {
        return this.add(i);
    }

    public inline function del(i: Int): Bool {
        return this.del(i);
    }

    @:arrayAccess
    public inline function has(i: Int): Bool {
        return this.has(i);
    }

    @:op(~A)
    public inline function not(): BitSet {
        return cast this.not();
    }

    @:op(!A)
    public inline function pureNot(): BitSet {
        return cast this.pureNot();
    }

    @:op(A |= B)
    public inline function or(rhs: BitSet): BitSet {
        return cast this.or(cast rhs);
    }

    @:op(A | B)
    public inline function pureOr(rhs: BitSet): BitSet {
        return cast this.pureOr(cast rhs);
    }

    @:op(A &= B)
    public inline function and(rhs: BitSet): BitSet {
        return cast this.and(cast rhs);
    }

    @:op(A & B)
    public inline function pureAnd(rhs: BitSet): BitSet {
        return cast this.pureAnd(cast rhs);
    }

    @:op(A ^= B)
    public inline function xor(rhs: BitSet): BitSet {
        return cast this.xor(cast rhs);
    }

    @:op(A ^ B)
    public inline function pureXor(rhs: BitSet): BitSet {
        return cast this.pureXor(cast rhs);
    }
}

private class BitSetImpl implements ISetImpl<Int> {
    static inline final INT_SHIFT_COUNT: Int = 5;
    static inline final SUBWORD_BITS: Int32 = (1 << INT_SHIFT_COUNT) - 1;
    static inline final MASK_1BIT: Int32 = 0x55555555;
    static inline final MASK_2BIT: Int32 = 0x33333333;
    static inline final MASK_4BIT: Int32 = 0x0f0f0f0f;
    static inline final ADD_MULT: Int32 = 0x01010101;
    static inline final ACC_SHIFT: Int = 4;
    static inline final EXTRACT_SHIFT: Int = 24;

    public var size(get, never): Int;

    inline function countSetBits(w: Int32): Int {
        // https://stackoverflow.com/a/109025
        w -= (w >>> 1) & MASK_1BIT;
        w = (w & MASK_2BIT) + ((w >>> 2) & MASK_2BIT);
        w = (((w + (w >>> ACC_SHIFT)) & MASK_4BIT) * ADD_MULT) >>> EXTRACT_SHIFT;
        return w;
    }

    function get_size(): Int {
        var sum = 0;
        for (i in 1...bits.length - 1) {
            sum += countSetBits(bits[i]);
        }
        sum += countSetBits(bits[bits.length - 1] & msb);
        return sum;
    }

    public var capacity(get, never): Int;

    inline function get_capacity(): Int {
        return bits[0];
    }

    final bits: Vector<Int32>;
    final msb: Int32;

    public function new(cap: Int) {
        if (cap < 0) throw new Exception('capacity must be a positive integer: $cap');

        // 0th element is used to store capacity
        final len = (cap >> INT_SHIFT_COUNT) + 1;
        final rem = cap & SUBWORD_BITS;
        if (rem == 0) {
            this.bits = new Vector(len);
            this.msb = 0;
        } else {
            this.bits = new Vector(len + 1);
            this.msb = (1 << rem) - 1;
        }

        bits[0] = cap;

        #if !static // on dynamic targets, arrays are initialized with null elements
        for (i in 1...bits.length) bits[i] = 0;
        #end
    }

    function validateIdx(i: Int): Void {
        if (i >= capacity || i < 0) throw new Exception('index out of bounds: $i for set with capacity $capacity');
    }

    // Converts bit index to word index.
    inline function widx(i: Int): Int {
        return (i >>> INT_SHIFT_COUNT) + 1;
    }

    // Converts bit index to bitmask
    inline function mask(i: Int): Int32 {
        return 1 << (i & SUBWORD_BITS);
    }

    inline function modify(i: Int, mod: (Int, Int32) -> Void): Bool {
        validateIdx(i);

        final idx = widx(i);
        final mask = mask(i);
        final isSet = bits[idx] & mask == mask;

        mod(idx, mask);
        return isSet;
    }

    public function add(i: Int): Bool {
        return modify(i, (idx, mask) -> bits[idx] |= mask);
    }

    public function del(i: Int): Bool {
        return modify(i, (idx, mask) -> bits[idx] &= ~mask);
    }

    public function has(i: Int): Bool {
        validateIdx(i);

        final idx = widx(i);
        final mask = mask(i);
        return bits[idx] & mask == mask;
    }

    public inline function iterator(): Iterator<Int> {
        return new BitIterator(bits);
    }

    public function not(): BitSetImpl {
        for (i in 1...bits.length) bits[i] = ~bits[i];
        return this;
    }

    public function pureNot(): BitSetImpl {
        final c = new BitSetImpl(capacity);
        for (i in 1...bits.length) c.bits[i] = ~bits[i];
        return c;
    }

    function validateCap(rhs: BitSetImpl): Void {
        if (rhs.capacity != capacity) throw new Exception('mismatched bitset sizes: $capacity != ${rhs.capacity}');
    }

    inline function binOp(op: (Int32, Int32) -> Int32, rhs: BitSetImpl): BitSetImpl {
        validateCap(rhs);
        for (i in 1...bits.length) bits[i] = op(bits[i], rhs.bits[i]);
        return this;
    }

    inline function pureBinOp(op: (Int32, Int32) -> Int32, rhs: BitSetImpl): BitSetImpl {
        validateCap(rhs);
        final c = new BitSetImpl(capacity);
        for (i in 1...bits.length) c.bits[i] = op(bits[i], rhs.bits[i]);
        return c;
    }

    public function or(rhs: BitSetImpl): BitSetImpl {
        return binOp((w1, w2) -> w1 | w2, rhs);
    }

    public function pureOr(rhs: BitSetImpl): BitSetImpl {
        return pureBinOp((w1, w2) -> w1 | w2, rhs);
    }

    public function and(rhs: BitSetImpl): BitSetImpl {
        return binOp((w1, w2) -> w1 & w2, rhs);
    }

    public function pureAnd(rhs: BitSetImpl): BitSetImpl {
        return pureBinOp((w1, w2) -> w1 & w2, rhs);
    }

    public function xor(rhs: BitSetImpl): BitSetImpl {
        return binOp((w1, w2) -> w1 ^ w2, rhs);
    }

    public function pureXor(rhs: BitSetImpl): BitSetImpl {
        return pureBinOp((w1, w2) -> w1 ^ w2, rhs);
    }

    public function hash(hasher: Hasher): Void {
        for (i in 0...bits.length) hasher.i32(bits[i]);
    }

    public function toStr(): String {
        final buf = new StringBuf();

        var i = 0;
        for (bi in this) {
            while (i++ < bi) buf.add("0");
            buf.add("1");
        }

        while (i++ < capacity) buf.add("0");

        return buf.toString().reverse();
    }

    public function toRepr(): String {
        final buf = new StringBuf();
        buf.add("BitSet { ");
        buf.add('capacity=$capacity');
        buf.add(', bits=[${bits[1].toHexRepr()}');
        for (i in 2...bits.length) {
            buf.add(", ");
            buf.add(bits[i].toHexRepr());
        }
        buf.add("] }");
        return buf.toString();
    }
}

private class BitIterator {
    static inline final MSB: Int32 = 1 << 31;

    var cap(get, never): Int;

    inline function get_cap(): Int {
        return bits[0];
    }

    final bits: Vector<Int32>;
    var w: Int;
    var mask: Int32;
    var i: Int;

    public function new(bits: Vector<Int32>) {
        this.bits = bits;
        this.w = 1;
        this.mask = 1;
        this.i = 0;
        findNext();
    }

    inline function inc(): Int {
        if (mask == MSB) {
            mask = 1;
            w++;
        } else mask <<= 1;
        return i++;
    }

    function findNext(): Void {
        while (i < cap) {
            if (bits[w] & mask != 0) break;
            inc();
        }
    }

    public #if !hl inline #end function hasNext(): Bool {
        return i < cap;
    }

    public function next(): Int {
        final index = inc();
        findNext();
        return index;
    }
}
