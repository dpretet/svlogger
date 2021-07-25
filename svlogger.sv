// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`timescale 1 ns / 1 ps
`default_nettype none

`ifndef SVLOGGER
`define SVLOGGER

class svlogger;

    ////////////////////////////////////////////
    // Name of the module printed in the console
    // and/or the log file name
    string  name;

    ///////////////////////////////////
    // Verbosity level of the instance:
    //   - 0: no logging
    //   - 1: debug/info/warning/critical/error
    //   - 2: info/warning/critical/error
    //   - 3: warning/critical/error
    //   - 4: critical/error
    //   - 5: error
    int     verbosity;

    ///////////////////////////////////////////////////////
    // Define if log in the console, in a log file or both:
    //   - 1: console only
    //   - 2: log file only
    //   - 3: console and log file
    int  route;

    // internal variable to build messages
    string _msg;
    string _time;
    // pointer to log file
    integer f;

    // color codes:
    // BLACK      "\033[1;30m"
    // RED        "\033[1;31m"
    // GREEN      "\033[1;32m"
    // BROWN      "\033[1;33m"
    // BLUE       "\033[1;34m"
    // PINK       "\033[1;35m"
    // CYAN       "\033[1;36m"
    // WHITE      "\033[1;37m"
    // NC         "\033[0m"

    // constructor
    function new(
        string  _name,
        int     _verbosity,
        int     _route
    );
        this.name = _name;
        this.verbosity = _verbosity;
        this.route = _route;
        if (route==2 || route==3) begin
            f = $fopen({this.name, ".txt"},"w");
        end
    endfunction

    task debug(string message);
    begin
        if (this.verbosity<2 && this.verbosity>0) begin
        if (this.route==1 || this.route==3) begin
        $display("\033[1;37m%s: DEBUG: (@ %0t) %s \033[0m", this.name, $realtime, message);
        end
        if (route==2 || route==3) begin
        $fwrite(f, "\033[1;37m%s: DEBUG: (@ %0t) %s \033[0m\n", this.name, $realtime, message);
        end
        end
    end
    endtask

    task info(string message);
    begin
        if (this.verbosity<3 && this.verbosity>0) begin
        if (this.route==1 || this.route==3) begin
        $display("\033[1;34m%s: INFO: (@ %0t) %s \033[0m", this.name, $realtime, message);
        end
        if (route==2 || route==3) begin
            $fwrite(f, "\033[1;34m%s: INFO: (@ %0t) %s \033[0m\n", this.name, $realtime, message);
        end
        end
    end
    endtask

    task warning(string message);
    begin
        if (this.verbosity<4 && this.verbosity>0) begin
        if (this.route==1 || this.route==3) begin
        $display("\033[1;33m%s: WARNING: (@ %0t) %s \033[0m", this.name, $realtime, message);
        end
        if (route==2 || route==3) begin
            $fwrite(f, "\033[1;33m%s: WARNING: (@ %0t) %s \033[0m\n", this.name, $realtime, message);
        end
        end
    end
    endtask

    task critical(string message);
    begin
        if (this.verbosity<5 && this.verbosity>0) begin
        if (this.route==1 || this.route==3) begin
        $display("\033[1;35m%s: CRITICAL: (@ %0t) %s \033[0m", this.name, $realtime, message);
        end
        if (route==2 || route==3) begin
            $fwrite(f, "\033[1;35m%s: CRITICAL: (@ %0t) %s \033[0m\n", this.name, $realtime, message);
        end
        end
    end
    endtask

    task error(string message);
    begin
        if (this.verbosity<6 && this.verbosity>0) begin
        if (this.route==1 || this.route==3) begin
        $display("\033[1;31m%s: ERROR: (@ %0t) %s \033[0m", this.name, $realtime, message);
        end
        if (route==2 || route==3) begin
            $fwrite(f, "\033[1;31m%s: ERROR: (@ %0t) %s \033[0m\n", this.name, $realtime, message);
        end
        end
    end
    endtask

endclass
`endif
