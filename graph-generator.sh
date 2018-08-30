#!/usr/bin/env bash

lgus='anini-y arteche carles dipolog jose-panganiban maasim macarthur masinloc mercedes pagsanghan rtlim socorro'
scenarios='bau fish-catch fisher-revenue both'
files='baseline accessibility adoption sufficiency sustainability'

for file in $files; do
    for lgu in $lgus; do
        for scenario in $scenarios; do
            str="python image-builder.py $lgu $scenario $file y"
            eval $str
        done
    done
done