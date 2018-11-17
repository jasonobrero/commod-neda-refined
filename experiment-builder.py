#Import dependencies
import csv
import os
import sys
import plotly
import plotly.graph_objs as go

#Initialization of constants
lgus = ["magsingal", "dinapigue", "masinloc", "nasugbu", "jomalig",
            "quezon", "gasan", "mansalay", "jose_panganiban", "mercedes",
            "claveria", "anini_y", "carles", "toboso", "daanbantayan",
            "bien_unido", "pagsanghan", "arteche", "macarthur",
            "baliguian", "dipolog", "rtlim", "maasim", "socorro",
            "lcli", "lchi", "hcli", "hchi", "universe"]
scenarios = ["bau", "fish_catch", "fisher_revenue", "both"] 
criteria = ["baseline", "adoption", "accessibility", "sufficiency",
            "sustainability"]

masinloc = {'blgu': 2, 'mplgu': 14, 'bd': 2, 'academe': 0, 'business': 1, 'nga': 1}
dinapigue = {'blgu': 16, 'mplgu': 2, 'bd': 0, 'academe': 0, 'business': 0, 'nga': 1}
anini_y = {'blgu': 4, 'mplgu': 3, 'bd': 6, 'academe': 0, 'business': 0, 'nga': 0}
macarthur = {'blgu': 3, 'mplgu': 6, 'bd': 5, 'academe': 0, 'business': 0, 'nga': 0}
pagsanghan = {'blgu': 13, 'mplgu': 5, 'bd': 0, 'academe': 0, 'business': 1, 'nga': 0}
claveria = {'blgu': 0, 'mplgu': 0, 'bd': 0, 'academe': 0, 'business': 0, 'nga': 0}
baliguian = {'blgu': 0, 'mplgu': 1, 'bd': 0, 'academe': 0, 'business': 0, 'nga': 0}
socorro = {'blgu': 5, 'mplgu': 3, 'bd': 0, 'academe': 0, 'business': 5, 'nga': 0}
bien_unido = {'blgu': 2, 'mplgu': 4, 'bd': 0, 'academe': 0, 'business': 12, 'nga': 1}
carles = {'blgu': 8, 'mplgu': 4, 'bd': 1, 'academe': 0, 'business': 1, 'nga': 0}
magsingal = {'blgu': 1, 'mplgu': 9, 'bd': 0, 'academe': 0, 'business': 0, 'nga': 1}
gasan = {'blgu': 18, 'mplgu': 3, 'bd': 1, 'academe': 0, 'business': 0, 'nga': 1}
jose_panganiban = {'blgu': 7, 'mplgu': 7, 'bd': 1, 'academe': 0, 'business': 0, 'nga': 2}
mansalay = {'blgu': 0, 'mplgu': 15, 'bd': 4, 'academe': 0, 'business': 2, 'nga': 0}
maasim = {'blgu': 12, 'mplgu': 4, 'bd': 0, 'academe': 0, 'business': 0, 'nga': 0}
toboso = {'blgu': 5, 'mplgu': 5, 'bd': 0, 'academe': 0, 'business': 1, 'nga': 0}
jomalig = {'blgu': 9, 'mplgu': 8, 'bd': 1, 'academe': 2, 'business': 0, 'nga': 1}
quezon = {'blgu': 7, 'mplgu': 0, 'bd': 1, 'academe': 1, 'business': 1, 'nga': 3}
dipolog = {'blgu': 1, 'mplgu': 10, 'bd': 5, 'academe': 1, 'business': 0, 'nga': 1}
rtlim = {'blgu': 0, 'mplgu': 5, 'bd': 1, 'academe': 0, 'business': 0, 'nga': 0}
arteche = {'blgu': 1, 'mplgu': 6, 'bd': 2, 'academe': 0, 'business': 3, 'nga': 2}
daanbantayan = {'blgu': 4, 'mplgu': 5, 'bd': 11, 'academe': 0, 'business': 2, 'nga': 0}
mercedes = {'blgu': 4, 'mplgu': 10, 'bd': 0, 'academe': 1, 'business': 0, 'nga': 1}
nasugbu = {'blgu': 0, 'mplgu': 0, 'bd': 0, 'academe': 0, 'business': 0, 'nga': 0}

lcli = {'blgu': 38, 'mplgu': 30, 'bd': 13, 'academe': 0, 'business': 2, 'nga': 2}
lchi = {'blgu': 15, 'mplgu': 12, 'bd': 1, 'academe': 0, 'business': 18, 'nga': 1}
hcli = {'blgu': 43, 'mplgu': 43, 'bd': 6, 'academe': 0, 'business': 3, 'nga': 4}
hchi = {'blgu': 26, 'mplgu': 44, 'bd': 21, 'academe': 5, 'business': 6, 'nga': 8}
universe = {'blgu': 122, 'mplgu': 129, 'bd': 29, 'academe': 5, 'business': 29, 'nga': 15}

