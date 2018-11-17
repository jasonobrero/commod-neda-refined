#!/usr/bin/env bash

lgus='magsingal dinapigue masinloc nasugbu jomalig quezon gasan mansalay jose-panganiban mercedes claveria anini-y carles toboso daanbantayan bien-unido pagsanghan arteche macarthur baliguian dipolog rtlim maasim socorro'
scenarios='bau fish-catch fisher-revenue both'
files='baseline'

for file in $files; do
    for lgu in $lgus; do
        for scenario in $scenarios; do
            str="python image-builder-stakeholder.py $lgu $scenario $file y"
            eval $str
        done
    done
done