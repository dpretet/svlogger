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

## How to

First instantiate and setup it in a module:

```verilog
    svlogger mylog;

    initial begin
        mylog = new("MyFSM", 1, 3);
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
- **debug**, printed in white
- **info**, printed in blue
- **warning**, printed in yellow
- **critical**, printed in pink
- **error**, printed in red


If verbosity is 0, no messages are logged. If equal to 1, everything is logged.
If verbosity=2, only info, warning, critical and errors and so on until 5. All
logs below the verbosity are discarded, all above are logged. For convenience,
multiple defines can be used:
- \`SVL_VERBOSE_OFF (0): No log
- \`SVL_VERBOSE_DEBUG (1): Debug
- \`SVL_VERBOSE_INFO (2): Info
- \`SVL_VERBOSE_WARNING (3): Warning
- \`SVL_VERBOSE_CRITICAL (4): Critical
- \`SVL_VERBOSE_ERROR (5): Error

Defines exist also to define the output routing:
- \`SVL_ROUTE_TERM (1): only to terminal
- \`SVL_ROUTE_FILE (2): only to log file
- \`SVL_ROUTE_ALL (3): in both terminal and log file

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
