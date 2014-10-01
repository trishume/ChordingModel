# Results

Pure Velotype system without layout: 3.2 characters per stroke = 1.49 strokes per word
Velotype system no double characters: 3.15 characters per stroke = 1.52 strokes per word
Velotype system with layout collisions: 2.98 characters per stroke = 1.622 strokes per word
Velotype with extra suffixes no layout (er|ed|en|e|ion|able|ing|al): 3.46 characters per stroke = 1.38 strokes per word
Stenotype with briefs and shortest dictionary entries: 3.74 characters per stroke = 1.14 strokes per word
Stenotype no briefs and longest dictionary entries: 3.0 characters per stroke = 1.60 strokes per word
Velotype with autocomplete based on the first strokes (no layout): 4.26 characters per stroke = 1.18 strokes per word

# Layout

## Wanted letter keys
Frequent: t, n, s, r, h, d, l, c
Few pairs: y, p (t,n,r,h,s,l)
Useful for chords: j

Triangle ideas: ftv, dmw

>> jkr
6.81
>> cpt
13.629999999999999
>> fsz
8.65
>> lny
13.04
sum: 41

>> mtw
13.799999999999999
>> dfv
7.73
>> dmv
8.04
>> ftw
13.489999999999998
>> ftv
12.509999999999998
>> dmw
9.02

>> bnp
10.26
>> hlq
10.01
>> jls
10.36
>> bhn
14.36
>> jlr
10.1
>> bgs
9.8
>> cgs
11.02
>> hln
16.85
>> bcs
10.48
>> gsy
10.42

## Attempt 2
Try pair with high frequency, then a low frequency pair for doubles.

["lmn", "dft", 29.259999999999998, 13.54, 15.719999999999999]
["svw", "grx", 0.009580517791156798, 17.7, 9.48, 8.219999999999999]
sum: 47

["nrx", "dmt", 29.17, 13.139999999999999, 16.03]

Trying high freq, then pairs that don't conflict with leftovers
["lmn", "dft", 29.259999999999998, 13.54, 15.719999999999999]
["jqv", "bsw", 0.03475060148039001, 11.18, 1.32, 9.86]
sum: 40

## Candidates
- jkr, cpt, fsz, lny = 41 (tnsr__l)
- ftv, dmw, bnp, hlq = 42 (tn__hdl)
- ftv, dmw, jls, bhn = 46 (t_s_hdl)
- ftv, dmw, jlr, bgs = 41 (t_sr_dl)

gen2 [Best 2 pairs, then best chord pair]
- dft, lmn, svw, grx = 47 (tnsr_dl) [Hbcjkpqyz]
- dft, lmn, bsw, jqv = 40 (tns__dl) [Hcgkprxyz]
