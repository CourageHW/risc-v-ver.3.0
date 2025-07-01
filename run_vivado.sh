#!/bin/zsh
clear

if [ "$1" = "-gui" ]; then
    echo "============================================"
    echo "| Starting Vivado in GUI Mode...           |"
    echo "============================================"
    vivado -mode batch -notrace -nojournal -nolog -source simulate.tcl -tclargs gui
else
    echo "============================================"
    echo "| Starting Vivado in Batch Mode            |"
    echo "============================================"
    vivado -mode batch -notrace -nojournal -nolog -source simulate.tcl
fi

echo "\n=========================================="
echo "|       Vivado Script Finished           |"
echo "=========================================="