baseline = {'sufficiency-w': 25, 'accessibility-w': 25, 'adoption-w': 25, 'sustainability-w': 25}
adoption = {'sufficiency-w': 10, 'accessibility-w': 30, 'adoption-w': 35, 'sustainability-w': 25}
accessibility = {'sufficiency-w': 25, 'accessibility-w': 35, 'adoption-w': 30, 'sustainability-w': 10}
sufficiency = {'sufficiency-w': 35, 'accessibility-w': 25, 'adoption-w': 10, 'sustainability-w': 30}
sustainability = {'sufficiency-w': 30, 'accessibility-w': 10, 'adoption-w': 25, 'sustainability-w': 35}

a = []
s = ""
lgu_swap = ""
scenario_swap = ""

for lgu in lgus:
    for scenario in scenarios:
        for criterion in criteria:
            lgu_swap = lgu
            scenario_swap = scenario
            if "_" in lgu_swap:
                lgu_swap = lgu_swap.replace("_", "-")
            if "_" in scenario_swap:
                scenario_swap = scenario_swap.replace("_", "-")
            a.append(lgu_swap+"-"+scenario_swap+"-"+criterion)
            a.append(scenario_swap)
            a.append(lgu_swap)
            exec("a.append("+lgu+"['blgu'])")
            exec("a.append("+lgu+"['mplgu'])")
            exec("a.append("+lgu+"['bd'])")
            exec("a.append("+lgu+"['business'])")
            exec("a.append("+lgu+"['academe'])")
            exec("a.append("+lgu+"['nga'])")
            exec("a.append("+criterion+"['sufficiency-w'])")
            exec("a.append("+criterion+"['accessibility-w'])")
            exec("a.append("+criterion+"['adoption-w'])")
            exec("a.append("+criterion+"['sustainability-w'])")
            
            s = '''\t<experiment name="''' + a[0] + '''" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 25</exitCondition>
    <metric>sum [pf] of blgu-players</metric>
    <metric>sum [pf] of mplgu-players</metric>
    <metric>sum [pf] of bd-players</metric>
    <metric>sum [pf] of academe-players</metric>
    <metric>sum [pf] of business-players</metric>
    <metric>sum [pf] of nga-players</metric>
    <metric>sum [pf] of turtles</metric>
    <metric>sum [nf] of blgu-players</metric>
    <metric>sum [nf] of mplgu-players</metric>
    <metric>sum [nf] of bd-players</metric>
    <metric>sum [nf] of academe-players</metric>
    <metric>sum [nf] of business-players</metric>
    <metric>sum [nf] of nga-players</metric>
    <metric>sum [nf] of turtles</metric>
    <metric>sum [g] of blgu-players</metric>
    <metric>sum [g] of mplgu-players</metric>
    <metric>sum [g] of bd-players</metric>
    <metric>sum [g] of academe-players</metric>
    <metric>sum [g] of business-players</metric>
    <metric>sum [g] of nga-players</metric>
    <metric>sum [g] of turtles</metric>
    <metric>sum [cw] of blgu-players</metric>
    <metric>sum [cw] of mplgu-players</metric>
    <metric>sum [cw] of bd-players</metric>
    <metric>sum [cw] of academe-players</metric>
    <metric>sum [cw] of business-players</metric>
    <metric>sum [cw] of nga-players</metric>
    <metric>sum [cw] of turtles</metric>
    <metric>sum [ps] of blgu-players</metric>
    <metric>sum [ps] of mplgu-players</metric>
    <metric>sum [ps] of bd-players</metric>
    <metric>sum [ps] of academe-players</metric>
    <metric>sum [ps] of business-players</metric>
    <metric>sum [ps] of nga-players</metric>
    <metric>sum [ps] of turtles</metric>
    <metric>sum [lb] of blgu-players</metric>
    <metric>sum [lb] of mplgu-players</metric>
    <metric>sum [lb] of bd-players</metric>
    <metric>sum [lb] of academe-players</metric>
    <metric>sum [lb] of business-players</metric>
    <metric>sum [lb] of nga-players</metric>
    <metric>sum [lb] of turtles</metric>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;''' + a[1] + '''&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;''' + a[2] + '''&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="''' + str(a[3]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="''' + str(a[4]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="''' + str(a[5]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="''' + str(a[6]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="''' + str(a[7]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="''' + str(a[8]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="''' + str(a[9]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="''' + str(a[10]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="''' + str(a[11]) + '''"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="''' + str(a[12]) + '''"/>
    </enumeratedValueSet>
  </experiment>'''
  
            print(s)

            s = ""
            a = []

