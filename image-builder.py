#Import dependencies
import csv
import os
import sys
import plotly
import plotly.graph_objs as go
import plotly.io as pio

plotly.io.orca.config.executable = '/home/neda-anres/miniconda2/bin/orca'

#Initialization of constants
lgus = ["magsingal", "dinapigue", "masinloc", "nasugbu", "jomalig",
            "quezon", "gasan", "mansalay", "jose-panganiban", "mercedes",
            "claveria", "anini-y", "carles", "toboso", "daanbantayan",
            "bien-unido", "pagsanghan", "arteche", "macarthur",
            "baliguian", "dipolog", "rtlim", "maasim", "socorro",
            "lcli", "lchi", "hcli", "hchi", "universe"]
scenarios = ["bau", "fish-catch", "fisher-revenue", "both"] 
criteria = ["baseline", "adoption", "accessibility", "sufficiency",
            "sustainability"]

#Error checking of argument count
if not len(sys.argv) == 4:
    raise ValueError('Usage: python image-builder.py <lgu> <scenario> <criteria>.')

#Assigning of command line arguments
lgu = sys.argv[1]
scenario = sys.argv[2]
criterion = sys.argv[3]
download = sys.argv[4]

#Checking validity of command line arguments
if lgu not in lgus:
    raise ValueError('Chosen LGU not in proper list of LGUs.')
if scenario not in scenarios:
    raise ValueError('Chosen scenario not in proper list of scenarios.')
if criterion not in criteria:
    raise ValueError('Chosen criterion not in proper list of criteria.')

#File input
space = " "
fileDir = os.path.dirname(os.path.realpath('__file__'))
fileName = "rpg_" + criterion + "_results/" + criterion + "-" + lgu + "-" + scenario + ".csv"

#Initialization of list variables
lines = []

pf = []
nf = []
g = []
cw = []
ps = []
lb = []

pf_total = []
nf_total = []
g_total = []
cw_total = []
ps_total = []
lb_total = []

#Parsing the files
#All lines of the CSV file are contained in the list named 'lines'
with open(os.path.join(fileDir, fileName)) as f:
    for row in f:
        lines.append(row.split(","))

#How to process each line
#There are 25 lines, for 25 ticks.
#Tick number 1 starts at line 28 (zero indexing is used)
ticks = 25
for tick in range(0, ticks):
    #Get the line of the CSV
    x = lines[28 + tick]

    #Remove first column
    del x[0]

    #Remove stray new lines and quotation marks
    x = [s.replace('\"', '') for s in x]
    x = [s.replace('\n', '') for s in x]
    x = [float(s) for s in x]

    #Get the total scores for all agents for each of the financing scheme
    for i in range(6, len(x), 42):
        pf.append(x[i+(7*0)])
        nf.append(x[i+(7*1)])
        g.append(x[i+(7*2)])
        cw.append(x[i+(7*3)])
        ps.append(x[i+(7*4)])
        lb.append(x[i+(7*5)])

    #Set up the running totals of the financing schemes for all experiments
    l = {'pf': 0, 'nf': 0, 'g': 0, 'cw': 0, 'ps': 0, 'lb': 0}

    #For all experiments
    for i in range(0, 100):
        #Get the score for each scheme for each experiment
        #Add the score to the running total
        l['pf'] += pf[i]
        l['nf'] += nf[i]
        l['g'] +=  g[i]
        l['cw'] += cw[i]
        l['ps'] += ps[i]
        l['lb'] += lb[i]

    #Compute for the average total score for all experiments, across all persons
    for k, v in l.items():
        l[k] /= 10000

    #Get the average score for all experiments
    pf_total.append(l['pf'])
    nf_total.append(l['nf'])
    g_total.append(l['g'])
    cw_total.append(l['cw'])
    ps_total.append(l['ps'])
    lb_total.append(l['lb'])

    l.clear()
    pf = []
    nf = []
    g = []
    cw = []
    ps = []
    lb = []

#Data for graphs
timestep = range(1, ticks + 1)

