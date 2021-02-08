# Again, reused from
# https://github.com/Thonner/bindsnet/blob/master/examples/mnist/supervised_mnist.py

from .model import ShowCaseNet
from .dataset import SpeechCommandsDataset
from .encode import RateEncoder
from .utils import get_default_net, download

import argparse
import numpy as np
import torch
import matplotlib.pyplot as plt
from tqdm import tqdm
from bindsnet.network.monitors import Monitor
from bindsnet.utils import get_square_assignments, get_square_weights
from bindsnet.evaluation import all_activity, proportion_weighting, assign_labels
from bindsnet.encoding import NullEncoder
from bindsnet.analysis.plotting import (
    plot_input,
    plot_assignments,
    plot_performance,
    plot_weights,
    plot_spikes,
    plot_voltages,
)

# Argument parsing
print('Initializing parser')
parser = argparse.ArgumentParser()
parser.add_argument("--seed", type=int, default=2)
parser.add_argument("--epochs", type=int, default=10)
parser.add_argument("--n_neurons", type=int, default=200)
parser.add_argument("--n_clamp", type=int, default=1)
parser.add_argument("--exc", type=float, default=22.5)
parser.add_argument("--inh", type=float, default=22.5)
parser.add_argument("--time", type=int, default=500)
parser.add_argument("--dt", type=int, default=1.0)
parser.add_argument("--update_interval", type=int, default=250)
parser.add_argument("--plot", dest="plot", action="store_true")
parser.add_argument("--gpu", dest="gpu", action="store_true")
parser.add_argument("--device_id", type=int, default=0)
parser.set_defaults(plot=False, gpu=False)

args = parser.parse_args()

seed = args.seed
epochs = args.epochs
n_neurons = args.n_neurons
n_clamp = args.n_clamp
exc = args.exc
inh = args.inh
time = args.time
dt = args.dt
update_interval = args.update_interval
plot = args.plot
gpu = args.gpu
device_id = args.device_id

# Network and GPU-related setup
print('Setting up network')
network = get_default_net()
print(network)

if gpu and torch.cuda.is_available():
    #torch.set_default_tensor_type("torch.cuda.FloatTensor")
    torch.cuda.set_device(device_id)
    torch.cuda.manual_seed_all(seed)
    network.to("cuda")
else:
    torch.manual_seed(seed)

n_sqrt = int(np.ceil(np.sqrt(n_neurons)))
per_class = int(n_neurons / 10)

# Voltage recording for excitatory and inhibitory layers.
print('Setting up monitors')
exc_voltage_monitor = Monitor(network.layers["Ae"], ["v"], time=time)
inh_voltage_monitor = Monitor(network.layers["Ai"], ["v"], time=time)
network.add_monitor(exc_voltage_monitor, name="exc_voltage")
network.add_monitor(inh_voltage_monitor, name="inh_voltage")

# Get the dataset
print('Fetching the dataset')
download('../data')
dataset = SpeechCommandsDataset('../data')
dataset.process_data()
# TODO: Replace this with more efficient alternative!
audio_enc = RateEncoder(time=time, dt=dt)
label_enc = NullEncoder()
# Wrap in a dataloader
dataloader = torch.utils.data.DataLoader(dataset, batch_size=1)

# Recording stuff throughout the training
spike_record = torch.zeros(update_interval, time, n_neurons)
assignments = -torch.ones_like(torch.Tensor(n_neurons))
proportions = torch.zeros_like(torch.Tensor(n_neurons, 10))
rates = torch.zeros_like(torch.Tensor(n_neurons, 10))
accuracy = {"all": [], "proportion": []}
labels = torch.empty(update_interval)
spikes = {}
for layer in set(network.layers):
    spikes[layer] = Monitor(network.layers[layer], state_vars=["s"], time=time)
    network.add_monitor(spikes[layer], name=f"{layer}_spikes")

# Training loop
print("Begin training.")
inpt_axes = None
inpt_ims = None
spike_axes = None
spike_ims = None
weights_im = None
assigns_im = None
perf_ax = None
voltage_axes = None
voltage_ims = None

