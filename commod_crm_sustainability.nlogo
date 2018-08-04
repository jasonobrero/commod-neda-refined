;Definition of agents
breed [blgu-players blgu-player]
breed [mplgu-players mplgu-player]
breed [bd-players bd-player]
breed [academe-players academe-player]
breed [business-players business-player]
breed [nga-players nga-player]

;Definition of global variables
globals [
  ;Stores the responses for each financing scheme
  public-funds local-bonds national-funds credit-windows grants private-sector

  ;Stores the responses per criteria for each financing scheme
  sustainability-pf accessibility-pf sufficiency-pf adoption-pf
  sustainability-lb accessibility-lb sufficiency-lb adoption-lb
  sustainability-nf accessibility-nf sufficiency-nf adoption-nf
  sustainability-cw accessibility-cw sufficiency-cw adoption-cw
  sustainability-g accessibility-g sufficiency-g adoption-g
  sustainability-ps accessibility-ps sufficiency-ps adoption-ps

  lcli lchi hcli hchi type1 type2 type3 type4

  totals summ
]

;At a particular time, the players have a weighted total of the responses for each criteria
;and a ranking which is an ordered list of financing schemes, sorted by weighted total
blgu-players-own     [ pf lb nf cw g ps ranking]
mplgu-players-own    [ pf lb nf cw g ps ranking]
bd-players-own       [ pf lb nf cw g ps ranking]
academe-players-own  [ pf lb nf cw g ps ranking]
business-players-own [ pf lb nf cw g ps ranking]
nga-players-own      [ pf lb nf cw g ps ranking]

;Reports total amoount of weight
to-report total
  report sustainability-w + accessibility-w + sufficiency-w + adoption-w
end

;Reports number of agents in the simulation
to-report total-players
  report blgu + mplgu + bd + academe + business + nga
end

;Creates the players with the assigned color.
;Proportional to the number of players present to the LGU
to spawn-agent [player shade]
  ;Get proportion of player from input
  let proportion round ((runresult player / total-players) * 100)
  ;Build string which creates agents
  let agent (word "create-" player "-players " proportion
    "[setxy random-xcor random-ycor set color " shade " ]")
  run agent
end

;Distributes the data set to the pool of responses
to distribute [financing-scheme]
  let suffix ""
  let response 0

  ;Set suffix to be used for the particular financing scheme
  if financing-scheme = "public-funds" [set suffix "pf"]
  if financing-scheme = "local-bonds" [set suffix "lb"]
  if financing-scheme = "national-funds" [set suffix "nf"]
  if financing-scheme = "credit-windows" [set suffix "cw"]
  if financing-scheme = "grants" [set suffix "g"]
  if financing-scheme = "private-sector" [set suffix "ps"]

  ;Add appropriate suffix for the financing scheme of choice
  let criteria ["accessibility-" "adoption-" "sufficiency-" "sustainability-"]
  set criteria map [criterion -> (word criterion suffix)] criteria

  ;Get list of responses for each financing scheme
  let schemes runresult financing-scheme

  foreach schemes
  [
    ;Set the individual response
    scheme -> set response scheme
    foreach criteria
    [
      ;Get the digit [1-5] which corresponds to the criteria
      criterion -> run (word "set " criterion " lput (floor " response " mod 10)" criterion)
      set response floor response / 10
    ]
  ]
end

