package tests;

import utest.Runner;
import utest.ui.Report;

function main(): Void {
    final runner = new Runner();

    runner.addCase(new TestBitSet());
    runner.addCase(new TestQueue());
    runner.addCase(new TestStack());
    runner.addCase(new TestTreeDict());

    Report.create(runner);
    runner.run();
}
