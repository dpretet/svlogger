#!/usr/bin/env bash
set -e

#------------------------------------------------------------------------------
# Variables and setup
#------------------------------------------------------------------------------

test_ret=0
do_clean=0

# Use Icarus Verilog simulator
[[ -z $SIM ]] && SIM="icarus"

#------------------------------------------------------------------------------
# Grab arguments and values
#------------------------------------------------------------------------------

get_args() {

    while [ "$1" != "" ]; do
        case $1 in
             -s  | --simulator )
                shift
                SIM=$1
            ;;
            -c | --clean )
                do_clean=1
            ;;
            -h | --help )
                usage
                exit 0
            ;;
            * )
                usage
                exit 1
            ;;
        esac
        shift
    done
}


#------------------------------------------------------------------------------
# Cleaner
#------------------------------------------------------------------------------
clean() {
    echo "Clean-up"
    rm -f "*.txt"
    rm -f icarus.out
    rm -fr build
}

#------------------------------------------------------------------------------
# Helper
#------------------------------------------------------------------------------
usage() {
cat << EOF
usage: bash ./run.sh ...
-c    | --clean             Clean-up and exit
-s    | --simulator         Choose between icarus or verilator (icarus is default)
-h    | --help              Brings up this menu
        --simulator         Choose between icarus or verilator (icarus is default)
EOF
}

# Function to verify log merger output
verify_log_merger() {
    local sim_type=$1
    local merged_file="merged_${sim_type}_logs.txt"

    echo "Running Python log merger..."
    python3 ../svlogger.py MyFSM.txt --output "$merged_file"

    # Count log entries in merged file
    local merged_count=$(grep -c "@" "$merged_file" 2>/dev/null || echo "0")

    # Count log entries in input file
    local input_count=$(grep -c "@" "MyFSM.txt" 2>/dev/null || echo "0")

    # Verify counts match
    echo "Verifying log merger output..."
    if [[ $merged_count -eq $input_count ]]; then
        echo "✅ Log merger: All $merged_count entries found in $merged_file"
    else
        echo "⚠️  Log merger: Expected $input_count entries, found $merged_count in $merged_file"
    fi

    echo "Logs merged into $merged_file"
}

compile() {
    if [ "$SIM" == "icarus" ]; then
        iverilog -g2012 -Wall -o icarus.out -f files.f  fsm_example_testbench.sv ; vvp icarus.out
        verify_log_merger "icarus"

    else
        verilator -Wall --trace --Mdir build +1800-2017ext+sv \
            +1800-2005ext+v -Wno-STMTDLY -Wno-UNUSED -Wno-UNDRIVEN -Wno-PINCONNECTEMPTY \
            -Wpedantic -Wno-VARHIDDEN -Wno-lint \
            +incdir+. -f files.f \
            -cc --exe --build -j --top-module fsm_example_testbench \
            fsm_example_testbench.sv sim_main.cpp

        ./build/Vfsm_example_testbench
        verify_log_merger "verilator"
    fi
}
#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

main() {
    get_args "$@"

    if [ $do_clean -eq 1 ]; then
        clean
    else
        compile
    fi
}

main "$@"