;Set ups the whole simulation
to spawn
  ;Reset every list and individual variables
  clear-all
  reset-ticks

  set lcli ["masinloc" "nasugbu" "dinapigue" "anini-y" "macarthur" "pagsanghan"]
  set lchi ["claveria" "baliguian" "socorro" "bien-unido" "carles"]
  set hcli ["magsingal" "gasan" "jose-panganiban" "mansalay" "maasim" "toboso"]
  set hchi ["jomalig" "quezon" "dipolog" "rtlim" "arteche" "daanbantayan" "mercedes"]

  set public-funds []
  set local-bonds []
  set national-funds []
  set credit-windows []
  set grants []
  set private-sector []

  set sustainability-pf []
  set accessibility-pf []
  set sufficiency-pf []
  set adoption-pf []

  set sustainability-lb []
  set accessibility-lb []
  set sufficiency-lb []
  set adoption-lb []

  set sustainability-nf []
  set accessibility-nf []
  set sufficiency-nf []
  set adoption-nf []

  set sustainability-cw []
  set accessibility-cw []
  set sufficiency-cw []
  set adoption-cw []

  set sustainability-g []
  set accessibility-g []
  set sufficiency-g []
  set adoption-g []

  set sustainability-ps []
  set accessibility-ps []
  set sufficiency-ps []
  set adoption-ps []

  ;Check if total of the weights is 100
  if total != 100
  [error "Total of weights should be exactly 100."]

  if total-players = 0
  [error "There are no players."]

  ;user-message "Population file has been found. Entering data set."

  ;Spawn agents
  let agents ["blgu" "mplgu" "academe" "bd" "business" "nga"]
  let colors [blue green yellow red white magenta]
  (foreach agents colors [
    [agent shade] -> spawn-agent agent shade
  ])

  ;Check if the data set is found in the directory
  let population-list []
  set population-list fput population population-list
  if population = "lcli" [set population-list lcli]
  if population = "lchi" [set population-list lchi]
  if population = "hcli" [set population-list hcli]
  if population = "hchi" [set population-list hchi]

  let filename ""
  set-current-directory "responses"
  foreach population-list
  [
    town -> set filename (word town "-" scenario)
    if-else not file-exists? filename
    [error (word "Data set file named " filename " not found.") ]
    [
      ;Get data from file
      file-open filename

      ;Ordering is based on the conduct of the RPG
      while [not file-at-end?] [
        set public-funds lput file-read public-funds
        set local-bonds lput file-read local-bonds
        set national-funds lput file-read national-funds
        set credit-windows lput file-read credit-windows
        set grants lput file-read grants
        set private-sector lput file-read private-sector
      ]

      file-close

      ;user-message (word "Data set file named " filename " is loaded.")
    ]
  ]

  ;Distribute the responses to the financing schemes
  let financing-schemes ["public-funds" "local-bonds" "national-funds" "credit-windows" "grants" "private-sector"]
  foreach financing-schemes [
   financing-scheme -> distribute financing-scheme
  ]
  ;user-message "Data set is distributed."

  set-current-directory ".."
end

;Procedure for an agent to rank the financing schemes
to rank [agent]
  ask turtle agent[
    set ranking []
    let top 0
    set ranking fput list "pf" pf ranking
    set ranking fput list "lb" lb ranking
    set ranking fput list "nf" nf ranking
    set ranking fput list "cw" cw ranking
    set ranking fput list "g" g ranking
    set ranking fput list "ps" ps ranking

    ;Sort ranking from lowest to highest
    ;Highest ranked scheme is indicated in the last elements of the list
    set ranking sort-by [ [a b] -> last a < last b ] ranking

    ;Display the top-ranking scheme in the agents
    set top last ranking
    set label first top
  ]
end

;Allows each agent to score a financing scheme
to score-scheme [financing-scheme agent]
  let suffix ""
  let prefix ""
  let curr ""
  let w ""
  let wgt ""
  let value 0

  ;Set prefixes
  if financing-scheme = "public-funds" [set suffix "pf"]
  if financing-scheme = "local-bonds" [set suffix "lb"]
  if financing-scheme = "national-funds" [set suffix "nf"]
  if financing-scheme = "credit-windows" [set suffix "cw"]
  if financing-scheme = "grants" [set suffix "g"]
  if financing-scheme = "private-sector" [set suffix "ps"]

  ;Rank scheme for each criteria
  let criteria ["sustainability-" "accessibility-" "sufficiency-" "adoption-"]
  foreach criteria
  [
    criterion -> set prefix criterion
    set w (word prefix suffix)
    set wgt (word prefix "w")
    set value (value + ((one-of runresult w) * runresult wgt))
  ]

  ask turtle agent[
    run (word "set " suffix " " value)
  ]

end

