package tests;

import utest.Assert;
import utest.ITest;

using fount.Core;
using datum.Core;

class TestStack implements ITest {
    public function new() {}

    function test_empty_init() {
        final s = new Stack();

        Assert.equals(0, s.size);
        Assert.isTrue(s.isEmpty());
    }

    function test_iter_init() {
        final s = new Stack([0, 1, 2]);

        Assert.equals(3, s.size);
        Assert.isFalse(s.isEmpty());
    }

    function test_push_adds_item_to_stack() {
        final s = new Stack();

        s.push(1);

        Assert.equals(1, s.size);
        Assert.isFalse(s.isEmpty());
    }

    function test_pop_empties_stack() {
        final s = new Stack();

        s.push(1);
        s.pop();

        Assert.equals(0, s.size);
        Assert.isTrue(s.isEmpty());
    }

    function test_lifo() {
        final s = new Stack();

        s.push(1);
        s.push(2);

        Assert.isTrue(2 == s.pop().unwrap());
        Assert.isTrue(1 == s.pop().unwrap());
    }

    function test_pop_on_empty_stack_evals_to_None() {
        final s = new Stack();

        Assert.isTrue(s.pop().isNone());
    }

    function test_pop_order() {
        final s = new Stack([0, 1, 2]);

        Assert.isTrue(2 == s.pop().unwrap());
        Assert.isTrue(1 == s.pop().unwrap());
        Assert.isTrue(0 == s.pop().unwrap());
        Assert.isTrue(s.pop().isNone());
    }

    function test_pop_vals_eq_peek_vals() {
        final s = new Stack([0, 1, 2]);

        Assert.isTrue(s.peek().equals(s.pop()));
        Assert.isTrue(s.peek().equals(s.pop()));
        Assert.isTrue(s.peek().equals(s.pop()));
        Assert.isTrue(s.peek().equals(s.pop()));
    }
}
