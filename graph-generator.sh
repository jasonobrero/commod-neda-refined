#!/usr/bin/env bash

lgus='lcli lchi hcli hchi universe jomalig dinapigue'
scenarios='bau fish-catch fisher-revenue both'
files='accessibility adoption sufficiency sustainability'

for file in $files; do
    for lgu in $lgus; do
        for scenario in $scenarios; do
            str="python image-builder.py $lgu $scenario $file y"
            eval $str
        done
    done
done