to-report get-total-rank [agentset]
  let suffix ""
  let current ""
  set totals []
  set summ 0

  ;Set prefixes
  let financing-schemes ["public-funds" "local-bonds" "national-funds" "credit-windows" "grants" "private-sector"]
  foreach financing-schemes
  [
    financing-scheme -> set current financing-scheme
    if current = "public-funds" [set suffix "pf"]
    if current = "local-bonds" [set suffix "lb"]
    if current = "national-funds" [set suffix "nf"]
    if current = "credit-windows" [set suffix "cw"]
    if current = "grants" [set suffix "g"]
    if current = "private-sector" [set suffix "ps"]

    run (word "set summ sum [" suffix "] of " agentset)
    run (word "set totals fput list \"" suffix "\" " summ " totals")
  ]

  ;set totals sort-by [ [a b] -> last a < last b ] totals
  report totals
end

;This ranks a scheme for a particular year
to go
  let current ""

  ;Score schemes for each financing scheme
  let financing-schemes ["public-funds" "local-bonds" "national-funds" "credit-windows" "grants" "private-sector"]
  foreach financing-schemes
  [
    financing-scheme -> set current financing-scheme
    ask blgu-players[ score-scheme current who ]
    ask mplgu-players[ score-scheme current who]
    ask bd-players[ score-scheme current who ]
    ask academe-players[ score-scheme current who ]
    ask business-players[ score-scheme current who ]
    ask nga-players[ score-scheme current who ]
  ]

  ;Rank all of the financing schemes
  ask blgu-players[ rank who ]
  ask mplgu-players[ rank who ]
  ask bd-players[ rank who ]
  ask academe-players[ rank who ]
  ask business-players[ rank who ]
  ask nga-players[ rank who ]

  let players ["blgu-players" "mplgu-players" "bd-players" "academe-players" "business-players" "nga-players" "turtles"]
  let ranks []
  foreach players
  [
    player -> set ranks get-total-rank player
  ]

  clear-all-plots
  tick
end

to go-25

end
@#$#@#$#@
GRAPHICS-WINDOW
416
10
853
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

INPUTBOX
232
46
321
106
sustainability-w
25.0
1
0
Number

INPUTBOX
1
46
80
106
accessibility-w
25.0
1
0
Number

INPUTBOX
83
46
151
106
adoption-w
25.0
1
0
Number

INPUTBOX
154
46
229
106
sufficiency-w
25.0
1
0
Number

TEXTBOX
4
10
367
39
Set the specific values of the weights of the specific criteria here. The total should add up to 100.
12
0.0
1

INPUTBOX
3
154
53
214
blgu
7.0
1
0
Number

INPUTBOX
56
154
106
214
mplgu
10.0
1
0
Number

INPUTBOX
107
154
157
214
bd
5.0
1
0
Number

INPUTBOX
158
154
221
214
academe
0.0
1
0
Number

INPUTBOX
223
154
286
214
business
0.0
1
0
Number

INPUTBOX
289
154
339
214
nga
0.0
1
0
Number

MONITOR
339
55
389
100
total
sustainability-w + accessibility-w + adoption-w + sufficiency-w
1
1
11

MONITOR
342
155
404
200
players
total-players
0
1
11

BUTTON
4
252
82
285
spawn
spawn
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

TEXTBOX
5
116
385
147
Set the number of players that the game would have here. Consequently, the cumulative frequency will be computed.
12
0.0
1

MONITOR
84
252
142
297
agents
count turtles
0
1
11

CHOOSER
150
253
290
298
population
population
"magsingal" "dinapigue" "masinloc" "nasugbu" "jomalig" "quezon" "gasan" "mansalay" "jose-panganiban" "mercedes" "claveria" "anini-y" "carles" "toboso" "daanbantayan" "bien-unido" "pagsanghan" "arteche" "macarthur" "baliguian" "dipolog" "rtlim" "maasim" "socorro" "lchi" "lcli" "hchi" "hcli" "blgf-type1" "blgf-type2" "blgf-type3" "blgf-type4"
0

CHOOSER
292
253
403
298
scenario
scenario
"bau" "fish-catch" "fisher-revenue" "both"
2

