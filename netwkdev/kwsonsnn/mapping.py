# Once again, reused from
# https://github.com/Thonner/bindsnet/blob/master/examples/mnist/BNSupervised_mnist_map_gen.py

from .model import ShowCaseNet
from .utils import get_default_net

import torch
import json

def getDecayShift(modelDecay: float) -> int:
    """
    Convert float model decay to estimated decay shift for accelerator.

    :param modelDecay: a floating-point decay factor

    :return: an integer shift estimating the decay factor ``modelDecay``
    """
    for i in range(1,8):
        if (1 - modelDecay > 0.5):
            return 1
        
        if (1 - modelDecay < 1/(2**i) and 1 - modelDecay > 1/(2**(i+1))):
            if ((1 - modelDecay) - (1/(2**(i+1))) > (1/(2**i) - (1/(2**(i+1))))/2 ):
                return i
            else:
                return i+1
    return 0

def map2Acc(
    path: str = '../pretrained/network.pt'
) -> None:
    """
    Map a pretrained network to the neuromorphic accelerator.

    :param path: a path to a pretrained network model represented as a string.
    """
    network = get_default_net()
    network.load_state_dict(torch.load(path))
    network.learning = False
    network.Ae.learning = False
    network.Ae_to_Ai.training = False
    network.Ai.learning = False
    network.Ai_to_Ae.training = False
    network.X.learning = False
    network.X_to_Ae.training = False
    AeThresh = [network.Ae.thresh.item()] * network.Ae.n
    Aetheta  = network.Ae.theta.tolist()
    for i in range(network.Ae.n):
        AeThresh[i] = AeThresh[i] + Aetheta[i]
    AeBiases1 = network.X_to_Ae.b.data.tolist()
    AeBiases2 = network.Ai_to_Ae.b.data.tolist()
    for i in range(network.Ae.n):
        AeBiases1[i] = AeBiases1[i] + AeBiases2[i]
    AeDecay =  getDecayShift(network.Ae.decay.item())
    AiDecay = getDecayShift(network.Ai.decay.item())

    networkData = {}
    networkData['l1'] = []
    networkData['l1'].append({
        'reset'  : [round(network.Ae.reset.item())] * network.Ae.n,
        'thresh' : [round(numb) for numb in AeThresh],
        'refrac' : [network.Ae.refrac.item()] * network.Ae.n,
        'decay'  : [AeDecay] * network.Ae.n,
        'biases' : [round(numb) for numb in AeBiases1],
        'w1size' : list(network.X_to_Ae.w.data.size()),
        'w1'     : [([round(numb) for numb in numb2]) for numb2 in network.X_to_Ae.w.data.tolist()],
        'w2size' : list(network.Ai_to_Ae.w.data.size()),
        'w2'     : [([round(numb) for numb in numb2]) for numb2 in network.Ai_to_Ae.w.data.tolist()],
    })

    networkData['l2'] = []
    networkData['l2'].append({
        'reset'  : [round(network.Ai.reset.item())] * network.Ai.n,
        'thresh' : [round(network.Ai.thresh.item())] * network.Ai.n,
        'decay'  : [AiDecay] * network.Ae.n,
        'refrac' : [network.Ae.refrac.item()] * network.Ae.n,
        'biases' : [round(numb) for numb in  network.Ae_to_Ai.b.data.tolist()],
        'wsize'  : list(network.Ae_to_Ai.w.data.size()),
        'w'      : [([round(numb) for numb in numb2]) for numb2 in network.Ae_to_Ai.w.data.tolist()],
    })

    with open('examples/mnist/mapping/networkData.json', 'w') as jsonfile:
        json.dump(networkData, jsonfile)
