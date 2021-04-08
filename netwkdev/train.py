from kwsonsnn.model import ShowCaseNet
from kwsonsnn.dataset import SpeechCommandsDataset
from kwsonsnn.encode import RateEncoder

import argparse
import numpy as np
from pandas import DataFrame
import torch
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt
from tqdm import tqdm
from bindsnet.network.monitors import Monitor
from bindsnet.evaluation import (
    all_activity, proportion_weighting, assign_labels
)
from bindsnet.encoding import NullEncoder

###############################################################################
# Argument parsing                                                            #
###############################################################################
print('Initializing parser')
parser = argparse.ArgumentParser()
parser.add_argument('--use_mnist', dest='use_mnist', action='store_true')
parser.add_argument('--seed', type=int, default=2)
parser.add_argument('--epochs', type=int, default=5)
parser.add_argument('--n_clamp', type=int, default=1)
parser.add_argument('--n_train', type=int, default=-1)
parser.add_argument('--n_valid', type=int, default=-1)
parser.add_argument('--exc', type=float, default=22.5)
parser.add_argument('--inh', type=float, default=17.5)
parser.add_argument('--time', type=int, default=500)
parser.add_argument('--dt', type=int, default=1.0)
parser.add_argument('--intensity', type=float, default=128.0)
parser.add_argument('--update_interval', type=int, default=250)
parser.add_argument('--gpu', dest='gpu', action='store_true')
parser.add_argument('--plot', dest='plot', action='store_true')
parser.add_argument('--plot_interval', type=int, default=250)
parser.set_defaults(use_mnist=False, gpu=False, plot=False)

args = parser.parse_args()

use_mnist = args.use_mnist
seed = args.seed
epochs = args.epochs
n_clamp = args.n_clamp
n_train = args.n_train
n_valid = args.n_valid
exc = args.exc
inh = args.inh
time = args.time
dt = args.dt
intensity = args.intensity
update_interval = args.update_interval
gpu = args.gpu
plot = args.plot
plot_interval = args.plot_interval

if use_mnist:
    import os
    from torchvision import transforms
    from bindsnet.datasets import MNIST

if plot:
    import matplotlib.pyplot as plt
    from bindsnet.utils import get_square_assignments, get_square_weights
    from bindsnet.analysis.plotting import (
        plot_input, plot_assignments, plot_weights, plot_spikes, plot_voltages
    )

###############################################################################
# Setup                                                                       #
###############################################################################
# Network and GPU-related setup
print('Setting up network')
n_neurons = 200
cuda_avail = torch.cuda.is_available()
network = ShowCaseNet(
    n_inpt=22*22,
    n_neurons=n_neurons,
    exc=exc,
    inh=inh,
    dt=dt,
    norm=48.4 if use_mnist else 2*48.4,
    nu=[1e-10, 1e-3] if use_mnist else [1e-5, 2e-3],
    inpt_shape=(1, 22, 22),
    theta_plus=0.05
)
device = torch.device(f'cuda' if gpu and cuda_avail else 'cpu')
print(f'Using device = {str(device)}')
network = network.to(device)
if gpu and cuda_avail:
    torch.cuda.manual_seed(seed)
else:
    torch.manual_seed(seed)

# Get the dataset
print('Fetching the dataset')
kws = ['up', 'down', 'left', 'right', 'on', 'off', 'yes', 'no', 'go', 'stop']
data_path = './data'
train_data = MNIST(
    RateEncoder(time=time, dt=dt),
    None,
    root=os.path.join('.', 'mnist'),
    download=True,
    transform=transforms.Compose([
        transforms.Resize(size=(22,22)), 
        transforms.ToTensor(), 
        transforms.Lambda(lambda x: x * intensity)
    ])
) if use_mnist else SpeechCommandsDataset(
    data_path, download=True, kws=kws
)
valid_data = MNIST(
    RateEncoder(time=time, dt=dt),
    None,
    root=os.path.join('.', 'mnist'),
    download=False,
    transform=transforms.Compose([
        transforms.Resize(size=(22,22)), 
        transforms.ToTensor(), 
        transforms.Lambda(lambda x: x * intensity)
    ]),
    train=False
) if use_mnist else SpeechCommandsDataset(
    data_path, download=False, split='valid', kws=kws
)
test_data = None if use_mnist else SpeechCommandsDataset(
    data_path, download=False, split='test', kws=kws
)

