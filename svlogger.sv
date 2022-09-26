// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

`ifndef SVLOGGER
`define SVLOGGER

`define SVL_VERBOSE_OFF 0
`define SVL_VERBOSE_DEBUG 1
`define SVL_VERBOSE_INFO 2
`define SVL_VERBOSE_WARNING 3
`define SVL_VERBOSE_CRITICAL 4
`define SVL_VERBOSE_ERROR 5

`define SVL_ROUTE_TERM 1
`define SVL_ROUTE_FILE 2
`define SVL_ROUTE_ALL 3


class svlogger;

    ////////////////////////////////////////////
    // Name of the module printed in the console
    // and/or the log file name
    string name;

    ///////////////////////////////////
    // Verbosity level of the instance:
    //   - 0: no logging
    //   - 1: debug/info/warning/critical/error
    //   - 2: info/warning/critical/error
    //   - 3: warning/critical/error
    //   - 4: critical/error
    //   - 5: error
    int verbosity;

    ///////////////////////////////////////////////////////
    // Define if log in the console, in a log file or both:
    //   - 1: console only
    //   - 2: log file only
    //   - 3: console and log file
    int route;

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
        if (this.route==`SVL_ROUTE_FILE || this.route==`SVL_ROUTE_ALL) begin
            this.f = $fopen({this.name, ".txt"},"w");
        end
    endfunction

    // Internal function to log into console and/or log file
    // Internal use only
    task _log_text(string text);
    begin
        string t_text;
        if (this.route==`SVL_ROUTE_TERM || this.route==`SVL_ROUTE_ALL) begin
            $display(text);
        end
        if (this.route==`SVL_ROUTE_FILE || this.route==`SVL_ROUTE_ALL) begin
            $sformat(t_text, "%s\n", text);
            $fwrite(this.f, t_text);
        end
    end
    endtask

    // Just write a message without any formatting neither time printed
    // Could be used for further explanation of a previous debug/info ...
    task msg(string text);
    begin
        _log_text(text);
    end
    endtask

    // Print a debug message, in white
    task debug(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_INFO && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            $sformat(t_text, "\033[0;37m%s: DEBUG: (@ %0t) %s \033[0m", this.name, $realtime, text);
            _log_text(t_text);
        end
    end
    endtask

    // Print an info message, in blue
    task info(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_WARNING && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            $sformat(t_text, "\033[0;34m%s: INFO: (@ %0t) %s \033[0m", this.name, $realtime, text);
            _log_text(t_text);
        end
    end
    endtask

    // Print a warning message, in yellow
    task warning(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_CRITICAL && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            $sformat(t_text, "\033[1;33m%s: WARNING: (@ %0t) %s \033[0m", this.name, $realtime, text);
            _log_text(t_text);
        end
    end
    endtask

    // Print a critical message, in pink
    task critical(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_ERROR && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            $sformat(t_text, "\033[1;35m%s: CRITICAL: (@ %0t) %s \033[0m", this.name, $realtime, text);
            _log_text(t_text);
        end
    end
    endtask

    // Print an error message, in red
    task error(string text);
    begin
        if (this.verbosity<`SVL_VERBOSE_ERROR+1 && this.verbosity>`SVL_VERBOSE_OFF) begin
            string t_text;
            $sformat(t_text, "\033[1;31m%s: ERROR: (@ %0t) %s \033[0m", this.name, $realtime, text);
            _log_text(t_text);
        end
    end
    endtask

endclass
`endif
