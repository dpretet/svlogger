/// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"

`timescale 1 ns / 100 ps

module fsm_example_testbench();

    `SVUT_SETUP

    parameter NAME = 0;

    logic aclk;
    logic aresetn;

    fsm
    #(
    NAME
    )
    dut
    (
    aclk,
    aresetn
    );

    // To create a clock:
    initial aclk = 0;
    always #2 aclk = ~aclk;

    initial $timeformat(-9, 1, "ns", 8);

    // To dump data for visualization:
    // initial begin
    //     $dumpfile("fsm_example_testbench.vcd");
    //     $dumpvars(0, fsm_example_testbench);
    // end

    task setup(msg="");
    begin
        aresetn = 1'b0;
        #10;
        aresetn = 1'b1;
    end
    endtask

    task teardown(msg="");
    begin
        /// teardown() runs when a test ends
    end
    endtask

    `TEST_SUITE("SUITE_NAME")

    ///    Available macros:"
    ///
    ///    - `MSG("message"):       Print a raw white message
    ///    - `INFO("message"):      Print a blue message with INFO: prefix
    ///    - `SUCCESS("message"):   Print a green message if SUCCESS: prefix
    ///    - `WARNING("message"):   Print an orange message with WARNING: prefix and increment warning counter
    ///    - `CRITICAL("message"):  Print a purple message with CRITICAL: prefix and increment critical counter
    ///    - `ERROR("message"):     Print a red message with ERROR: prefix and increment error counter
    ///
    ///    - `FAIL_IF(aSignal):                 Increment error counter if evaluaton is true
    ///    - `FAIL_IF_NOT(aSignal):             Increment error coutner if evaluation is false
    ///    - `FAIL_IF_EQUAL(aSignal, 23):       Increment error counter if evaluation is equal
    ///    - `FAIL_IF_NOT_EQUAL(aSignal, 45):   Increment error counter if evaluation is not equal
    ///    - `ASSERT(aSignal):                  Increment error counter if evaluation is not true
    ///    - `ASSERT((aSignal == 0)):           Increment error counter if evaluation is not true
    ///
    ///    Available flag:
    ///
    ///    - `LAST_STATUS: tied to 1 is last macro did experience a failure, else tied to 0

    `UNIT_TEST("TEST_NAME")

        /// Describe here the testcase scenario
        ///
        /// Because SVUT uses long nested macros, it's possible
        /// some local variable declaration leads to compilation issue.
        /// You should declare your variables after the IOs declaration to avoid that.

        #100

    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
