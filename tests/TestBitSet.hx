package tests;

import utest.Assert;
import utest.ITest;

using fount.Core;
using datum.Core;

class TestBitSet implements ITest {
    public function new() {}

    static inline final SET_CAP: Int = 48;
    static inline final HALF_CAP: Int = 24;

    var s: BitSet;

    function setup() {
        s = new BitSet(SET_CAP);
    }

    function test_negative_capacity_raises_error() {
        Assert.raises(() -> new BitSet(-1));
    }

    function test_size_is_0_on_set_init() {
        Assert.equals(0, s.size);
    }

    function test_size_increments_on_add() {
        for (i in 0...SET_CAP) {
            Assert.equals(i, s.size);
            s.add(i);
        }
        Assert.equals(SET_CAP, s.size);
    }

    function test_size_decrements_on_del() {
        for (i in 0...SET_CAP) s.add(i);

        for (i in 0...SET_CAP) {
            Assert.equals(SET_CAP - i, s.size);
            s.del(i);
        }
        Assert.equals(0, s.size);
    }

    function test_size_does_not_count_last_word_remainder() {
        ~s;
        Assert.equals(SET_CAP, s.size);
    }

    function test_add_returns_false_if_value_is_not_in_set() {
        Assert.isFalse(s.add(0));
    }

    function test_add_returns_false_if_value_is_in_set() {
        s.add(0);
        Assert.isTrue(s.add(0));
    }

    function test_add_errors_on_negative_index() {
        Assert.raises(() -> s.add(-1));
    }

    function test_add_errors_on_index_outside_capacity() {
        Assert.raises(() -> s.add(s.capacity));
    }

    function test_del_returns_false_if_value_is_not_in_set() {
        Assert.isFalse(s.del(0));
    }

    function test_del_returns_false_if_value_is_in_set() {
        s.add(0);
        Assert.isTrue(s.del(0));
        Assert.isFalse(s.del(0)); // did the delete go through?
    }

    function test_del_errors_on_negative_index() {
        Assert.raises(() -> s.del(-1));
    }

    function test_del_errors_on_index_outside_capacity() {
        Assert.raises(() -> s.del(s.capacity));
    }

    function test_has_returns_false_if_value_is_not_in_set() {
        Assert.isFalse(s[0]);
    }

    function test_has_returns_false_if_value_is_in_set() {
        s.add(0);
        Assert.isTrue(s[0]);
    }

    function test_has_errors_on_negative_index() {
        Assert.raises(() -> s.has(-1));
    }

    function test_has_errors_on_index_outside_capacity() {
        Assert.raises(() -> s.has(s.capacity));
    }

    function test_add_del_has_combo() {
        for (i in 0...SET_CAP) {
            Assert.isFalse(s[i]);
            s.add(i);
            Assert.isTrue(s[i]);
            s.del(i);
            Assert.isFalse(s[i]);
        }
    }

    function test_not() {
        for (i in 0...SET_CAP) Assert.isFalse(s[i]);
        ~s;
        for (i in 0...SET_CAP) Assert.isTrue(s[i]);
    }

    function test_pureNot() {
        final n = !s;
        for (i in 0...SET_CAP) {
            Assert.isFalse(s[i]);
            Assert.isTrue(n[i]);
        }
    }

    function test_or_with_mismatched_sets_raises() {
        final s2 = new BitSet(2 * SET_CAP);
        Assert.raises(() -> s |= s2);
    }

    function test_or() {
        final s2 = new BitSet(SET_CAP);

        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);
        for (i in 0...HALF_CAP) s2.add(i);
        s |= s2;

