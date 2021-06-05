package tests;

import utest.Assert;
import utest.ITest;

using fount.Core;
using datum.Core;

class TestTreeDict implements ITest {
    static final KEYS: Array<Int> = [1, 2, 3, 6, 5, 4, 8, 0, 9, 7];
    static final VALS: Array<Int> = [for (i in 0...10) i];
    static final SORTED_KEYS: Array<Int> = [for (i in 0...10) i];
    static final SORTED_VALS: Array<Int> = [7, 0, 1, 2, 5, 4, 3, 9, 6, 8];

    public function new() {}

    var d: Dict<Int, Int>;

    function setup() {
        d = TreeDict.withComparator(IntTools.cmp);
    }

    function test_new_dict_has_size_0() {
        Assert.equals(0, d.size);
    }

    function test_set() {
        for (i in 0...10) {
            Assert.isTrue((d[KEYS[i]] = VALS[i]).isNone());
            Assert.equals(i + 1, d.size);
        }

        Assert.equals(10, d.size);
        var i = 0;
        for (key => value in d.keyValueIterator()) {
            Assert.equals(SORTED_KEYS[i], key);
            Assert.equals(SORTED_VALS[i], value);
            i++;
        }
        Assert.equals(9, (d[7] = 20).unwrap());
    }

    function test_get() {
        for (i in 0...10) d[KEYS[i]] = VALS[i];

        for (i in 0...10) Assert.equals(VALS[i], d[KEYS[i]].unwrap());

        var i = 0;
        for (key => value in d.keyValueIterator()) {
            Assert.equals(SORTED_KEYS[i], key);
            Assert.equals(SORTED_VALS[i], value);
            i++;
        }
        Assert.equals(10, i);
    }

    function test_del() {
        for (i in 0...10) d[KEYS[i]] = VALS[i];

        for (i in 0...10) {
            Assert.equals(VALS[i], d.del(KEYS[i]).unwrap());
            Assert.equals(9 - i, d.size);
        }

        Assert.isFalse(d.keyValueIterator().hasNext());
    }

    function test_crud() {
        for (_ in 0...100000) {
            final key = Std.random(1000);
            final val = Std.random(IntTools.MAX);
            final op = Std.random(2);
            switch op {
                case 0:
                    if (!d[key].equals(d[key] = val) || val != d[key].unwrap()) {
                        Assert.fail();
                        return;
                    }
                case 1:
                    if (!d[key].equals(d.del(key)) || d[key].isSome()) {
                        Assert.fail();
                        return;
                    }
            }
        }
        Assert.pass();
    }
}
