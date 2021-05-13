import argparse
import json

###############################################################################
# Argument parsing                                                            #
###############################################################################
parser = argparse.ArgumentParser()
parser.add_argument("nwkfile")
parser.add_argument("--scale", type=float, default=1000.0)
args = parser.parse_args()

nwkfile = args.nwkfile
scale = args.scale

assert '.json' in nwkfile, 'Input file should end in `.json`'
tgtfile = nwkfile[:-5] + '_fp.json'

###############################################################################
# Fetch data                                                                  #
###############################################################################
with open(nwkfile, 'r') as f:
    data = json.load(f)

###############################################################################
# Re-export data                                                              #
###############################################################################
l1_conv, l1_wconv = (['thresh', 'biases'], ['w1', 'w2'])
l2_conv, l2_wconv = (['thresh', 'biases'], ['w'])

for l in l1_conv:
    data['l1'][0][l] = list(map(lambda x: x / scale, data['l1'][0][l]))

for l in l1_wconv:
    data['l1'][0][l] = list(map(lambda wl: list(map(lambda w: w / scale, wl)), data['l1'][0][l]))

for l in l2_conv:
    data['l2'][0][l] = list(map(lambda x: x / scale, data['l2'][0][l]))

for l in l2_wconv:
    data['l2'][0][l] = list(map(lambda wl: list(map(lambda w: w / scale, wl)), data['l2'][0][l]))

with open(tgtfile, 'w') as f:
    json.dump(data, f)