# Wrap in dataloaders
train_loader = DataLoader(
    train_data, batch_size=1, pin_memory=gpu and cuda_avail, shuffle=True
)
valid_loader = DataLoader(
    valid_data, batch_size=1, pin_memory=gpu and cuda_avail, shuffle=True
)
test_loader  = None if use_mnist else DataLoader(
    test_data, batch_size=1, pin_memory=gpu and cuda_avail, shuffle=True
)
if not use_mnist:
    audio_enc = RateEncoder(time=time, dt=dt)
    label_enc = NullEncoder()
n_train = n_train if n_train != -1 else len(train_loader.dataset)
n_valid = n_valid if n_valid != -1 else len(valid_loader.dataset)
n_classes = 10 if use_mnist else len(kws)
n_sqrt    = int(np.ceil(np.sqrt(n_neurons)))
per_class = int(n_neurons / n_classes)

# Recording stuff throughout the training
assignments = -torch.ones(n_neurons, device=device)
proportions = torch.zeros((n_neurons, n_classes), device=device)
rates = torch.zeros((n_neurons, n_classes), device=device)

# Spike recording
spikes = {}
for layer in set(network.layers):
    spikes[layer] = Monitor(network.layers[layer], state_vars=['s'], time=time)
    network.add_monitor(spikes[layer], name=f'{layer}_spikes')

# Voltage recording and plotting-related variables
if plot:
    exc_v_monitor = Monitor(
        network.layers['Ae'], ['v'], time=time, device=device
    )
    inh_v_monitor = Monitor(
        network.layers['Ai'], ['v'], time=time, device=device
    )
    network.add_monitor(exc_v_monitor, name='exc_voltage')
    network.add_monitor(inh_v_monitor, name='inh_voltage')

    inpt_axes, inpt_ims = None, None
    spike_ims, spike_axes = None, None
    weights_im = None
    assigns_im = None
    voltage_ims, voltage_axes = None, None

# For checkpointing purposes
best_network = network
best_acc     = 1 / n_classes

