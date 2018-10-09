#Import dependencies
import csv
import os
import sys
import plotly
import plotly.graph_objs as go

#Initialization of constants
lgus = ["magsingal", "dinapigue", "masinloc", "nasugbu", "jomalig",
            "quezon", "gasan", "mansalay", "jose-panganiban", "mercedes",
            "claveria", "anini-y", "carles", "toboso", "daanbantayan",
            "bien-unido", "pagsanghan", "arteche", "macarthur",
            "baliguian", "dipolog", "rtlim", "maasim", "socorro"]
scenarios = ["bau", "fish-catch", "fisher-revenue", "both"] 
criteria = ["baseline", "adoption", "accessibility", "sufficiency",
            "sustainability"]

#Error checking of argument count
if not len(sys.argv) == 5:
    raise ValueError('Usage: python image-builder-stakeholder.py <lgu> <scenario> <criteria> <y/n>.')

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

blgu = []
mplgu = []
bd = []
business = []
academe = []
nga = []

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

#Get the number of participants
participants = ['blgu', 'mplgu', 'bd', 'business', 'academe', 'nga']
respondents = {}
for tick in range(9, 15):
    x = lines[tick]
    x = [s.replace('\"', '') for s in x]
    respondents[participants[tick - 9]] =  int(x[1])

'''
TO-DO
Get the total per agent
'''
#There are 25 lines, for 25 ticks.
#Tick number 1 starts at line 28 (zero indexing is used)
ticks = 25
if criterion != "baseline":
    ticks = 10
for tick in range(0, ticks):
    #Get the line of the CSV
    x = lines[28 + tick]

    #Remove first column
    del x[0]

    #Remove stray new lines and quotation marks
    x = [s.replace('\"', '') for s in x]
    x = [s.replace('\n', '') for s in x]
    x = [float(s) for s in x]

    #Set up the running totals of the financing schemes for all experiments
    l = {'pf': 0, 'nf': 0, 'g': 0, 'cw': 0, 'ps': 0, 'lb': 0}

    #Get the total scores for all agents for each of the financing scheme
    for i in range(0, len(x), 7):
        blgu.append(x[i+0])
        mplgu.append(x[i+1])
        bd.append(x[i+2])
        academe.append(x[i+3])
        business.append(x[i+4])
        nga.append(x[i+5])


#Normalize scores across all agents
if(respondents["blgu"] != 0):
    blgu = [x / respondents["blgu"] for x in blgu]
if(respondents["mplgu"] != 0):
    mplgu = [x / respondents["mplgu"] for x in mplgu]
if(respondents["bd"] != 0):
    bd = [x / respondents["bd"] for x in bd]
if(respondents["academe"] != 0):
    academe = [x / respondents["academe"] for x in academe]
if(respondents["business"] != 0):
    business = [x / respondents["business"] for x in business]
if(respondents["nga"] != 0):
    nga = [x / respondents["nga"] for x in nga]

#Get all scores for each financing scheme
pf = [blgu[0::6], mplgu[0::6], bd[0::6], academe[0::6], business[0::6], nga[0::6]]
nf = [blgu[1::6], mplgu[1::6], bd[1::6], academe[1::6], business[1::6], nga[1::6]]
g = [blgu[2::6], mplgu[2::6], bd[2::6], academe[2::6], business[2::6], nga[2::6]]
cw = [blgu[3::6], mplgu[3::6], bd[3::6], academe[3::6], business[3::6], nga[3::6]]
ps = [blgu[4::6], mplgu[4::6], bd[4::6], academe[4::6], business[4::6], nga[4::6]]
lb = [blgu[5::6], mplgu[5::6], bd[5::6], academe[5::6], business[5::6], nga[5::6]]

#Get the average of all of the simulation runs
pf = [round(sum(x) / float(len(x)), 2) for x in pf]
nf = [round(sum(x) / float(len(x)), 2) for x in nf]
g = [round(sum(x) / float(len(x)), 2) for x in g]
cw = [round(sum(x) / float(len(x)), 2) for x in cw]
ps = [round(sum(x) / float(len(x)), 2) for x in ps]
lb = [round(sum(x) / float(len(x)), 2) for x in lb]

agents = ["Barangay LGU", "Municipal and Provincial LGU", "Bantay Dagat", "Academe", "Business Sector", "Non-Government Agencies"]

#Create traces
trace_pf = go.Bar(
    x = agents,
    y = pf,
    name = 'Public Funds'
)

trace_nf = go.Bar(
    x = agents,
    y = nf,
    name = 'National Funds'
)

trace_g = go.Bar(
    x = agents,
    y = g,
    name = 'Grants'
)

trace_cw = go.Bar(
    x = agents,
    y = cw,
    name = 'Credit Windows'
)

trace_ps = go.Bar(
    x = agents,
    y = ps,
    name = 'Private Sector'
)

trace_lb = go.Bar(
    x = agents,
    y = lb,
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
    "socorro": "Socorro, Surigao del Norte"
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

title = 'RPG Simulation Per Agent Results for '
title = title + label_lgu[lgu] + ' in<br>' + label_scenario[scenario]
title = title + ' Scenario '+ label_criteria[criterion] +' (100 replicates)'

filename = "rpg_agents_graphs/" + lgu + '-' + scenario + '-' + criterion +'-agent.html'

#Create graph
data = [trace_pf, trace_nf, trace_g, trace_cw, trace_ps, trace_lb]
layout = dict(
    title = title,
    yaxis = dict(title = "Average Score (all replicates)"),
    xaxis = dict(title = "Financing Scheme")
)

if str.upper(download) == 'Y':
    plotly.offline.plot({
        "data": data,
        "layout": layout
    }, image='png', filename=filename)
else:
    plotly.offline.plot({
        "data": data,
        "layout": layout
    }, filename=filename)