try:
    epochbar = tqdm(range(epochs))
    for _ in epochbar:
        pbar = tqdm(enumerate(dataloader))
        for (i, datum) in pbar:
            image = audio_enc(datum['audio'])
            label = label_enc(datum['label'])

            if i % update_interval == 0 and i > 0:
                input_exc_weights = network.connections[("X", "Ae")].w
                w_arg = 0.0
                for i in range (22*22):
                   for j in range(n_neurons):
                       w_arg += input_exc_weights[i, j]
                print(w_arg /((22*22)*n_neurons))
                # Get network predictions.
                all_activity_pred = all_activity(spike_record, assignments, 10)
                proportion_pred = proportion_weighting(
                    spike_record, assignments, proportions, 10
                )

                # Compute network accuracy according to available classification strategies.
                accuracy["all"].append(
                    100 * torch.sum(labels.long() == all_activity_pred).item() / update_interval
                )
                accuracy["proportion"].append(
                    100 * torch.sum(labels.long() == proportion_pred).item() / update_interval
                )

                print('\nAll activity accuracy: {:.2f} (last), {:.2f} (average), {:.2f} (best)'.format(
                    accuracy["all"][-1], np.mean(accuracy["all"]), np.max(accuracy["all"])
                ))

                print('Proportion weighting accuracy: {:.2f} (last), {:.2f} (average), {:.2f} (best)\n'.format(
                    accuracy["proportion"][-1], np.mean(accuracy["proportion"]), np.max(accuracy["proportion"])
                ))

                # Assign labels to excitatory layer neurons.
                assignments, proportions, rates = assign_labels(spike_record, labels, 10, rates)

            #Add the current label to the list of labels for this update_interval
            labels[i % update_interval] = label[0]

            # Run the network on the input. Clamps expected output neurons forcing them to spike.
            choice = np.random.choice(int(n_neurons / 10), size=n_clamp, replace=False)
            clamp = {"Ae": per_class * label[0].long() + torch.Tensor(choice).long()}
            inputs = {"X": image.cuda().view(time, 1, 1, 22, 22) if gpu else image.view(time, 1, 1, 22, 22)}
            network.run(inputs=inputs, time=time, clamp=clamp)

            # Get voltage recording. Fetches voltage on both excitatory and inhibitory connections.
            exc_voltages = exc_voltage_monitor.get("v")
            inh_voltages = inh_voltage_monitor.get("v")

            # Add to spikes recording. The spikes are monitored constantly.
            spike_record[i % update_interval] = spikes["Ae"].get("s").view(time, n_neurons)

            # Optionally plot various simulation information.
            if plot:
                inpt = inputs["X"].view(time, 22*22).sum(0).view(22, 22)
                input_exc_weights = network.connections[("X", "Ae")].w
                square_weights = get_square_weights(
                    input_exc_weights.view(22*22, n_neurons), n_sqrt, 22
                )
                square_assignments = get_square_assignments(assignments, n_sqrt)
                voltages = {"Ae": exc_voltages, "Ai": inh_voltages}

                inpt_axes, inpt_ims = plot_input(
                    image.sum(1).view(22, 22), inpt, label=label, axes=inpt_axes, ims=inpt_ims
                )
                spike_ims, spike_axes = plot_spikes(
                    {layer: spikes[layer].get("s").view(time, 1, -1) for layer in spikes},
                    ims=spike_ims,
                    axes=spike_axes,
                )
                weights_im = plot_weights(square_weights, im=weights_im)
                assigns_im = plot_assignments(square_assignments, im=assigns_im)
                perf_ax = plot_performance(accuracy, ax=perf_ax)
                voltage_ims, voltage_axes = plot_voltages(
                    voltages, ims=voltage_ims, axes=voltage_axes
                )

                plt.pause(1e-8)

            network.reset_state_variables()
except KeyboardInterrupt:
    print('Keyboard interrupt caught.')
except:
    print('An error occurred in the training loop.')
    exit(1)
finally:
    import os
    if not os.path.isdir('pretrained'):
        os.mkdir('pretrained')
    torch.save(network.state_dict(), 'pretrained/network.pt')
    print("Training complete.\n")
