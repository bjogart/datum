package tests;

import utest.Assert;
import utest.ITest;

using fount.Core;
using datum.Core;

class TestQueue implements ITest {
    public function new() {}

    function test_empty_init() {
        final q = new Queue();

        Assert.equals(0, q.size);
        Assert.isTrue(q.isEmpty());
    }

    function test_iter_init() {
        final q = new Queue([0, 1, 2]);

        Assert.equals(3, q.size);
        Assert.isFalse(q.isEmpty());
    }

    function test_push_adds_item_to_queue() {
        final q = new Queue();

        q.push(1);

        Assert.equals(1, q.size);
        Assert.isFalse(q.isEmpty());
    }

    function test_pop_empties_queue() {
        final q = new Queue();

        q.push(1);
        q.pop();

        Assert.equals(0, q.size);
        Assert.isTrue(q.isEmpty());
    }

    function test_fifo() {
        final q = new Queue();

        q.push(1);
        q.push(2);

        Assert.equals(1, q.pop().unwrap());
        Assert.equals(2, q.pop().unwrap());
    }

    function test_pop_on_empty_queue_evals_to_None() {
        final q = new Queue();

        Assert.isTrue(q.pop().isNone());
    }

    function test_pop_order() {
        final q = new Queue([0, 1, 2]);

        Assert.isTrue(0 == q.pop().unwrap());
        Assert.isTrue(1 == q.pop().unwrap());
        Assert.isTrue(2 == q.pop().unwrap());
        Assert.isTrue(q.pop().isNone());
    }

    function test_pop_vals_eq_peek_vals() {
        final q = new Queue([0, 1, 2]);

        Assert.isTrue(q.peek().equals(q.pop()));
        Assert.isTrue(q.peek().equals(q.pop()));
        Assert.isTrue(q.peek().equals(q.pop()));
        Assert.isTrue(q.peek().equals(q.pop()));
    }
}