###############################################################################
# Training, validation, and test loops                                        #
###############################################################################
try:
    epochbar = tqdm(range(epochs))
    for ep in epochbar:
        # Training
        network.train(mode=True)
        accuracy = {'all': [], 'proportion': []}
        spike_record = torch.zeros(
            (update_interval, int(time / dt), n_neurons), device=device
        )
        labels = []
        print('Begin training.')
        for (i, datum) in tqdm(enumerate(train_loader)):
            if i >= n_train:
                break
            if use_mnist:
                image = datum['encoded_image']
                label = datum['label']
            else:
                image = audio_enc(datum['audio'] * intensity)
                image = image.view(1, *image.shape)
                label = label_enc(datum['label'])
            image, label = image.to(device), label.to(device)

            if i % update_interval == 0 and i > 0:
                # Get a tensor of labels
                label_tensor = torch.Tensor(labels).to(device)

                # Get network predictions.
                if use_mnist:
                    confusion = DataFrame(
                        [[0] * n_classes for _ in range(n_classes)]
                    )
                else:    
                    confusion = DataFrame(
                        [[0] * n_classes for _ in range(n_classes)], 
                        columns=kws, 
                        index=kws
                    )
                all_activity_pred = all_activity(
                    spike_record.to('cpu'), assignments.to('cpu'), n_classes
                ).to(device)
                proportion_pred = proportion_weighting(
                    spike_record.to('cpu'), 
                    assignments.to('cpu'), 
                    proportions.to('cpu'), 
                    n_classes
                ).to(device)
                for j in range(len(label_tensor)):
                    true_idx = label_tensor[j].long().item()
                    pred_idx = all_activity_pred[j].item()
                    if use_mnist:
                        confusion[true_idx][pred_idx] += 1
                    else:
                        confusion[kws[true_idx]][kws[pred_idx]] += 1

                # Compute network accuracy
                accuracy['all'].append(
                    100 * \
                    torch.sum(label_tensor.long() == all_activity_pred).item() \
                    / update_interval
                )
                accuracy['proportion'].append(
                    100 * \
                    torch.sum(label_tensor.long() == proportion_pred).item() \
                    / update_interval
                )

                print('\nAll activity accuracy: {:.2f} (last), '\
                      '{:.2f} (average), {:.2f} (best)'.format(
                    accuracy['all'][-1], 
                    np.mean(accuracy['all']), 
                    np.max(accuracy['all'])
                ))

                print('Proportion weighting accuracy: {:.2f} (last), '\
                      '{:.2f} (average), {:.2f} (best)\n'.format(
                    accuracy['proportion'][-1], 
                    np.mean(accuracy['proportion']), 
                    np.max(accuracy['proportion'])
                ))

                # Assign labels to excitatory layer neurons.
                assignments, proportions, rates = assign_labels(
                    spike_record, label_tensor, n_classes, rates
                )

                # Clear list of labels
                labels = []
                print('Confusion matrix:')
                print(confusion)

            labels.append(label)

            # Run the network on the input. Clamps output neurons.
            choice = np.random.choice(per_class, size=n_clamp, replace=False)
            clamp = {'Ae': per_class * label[0].long() \
                         + torch.Tensor(choice).long().to(device)}
            inputs = {'X': image.view(time, 1, 1, 22, 22)}
            network.run(inputs=inputs, time=time, clamp=clamp)

            # Add to spikes recording. The spikes are monitored constantly.
            spike_record[i % update_interval] = spikes['Ae'].get('s').view(
                time, n_neurons
            )

            # Optionally plot training information every plot interval
            if plot and i % plot_interval == 0 and i > 0:
                inpt = inputs['X'].view(time, 484).sum(0).view(22, 22)
                input_exc_weights = network.connections[('X', 'Ae')].w
                square_weights = get_square_weights(
                    input_exc_weights.view(484, n_neurons), n_sqrt, 22
                )
                square_assignments = get_square_assignments(
                    assignments, n_sqrt
                )
                voltages = {'Ae': exc_v_monitor.get('v'), 
                            'Ai': inh_v_monitor.get('v')}

                # Plot labelled input
                inpt_axes, inpt_ims = plot_input(
                    image.sum(1).view(22, 22),
                    inpt,
                    label=label,
                    axes=inpt_axes,
                    ims=inpt_ims,
                )
                
                # Plot the spikes from each layer
                spike_ims, spike_axes = plot_spikes(
                    {l: spikes[l].get('s').view(time, 1, -1) for l in spikes}, 
                    ims=spike_ims, 
                    axes=spike_axes,
                )

                # Plot the weights, assignments, and performance
                weights_im = plot_weights(square_weights, im=weights_im)
                assigns_im = plot_assignments(
                    square_assignments, im=assigns_im, classes=kws
                )

                # Plot the node voltages
                voltage_ims, voltage_axes = plot_voltages(
                    voltages, ims=voltage_ims, axes=voltage_axes
                )

                # Pause to allow plots to appear. Should be adjusted to the
                # particular system the script is running on.
                plt.pause(1)

            # Reset state variables.
            network.reset_state_variables()

        # Validation
        network.train(mode=False)
        print('Begin validation.')
        accuracy = {'all': 0, 'proportion': 0}
        spike_record = torch.zeros(
            (1, int(time / dt), n_neurons), device=device
        )
        if use_mnist:
            confusion = DataFrame([[0] * n_classes for _ in range(n_classes)])
        else:    
            confusion = DataFrame([[0] * n_classes for _ in range(n_classes)], 
                columns=kws, index=kws
            )
        for (i, datum) in tqdm(enumerate(valid_loader)):
            if i >= n_valid:
                break
            if use_mnist:
                image = datum['encoded_image']
                label = datum['label']
            else:
                image = audio_enc(datum['audio'] * intensity)
                image = image.view(1, *image.shape)
                label = label_enc(datum['label'])
            image, label = image.to(device), label.to(device)
            inputs = {'X': image.view(time, 1, 1, 22, 22)}
            # Run the network on the input
            network.run(inputs=inputs, time=time)
            # Add to spike record
            spike_record[0] = spikes['Ae'].get('s').squeeze()
            # Get network predictions
            all_activity_pred = all_activity(
                spike_record.to('cpu'), assignments.to('cpu'), n_classes
            ).to(device)
            proportion_pred = proportion_weighting(
                spike_record.to('cpu'), 
                assignments.to('cpu'), 
                proportions.to('cpu'), 
                n_classes
            ).to(device)
            # Compute accuracy
            accuracy['all'] += \
                float(torch.sum(label.long() == all_activity_pred).item())
            accuracy['proportion'] += \
                float(torch.sum(label.long() == proportion_pred).item())
            true_idx = label.long().item()
            pred_idx = all_activity_pred.item()
            if use_mnist:
                confusion[true_idx][pred_idx] += 1
            else:
                confusion[kws[true_idx]][kws[pred_idx]] += 1
            # Reset state variables
            network.reset_state_variables()
    
        acc = accuracy['all'] / n_valid
        propacc = accuracy['proportion'] / n_valid
        best_network = network if acc > best_acc else best_network
        print(f'Results for epoch {ep}:')
        print(f'\tOverall validation accuracy is {acc:.2f}')
        print(f'\tProportion weighting test accuracy is {propacc:.2f}')
        print('Confusion matrix:')
        print(confusion)

    if use_mnist:
        exit(0)

    print('Begin test.')
    network.train(mode=False)
    accuracy = {'all': 0, 'proportion': 0}
    spike_record = torch.zeros((1, int(time / dt), n_neurons), device=device)
    confusion = DataFrame([[0] * n_classes for _ in range(n_classes)], 
        columns=kws, index=kws
    )
    for datum in tqdm(test_loader):
        image = audio_enc(datum['audio'] * intensity).to(device)
        image = image.view(1, *image.shape)
        label = label_enc(datum['label']).to(device)
        inputs = {'X': image.view(time, 1, 1, 22, 22)}
        # Run the network on the input
        network.run(inputs=inputs, time=time)
        # Add to spike record
        spike_record[0] = spikes['Ae'].get('s').squeeze()
        # Get network predictions
        all_activity_pred = all_activity(
            spike_record.to('cpu'), assignments.to('cpu'), n_classes
        ).to(device)
        proportion_pred = proportion_weighting(
            spike_record.to('cpu'), 
            assignments.to('cpu'), 
            proportions.to('cpu'), 
            n_classes
        ).to(device)
        # Compute accuracy
        accuracy['all'] += \
            float(torch.sum(label.long() == all_activity_pred).item())
        accuracy['proportion'] += \
            float(torch.sum(label.long() == proportion_pred).item())
        confusion[kws[label.long().item()]][kws[all_activity_pred.item()]] += 1
        # Reset state variables
        network.reset_state_variables()
    
    print('Overall test accuracy is {:.2f}'.format(
        accuracy["all"] / len(test_loader.dataset)
    ))
    print('Proportion weighting test accuracy is {:.2f}'.format(
        accuracy["proportion"] / len(test_loader.dataset)
    ))
    print('Confusion matrix:')
    print(confusion)
except KeyboardInterrupt:
    print('Keyboard interrupt caught.')
finally:
    import os
    if not os.path.isdir('pretrained'):
        os.mkdir('pretrained')
    torch.save(best_network.state_dict(), 'pretrained/network.pt')
