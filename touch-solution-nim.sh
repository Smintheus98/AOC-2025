#!/usr/bin/env bash

argc=$#
argv=($*)

# print help message
function print_help {
    echo "touch-solution-nim <name, e.g. a, b>"
}

function make_main_body {
    cat << EOF
import std / [strutils, sequtils]
import parsecli, utils

#type 

proc main =
  let infile = getInputFile()

when isMainModule:
  main()

EOF
}

for i in `seq 0 $((argc - 1))` ; do
    arg=${argv[$i]}
    case $arg in
        "-h" | "--help")
            print_help
            exit 0
            ;;
        -*)
            echo "Error: invalid option $arg!"
            print_help
            exit 1
            ;;
        "")
            echo "Error: missing argument!"
            print_help
            exit 1
            ;;
        *)
            file=$arg.nim
            make_main_body >> $file
            ;;
    esac
done

if [[ $argc -eq 0 ]] ; then
    echo "Error: missing argument!"
    print_help
    exit 1
fi
