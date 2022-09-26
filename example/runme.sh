#!/usr/bin/env bash


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

compile() {
    if [ "$SIM" == "icarus" ]; then
        iverilog -g2012 -Wall -o icarus.out -f files.f  fsm_example_testbench.sv ; vvp icarus.out
    else
        verilator -Wall --trace --Mdir build +1800-2017ext+sv \
            +1800-2005ext+v -Wno-STMTDLY -Wno-UNUSED -Wno-UNDRIVEN -Wno-PINCONNECTEMPTY \
            -Wpedantic -Wno-VARHIDDEN -Wno-lint \
            +incdir+. -f files.f \
            -cc --exe --build -j --top-module fsm_example_testbench \
            fsm_example_testbench.sv sim_main.cpp

        make -j -C build -f Vfsm_example_testbench.mk Vfsm_example_testbench

        ./build/Vfsm_example_testbench
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