        for (i in 0...SET_CAP) Assert.isTrue(s[i] == i.isEven() || i < HALF_CAP);
    }

    function test_pureOr_with_mismatched_sets_raises() {
        final s2 = new BitSet(2 * SET_CAP);
        Assert.raises(() -> s | s2);
    }

    function test_pureOr() {
        final s2 = new BitSet(SET_CAP);

        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);
        for (i in 0...HALF_CAP) s2.add(i);
        final r = s | s2;

        for (i in 0...SET_CAP) Assert.isTrue(r[i] == i.isEven() || i < HALF_CAP);
    }

    function test_and_with_mismatched_sets_raises() {
        final s2 = new BitSet(2 * SET_CAP);
        Assert.raises(() -> s &= s2);
    }

    function test_and() {
        final s2 = new BitSet(SET_CAP);

        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);
        for (i in 0...HALF_CAP) s2.add(i);
        s &= s2;

        for (i in 0...SET_CAP) Assert.isTrue((i.isEven() && i < HALF_CAP) == s[i]);
    }

    function test_pureAnd_with_mismatched_sets_raises() {
        final s2 = new BitSet(2 * SET_CAP);
        Assert.raises(() -> s & s2);
    }

    function test_pureAnd() {
        final s2 = new BitSet(SET_CAP);

        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);
        for (i in 0...HALF_CAP) s2.add(i);
        final r = s & s2;

        for (i in 0...SET_CAP) Assert.isTrue((i.isEven() && i < HALF_CAP) == r[i]);
    }

    function test_xor_with_mismatched_sets_raises() {
        final s2 = new BitSet(2 * SET_CAP);
        Assert.raises(() -> s ^= s2);
    }

    function xor(a: Bool, b: Bool): Bool {
        return (a || b) && !(a && b);
    }

    function test_xor() {
        final s2 = new BitSet(SET_CAP);

        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);
        for (i in 0...HALF_CAP) s2.add(i);
        s ^= s2;

        for (i in 0...SET_CAP) Assert.isTrue(s[i] == xor(i.isEven(), i < HALF_CAP));
    }

    function test_pureXor_with_mismatched_sets_raises() {
        final s2 = new BitSet(2 * SET_CAP);
        Assert.raises(() -> s ^ s2);
    }

    function test_pureXor() {
        final s2 = new BitSet(SET_CAP);

        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);
        for (i in 0...HALF_CAP) s2.add(i);
        final r = s ^ s2;

        for (i in 0...SET_CAP) Assert.isTrue(r[i] == xor(i.isEven(), i < HALF_CAP));
    }

    function test_iterator_has_no_next_for_empty_set() {
        Assert.isFalse(s.iterator().hasNext());
    }

    function test_iterator_retrieves_right_items() {
        for (i in 0...SET_CAP) if (i.isEven() || i < HALF_CAP) s.add(i);
        final it = s.iterator();

        for (i in 0...HALF_CAP) {
            Assert.isTrue(it.hasNext());
            Assert.equals(i, it.next());
        }
        for (i in HALF_CAP...SET_CAP) {
            if (i.isEven()) {
                Assert.isTrue(it.hasNext());
                Assert.equals(i, it.next());
            }
        }
        Assert.isFalse(it.hasNext());
    }

    function test_iterator_retrieves_right_items_if_last_word_has_remainder() {
        ~s;
        final it = s.iterator();
        for (i in 0...SET_CAP) {
            Assert.isTrue(it.hasNext());
            Assert.equals(i, it.next());
        }
        Assert.isFalse(it.hasNext());
    }

    function test_toStr_byte() {
        final b = new BitSet(8);

        b.add(0);
        b.add(1);
        b.add(4);
        b.add(5);
        b.add(7);

        Assert.equals("10110011", b.toStr());
    }

    function test_toStr_with_empty_set() {
        Assert.equals("000000000000000000000000000000000000000000000000", s.toStr());
    }

    function test_toStr_with_alternating_bytes() {
        for (i in 0...8) s.add(i);
        for (i in 16...24) s.add(i);
        for (i in 32...40) s.add(i);

        Assert.equals("000000001111111100000000111111110000000011111111", s.toStr());
    }

    function test_toStr_with_set_of_ones() {
        for (i in 0...SET_CAP) s.add(i);

        Assert.equals("111111111111111111111111111111111111111111111111", s.toStr());
    }

    function test_toStr_with_0s_and_1s() {
        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);

        Assert.equals("010101010101010101010101010101010101010101010101", s.toStr());
    }

    function test_toRepr_with_empty_set() {
        Assert.equals("BitSet { capacity=48, bits=[0x0, 0x0] }", s.toRepr());
    }

    function test_toRepr_with_alternating_bytes() {
        for (i in 0...8) s.add(i);
        for (i in 16...24) s.add(i);
        for (i in 32...40) s.add(i);

        Assert.equals("BitSet { capacity=48, bits=[0xff00ff, 0xff] }", s.toRepr());
    }

    function test_toRepr_with_set_of_ones() {
        for (i in 0...SET_CAP) s.add(i);

        Assert.equals("BitSet { capacity=48, bits=[0xffffffff, 0xffff] }", s.toRepr());
    }

    function test_toRepr_with_0s_and_1s() {
        for (i in 0...SET_CAP) if (i.isEven()) s.add(i);

        Assert.equals("BitSet { capacity=48, bits=[0x55555555, 0x5555] }", s.toRepr());
    }
}
