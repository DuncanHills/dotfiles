#!/bin/bash
#
# License: Attribution 3.0 Unported (CC BY 3.0)
# License URI: https://creativecommons.org/licenses/by/3.0/
# Author: Michael Plotke
# Source: http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux#256%20%288-bit%29%20Colors
#
# This file echoes a bunch of color codes to the terminal to demonstrate
# what's available. Each line is the color code of one forground color,
# out of 17 (default + 16 escapes), followed by a test use of that color
# on all nine background colors (default + 8 escapes).
#
T='gYw'   # The test text
echo -e "\n                 40m     41m     42m     43m     44m     45m     46m     47m";
for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' '1;32m' \
           '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' '  36m' '1;36m' \
           '  37m' '1;37m'; do
    FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
        echo -en "$EINS \033[$FG\033[$BG  $T \033[0m\033[$BG \033[0m";
    done
    echo;
done
echo
echo "Usage: \\033[#m where # can be a valid set of semicolon separated numbers"
echo