#Create traces
trace_pf = go.Scatter(
    x = timestep,
    y = pf_total,
    mode = 'markers',
    name = 'Public Funds'
)

trace_nf = go.Scatter(
    x = timestep,
    y = nf_total,
    mode = 'markers',
    name = 'National Funds'
)

trace_g = go.Scatter(
    x = timestep,
    y = g_total,
    mode = 'markers',
    name = 'Grants'
)

trace_cw = go.Scatter(
    x = timestep,
    y = cw_total,
    mode = 'markers',
    name = 'Credit Windows'
)

trace_ps = go.Scatter(
    x = timestep,
    y = ps_total,
    mode = 'markers',
    name = 'Private Sector'
)

trace_lb = go.Scatter(
    x = timestep,
    y = lb_total,
    mode = 'markers',
    name = 'Local Bonds'
)

label_lgu = {
    "magsingal": "Magsingal, Ilocos Sur",
    "dinapigue": "Dinapigue, Isabela",
    "masinloc": "Masinloc, Zambales",
    "nasugbu": "Nasugbu, Batangas",
    "jomalig": "Jomalig, Quezon Province",
    "quezon": "Quezon, Palawan",
    "gasan": "Gasan, Marinduque",
    "mansalay": "Mansalay, Oriental Mindoro",
    "jose-panganiban": "Jose Panganiban, Camarines Norte",
    "mercedes": "Mercedes, Camarines Norte",
    "claveria": "Claveria, Misamis Oriental",
    "anini-y": "Anini-y, Antique",
    "carles": "Carles, Iloilo",
    "toboso": "Toboso, Negros Occidental",
    "daanbantayan": "Daanbantayan, Cebu",
    "bien-unido": "Bien Unido, Bohol",
    "pagsanghan": "Pagsanghan, Samar",
    "arteche": "Arteche, Eastern Samar",
    "macarthur": "MacArthur, Leyte",
    "baliguian": "Baliguian, Zamboanga del Norte",
    "dipolog": "Dipolog City, Zamboanga del Norte",
    "rtlim": "Roseller T. Lim, Zamboanga Sibugay",
    "maasim": "Maasim, Sarangani",
    "socorro": "Socorro, Surigao del Norte",
    "lcli": "Low Cost Low Impact Municipalities",
    "lchi": "Low Cost High Impact Municipalities",
    "hcli": "High Cost Low Impact Municipalities",
    "hchi": "High Cost High Impact Municipalities",
    "universe": "All"
}

label_scenario = {
    "bau": "a Business as Usual",
    "fish-catch": "a Fish Catch Sustainability",
    "fisher-revenue": "a Fisher Net Revenue Maximized",
    "both": "Both"
}

label_criteria = {
    "baseline": "with Equal Weights",
    "accessibility": "Prioritizing Fund Accessibility",
    "adoption": "Prioritizing Fund Adoption",
    "sustainability": "Prioritizing Fund Sustainability",
    "sufficiency": "Prioritizing Fund Sufficiency"
}

title = 'RPG Simulation Results for '
title = title + label_lgu[lgu] + ' in<br>' + label_scenario[scenario]
title = title + ' Scenario '+ label_criteria[criterion] +' (100 replicates)'

filename = 'rpg_' + criterion + '_graphs/' + lgu + '-' + scenario + '.html'
if not os.path.exists('rpg_' + criterion + '_graphs/images'):
    os.mkdir('rpg_' + criterion + '_graphs/images')
image_name = 'rpg_' + criterion + '_graphs/images/' + lgu + '-' + scenario + '.png'

#Create graph
data = [trace_pf, trace_nf, trace_g, trace_cw, trace_ps, trace_lb]
layout = dict(
    title = title,
    yaxis = dict(title = "Average Score (across replicates)"),
    xaxis = dict(title = "Run Number")
)
fig = go.Figure(data = data, layout = layout)

plotly.offline.plot({
        "data": data,
        "layout": layout
    }, filename=filename, auto_open=False)
pio.write_image(fig, image_name)