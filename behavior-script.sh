populations=(lcli lchi hcli hchi universe jomalig dinapigue)
scenarios=(bau fish-catch fisher-revenue both)
criteria=(baseline accessibility sufficiency adoption sustainability)

str1='./netlogo-headless.sh --model ~/Desktop/commod-neda-refined/commod.nlogo --experiment '
str2=' --threads 4 --spreadsheet ~/Desktop/commod-neda-refined/rpg_'
str3='_results/'
str4='.csv'

for population in ${populations[@]}; do
  for scenario in ${scenarios[@]}; do
    for criterion in ${criteria[@]}; do
        eval $str1$population-$scenario-$criterion$str2$criterion$str3$criterion-$population-$scenario$str4
        done
    done
done