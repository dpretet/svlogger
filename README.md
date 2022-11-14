![CI](https://github.com/dpretet/svlogger/actions/workflows/ci.yaml/badge.svg?branch=main)
[![GitHub license](https://img.shields.io/github/license/dpretet/svlogger)](https://github.com/dpretet/svlogger/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/dpretet/svlogger)](https://github.com/dpretet/svlogger/issues)
[![GitHub stars](https://img.shields.io/github/stars/dpretet/svlogger)](https://github.com/dpretet/svlogger/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/dpretet/svlogger)](https://github.com/dpretet/svlogger/network)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/dpretet/svlogger?style=social)](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2Fdpretet%2Fsvlogger)

# SVLogger

A SystemVerilog logger to help designers to log events in a circuit during a
simulation in a consistent way. SVLogger is a simple class, easy to instantiate
and use, with no dependencies.

## Setup

Just include in source file:

```verilog
`include "svlogger.sv"
```

and into the fileset:

```
+incdir+SVLOGGER_PATH
```

Please notice this project has been developed and tested with Icarus Verilog 11 and Verilator 5. It
can't work with oldest versions. SVlogger could probably work with other (commercial) simulators but
it never has been tested oustide iverilog and verilator scope.

## How to

First instantiate and setup it in a module:

```verilog
    svlogger mylog;

    initial begin
        mylog = new("MyFSM", `SVL_VERBOSE_DEBUG, `SVL_ROUTE_TERM);
    end
```

Then call a function to print a message:

```verilog
    always @ (posedge aclk or negedge aresetn) begin

        ...
            case (fsm)
                default: begin
                    mylog.debug("Start in IDLE state");
                    fsm <= ONE;
                end
        ...
            endcase
        end
    end
```

A complete example of svlogger usage is present in [example](./example) folder.

The class is setup with three arguments:
- **name**: the identifier printed first in the log associated to the
  module under debug.
- **verbosity**: 0 deactivate all logs, upper values define the filtering level
  of the logging.
- **route**: 1 print in console, 2 print in a log file (name.log), 3 in both.


Five functions are available to print a message by severity level:
- ⬜️ **debug**, printed in white
- 🟦 **info**, printed in blue
- 🟨 **warning**, printed in yellow
- 🟪 **critical**, printed in pink
- 🟥 **error**, printed in red


If verbosity is 0, no messages are logged. If equal to 1, everything is logged.
If verbosity=2, only info, warning, critical and errors and so on until 5. All
logs below the verbosity are discarded, all above are logged.

For convenience, multiple defines can be used:
- **\`SVL_VERBOSE_OFF** (0)
- **\`SVL_VERBOSE_DEBUG** (1)
- **\`SVL_VERBOSE_INFO`** (2)
- **\`SVL_VERBOSE_WARNING** (3)
- **\`SVL_VERBOSE_CRITICAL** (4)
- **\`SVL_VERBOSE_ERROR** (5)

Defines exist also to define the output routing:
- **\`SVL_ROUTE_TERM** (1)
- **\`SVL_ROUTE_FILE** (2)
- **\`SVL_ROUTE_ALL** (3)

Messages are logged with embedded timeframe. To have a pretty-print of $realtime,
you can setup the format with the next trick, for instance in your testbench:

```verilog
// $timeformat(<unit_number>, <precision>, <suffix_string>, <minimum field width>);
initial $timeformat(-9, 1, "ns", 8);
```

This should produce a similar output:

```bash
MyCircuit: ERROR: (@ 406.0ns) Moving in a new state
```

## License

This repo is licensed under MIT license. It grants nearly all rights to use,
modify and distribute these sources. However, consider to contribute and provide
updates to this core if you add feature and fix, would be greatly appreciated :)