BUTTON
4
288
81
321
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
5
457
398
736
rankings
financing-scheme
sum of ranks
1.0
6.0
0.0
10.0
true
true
"" ""
PENS
"blgu-players" 1.0 0 -13345367 true "" "plotxy 1 sum [pf] of blgu-players\nplotxy 2 sum [lb] of blgu-players\nplotxy 3 sum [nf] of blgu-players\nplotxy 4 sum [cw] of blgu-players\nplotxy 5 sum [g] of blgu-players\nplotxy 6 sum [ps] of blgu-players"
"mplgu-players" 1.0 0 -7500403 true "" "plotxy 1 sum [pf] of mplgu-players\nplotxy 2 sum [lb] of mplgu-players\nplotxy 3 sum [nf] of mplgu-players\nplotxy 4 sum [cw] of mplgu-players\nplotxy 5 sum [g] of mplgu-players\nplotxy 6 sum [ps] of mplgu-players"
"bd-players" 1.0 0 -2674135 true "" "plotxy 1 sum [pf] of bd-players\nplotxy 2 sum [lb] of bd-players\nplotxy 3 sum [nf] of bd-players\nplotxy 4 sum [cw] of bd-players\nplotxy 5 sum [g] of bd-players\nplotxy 6 sum [ps] of bd-players"
"academe-players" 1.0 0 -955883 true "" "plotxy 1 sum [pf] of academe-players\nplotxy 2 sum [lb] of academe-players\nplotxy 3 sum [nf] of academe-players\nplotxy 4 sum [cw] of academe-players\nplotxy 5 sum [g] of academe-players\nplotxy 6 sum [ps] of academe-players"
"business-players" 1.0 0 -6459832 true "" "plotxy 1 sum [pf] of business-players\nplotxy 2 sum [lb] of business-players\nplotxy 3 sum [nf] of business-players\nplotxy 4 sum [cw] of business-players\nplotxy 5 sum [g] of business-players\nplotxy 6 sum [ps] of business-players"
"nga-players" 1.0 0 -1184463 true "" "plotxy 1 sum [pf] of nga-players\nplotxy 2 sum [lb] of nga-players\nplotxy 3 sum [nf] of nga-players\nplotxy 4 sum [cw] of nga-players\nplotxy 5 sum [g] of nga-players\nplotxy 6 sum [ps] of nga-players"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="anini-y-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;anini-y&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="anini-y-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;anini-y&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="anini-y-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;anini-y&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="anini-y-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;anini-y&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="carles-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;carles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="carles-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;carles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="carles-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;carles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="carles-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;carles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="jose-panganiban-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;jose-panganiban&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="jose-panganiban-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;jose-panganiban&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="jose-panganiban-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;jose-panganiban&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="jose-panganiban-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;jose-panganiban&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="maasim-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;maasim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="maasim-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;maasim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="maasim-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;maasim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="maasim-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;maasim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mercedes-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;mercedes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mercedes-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;mercedes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mercedes-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;mercedes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mercedes-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;mercedes&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="socorro-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;socorro&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="socorro-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;socorro&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="socorro-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;socorro&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="socorro-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;socorro&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="magsingal-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;magsingal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="magsingal-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;magsingal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="magsingal-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;magsingal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="magsingal-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;magsingal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="masinloc-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;masinloc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="masinloc-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;masinloc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="masinloc-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;masinloc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="masinloc-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;masinloc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="pagsanghan-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;pagsanghan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="pagsanghan-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;pagsanghan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="pagsanghan-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;pagsanghan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="pagsanghan-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;pagsanghan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="arteche-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;arteche&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="arteche-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;arteche&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="arteche-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;arteche&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="arteche-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;arteche&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="macarthur-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;macarthur&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="macarthur-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;macarthur&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="macarthur-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;macarthur&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="macarthur-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;macarthur&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="dipolog-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;dipolog&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="dipolog-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;dipolog&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="dipolog-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;dipolog&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="dipolog-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;dipolog&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="rtlim-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;rtlim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="rtlim-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;rtlim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="rtlim-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;rtlim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="rtlim-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;rtlim&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baliguian-bau" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;bau&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;baliguian&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baliguian-fish-catch" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fish-catch&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;baliguian&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baliguian-fisher-revenue" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;fisher-revenue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;baliguian&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baliguian-both" repetitions="100" runMetricsEveryStep="true">
    <setup>spawn</setup>
    <go>go</go>
    <exitCondition>ticks = 10</exitCondition>
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
      <value value="&quot;both&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="&quot;baliguian&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blgu">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mplgu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bd">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="academe">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nga">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sufficiency-w">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="accessibility-w">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adoption-w">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sustainability-w">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
