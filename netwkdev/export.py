# Inspired by https://github.com/Thonner/bindsnet/blob/master/examples/mnist/BNSupervised_mnist_map_gen.py
from kwsonsnn.model import ShowCaseNet

import argparse
import numpy as np
import torch
import json

###############################################################################
# Argument parsing                                                            #
###############################################################################
parser = argparse.ArgumentParser()
parser.add_argument("nwkfile")
parser.add_argument("--scale", type=float, default=1000.0)
args = parser.parse_args()

nwkfile = args.nwkfile.lower()
scale = args.scale

assert '.pt' in nwkfile, 'Input file should end in `.pt`'
tgtfile = nwkfile[:-3] + '.json'

###############################################################################
# Fetch network and export to JSON                                            #
###############################################################################
def getDecayShift(modelDecay):
    if modelDecay < 0.5:
        return 1
    for i in range(2,8):
        if modelDecay > 1 - 2**(-i) and modelDecay < 1 - 2**(-(i+1)):
            if modelDecay < 1 - (2**(-(i)) - 2**(-(i+2))):
                return i
            else:
                return i+1
            break

network = ShowCaseNet(n_inpt=22*22, inpt_shape=(1, 22, 22))
try:
    nwk = torch.load(nwkfile, map_location=torch.device('cpu'))
    if 'X_to_Ae.b' not in nwk:
        network.X_to_Ae.b  = None
    if 'Ae_to_Ai.b' not in nwk:
        network.Ae_to_Ai.b = None
    if 'Ai_to_Ae.b' not in nwk:
        network.Ai_to_Ae.b = None
    network.load_state_dict(nwk)
except:
    print(f"The given file ({nwkfile}) is not a Pickle'd ShowCaseNet")
    exit(1)

data = {}

# Deactivate training of layers
network.learning = False
network.X.learning = False
network.X_to_Ae.training = False
network.Ae.learning = False
network.Ae_to_Ai.training = False
network.Ai.learning = False
network.Ai_to_Ae.training = False

# Read out values
nAe = network.Ae.n
threshAe = (
    torch.tensor(np.tile(network.Ae.thresh * scale, nAe)) + 
    network.Ae.theta * scale
)
bAe1 = network.X_to_Ae.b
bAe2 = network.Ai_to_Ae.b
biasesAe = (
    (bAe1 if bAe1 is not None else torch.zeros(nAe)) + 
    (bAe2 if bAe2 is not None else torch.zeros(nAe))
) * scale
w1Ae = network.X_to_Ae.w.data * scale
w2Ae = network.Ai_to_Ae.w.data * scale

nAi = network.Ai.n
threshAi = torch.tensor(np.tile(network.Ai.thresh * scale, nAi))
bAi = network.Ae_to_Ai.b
biasesAi = bAi if bAi is not None else torch.zeros(nAi)
wAi = network.Ae_to_Ai.w.data * scale

# Write all values to a JSON file
data = {}
data['l1'] = []
data['l1'].append({
    'reset'  : [round(network.Ae.reset.item())],
    'refrac' : [round(network.Ae.refrac.item())],
    'decay'  : [getDecayShift(network.Ae.decay.item())],
    'biases' : [round(b) for b in biasesAe.tolist()],
    'thresh' : [round(t) for t in threshAe.tolist()],
    'w1'     : [([round(c) for c in r]) for r in w1Ae.tolist()],
    'w2'     : [([round(c) for c in r]) for r in w2Ae.tolist()]
})

data['l2'] = []
data['l2'].append({
    'reset'  : [round(network.Ai.reset.item())],
    'refrac' : [round(network.Ai.refrac.item())],
    'decay'  : [getDecayShift(network.Ai.decay.item())],
    'biases' : [round(b) for b in biasesAi.tolist()],
    'thresh' : [round(t) for t in threshAi.tolist()],
    'w'      : [([round(c) for c in r]) for r in wAi.tolist()]
})

with open(tgtfile, 'w') as f:
    json.dump(data, f)
