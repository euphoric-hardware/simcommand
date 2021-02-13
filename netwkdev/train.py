from kwsonsnn.model import ShowCaseNet
from kwsonsnn.dataset import SpeechCommandsDataset
from kwsonsnn.encode import RateEncoder
from kwsonsnn.utils import get_default_net, download

import argparse
import numpy as np
import torch
import matplotlib.pyplot as plt
from tqdm import tqdm
from bindsnet.network.monitors import Monitor
from bindsnet.evaluation import all_activity, proportion_weighting, assign_labels
from bindsnet.encoding import NullEncoder

###############################################################################
# Argument parsing                                                            #
###############################################################################
print('Initializing parser')
parser = argparse.ArgumentParser()
parser.add_argument("--seed", type=int, default=2)
parser.add_argument("--epochs", type=int, default=5)
parser.add_argument("--n_neurons", type=int, default=200)
parser.add_argument("--n_clamp", type=int, default=1)
parser.add_argument("--exc", type=float, default=22.5)
parser.add_argument("--inh", type=float, default=22.5)
parser.add_argument("--time", type=int, default=500)
parser.add_argument("--dt", type=int, default=1.0)
parser.add_argument("--update_interval", type=int, default=250)
parser.add_argument("--gpu", dest="gpu", action="store_true")
parser.set_defaults(gpu=False)

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
gpu = args.gpu

###############################################################################
# Setup                                                                       #
###############################################################################
# Network and GPU-related setup
print('Setting up network')
network = get_default_net()
device = torch.device(f'cuda' if gpu and torch.cuda.is_available() else 'cpu')
print(f'Using device = {str(device)}')
network.to(device)
if gpu and torch.cuda.is_available():
    torch.cuda.manual_seed(seed)
else:
    torch.manual_seed(seed)

# Voltage recording for excitatory and inhibitory layers.
print('Setting up monitors')
exc_voltage_monitor = Monitor(network.layers["Ae"], ["v"], time=time)
inh_voltage_monitor = Monitor(network.layers["Ai"], ["v"], time=time)
network.add_monitor(exc_voltage_monitor, name="exc_voltage")
network.add_monitor(inh_voltage_monitor, name="inh_voltage")

# Get the dataset
print('Fetching the dataset')
data_path = './data'
download(data_path)
train_data = SpeechCommandsDataset(data_path)
valid_data = SpeechCommandsDataset(data_path, split='valid')
test_data  = SpeechCommandsDataset(data_path, split='test')
train_data.process_data()
valid_data.process_data()
test_data.process_data()
# Wrap in dataloaders
train_loader = torch.utils.data.DataLoader(
    train_data, batch_size=1, pin_memory=gpu and torch.cuda.is_available()
)
valid_loader = torch.utils.data.DataLoader(
    valid_data, batch_size=1, pin_memory=gpu and torch.cuda.is_available()
)
test_loader  = torch.utils.data.DataLoader(
    test_data,  batch_size=1, pin_memory=gpu and torch.cuda.is_available()
)
audio_enc = RateEncoder(time=time, dt=dt)
label_enc = NullEncoder()
n_classes = 10
per_class = int(n_neurons / n_classes)

# Recording stuff throughout the training
spike_record = torch.zeros((update_interval, int(time / dt), n_neurons), device=device)
assignments = -torch.ones(n_neurons, device=device)
proportions = torch.zeros((n_neurons, n_classes), device=device)
rates = torch.zeros((n_neurons, n_classes), device=device)
accuracy = {"all": [], "proportion": []}
labels = []
spikes = {}
for layer in set(network.layers):
    spikes[layer] = Monitor(network.layers[layer], state_vars=["s"], time=time)
    network.add_monitor(spikes[layer], name=f"{layer}_spikes")

# For checkpointing purposes
best_network = network
best_acc     = 1 / n_classes

###############################################################################
# Training, validation, and test loops                                        #
###############################################################################
try:
    print("Begin training loop.")
    epochbar = tqdm(range(epochs))
    for ep in epochbar:
        # Training
        network.train(mode=True)
        accuracy = {"all": [], "proportion": []}
        spike_record = torch.zeros((update_interval, int(time / dt), n_neurons), device=device)
        print("Begin training.")
        for (i, datum) in tqdm(enumerate(train_loader)):
            image = audio_enc(datum['audio']).to(device)
            label = label_enc(datum['label']).to(device)

            if i % update_interval == 0 and i > 0:
                # Get a tensor of labels
                label_tensor = torch.Tensor(labels).to(device)

                # Get network predictions.
                all_activity_pred = all_activity(
                    spike_record.to(device), assignments.to(device), n_classes
                ).to(device)
                proportion_pred = proportion_weighting(
                    spike_record.to(device), assignments.to(device), proportions.to(device), n_classes
                ).to(device)

                # Compute network accuracy according to available classification strategies.
                accuracy["all"].append(
                    100 * torch.sum(label_tensor.long() == all_activity_pred).item() / update_interval
                )
                accuracy["proportion"].append(
                    100 * torch.sum(label_tensor.long() == proportion_pred).item() / update_interval
                )

                print('\nAll activity accuracy: {:.2f} (last), {:.2f} (average), {:.2f} (best)'.format(
                    accuracy["all"][-1], np.mean(accuracy["all"]), np.max(accuracy["all"])
                ))

                print('Proportion weighting accuracy: {:.2f} (last), {:.2f} (average), {:.2f} (best)\n'.format(
                    accuracy["proportion"][-1], np.mean(accuracy["proportion"]), np.max(accuracy["proportion"])
                ))

                # Assign labels to excitatory layer neurons.
                assignments, proportions, rates = assign_labels(spike_record, label_tensor, n_classes, rates)

                # Clear list of labels
                labels = []

            labels.append(label)

            # Run the network on the input. Clamps expected output neurons forcing them to spike.
            choice = np.random.choice(per_class, size=n_clamp, replace=False)
            clamp = {"Ae": per_class * label[0].long() + torch.Tensor(choice).long().to(device)}
            inputs = {"X": image.view(time, 1, 1, 22, 22)}
            network.run(inputs=inputs, time=time, clamp=clamp)

            # Get voltage recording. Fetches voltage on both excitatory and inhibitory connections.
            exc_voltages = exc_voltage_monitor.get("v")
            inh_voltages = inh_voltage_monitor.get("v")

            # Add to spikes recording. The spikes are monitored constantly.
            spike_record[i % update_interval] = spikes["Ae"].get("s").view(time, n_neurons)

            # Reset state variables.
            network.reset_state_variables()

        # Validation
        network.train(mode=False)
        print("Begin validation.")
        accuracy = {"all": 0, "proportion": 0}
        spike_record = torch.zeros((1, int(time / dt), n_neurons), device=device)
        for (i, datum) in tqdm(enumerate(valid_loader)):
            image = audio_enc(datum['audio']).to(device)
            label = label_enc(datum['label']).to(device)
            inputs = {"X": image.view(time, 1, 1, 22, 22)}
            # Run the network on the input
            network.run(inputs=inputs, time=time)
            # Add to spike record
            spike_record[0] = spikes["Ae"].get("s").squeeze()
            # Get network predictions
            all_activity_pred = all_activity(
                spike_record.to(device), assignments.to(device), n_classes
            ).to(device)
            proportion_pred = proportion_weighting(
                spike_record.to(device), assignments.to(device), proportions.to(device), n_classes
            ).to(device)
            # Compute accuracy
            accuracy["all"] += float(torch.sum(label.long() == all_activity_pred).item())
            accuracy["proportion"] += float(
                torch.sum(label.long() == proportion_pred).item()
            )
            # Reset state variables
            network.reset_state_variables()
    
        acc = accuracy["all"] / len(valid_loader.dataset)
        propacc = accuracy["proportion"] / len(valid_loader.dataset)
        best_network = network if acc > best_acc else best_network
        print(f'Results for epoch {ep}:')
        print(f'\tOverall validation accuracy is {acc:.2f}')
        print(f'\tProportion weighting test accuracy is {propacc:.2f}')

    print('Begin test.')
    network.train(mode=False)
    accuracy = {"all": 0, "proportion": 0}
    spike_record = torch.zeros((1, int(time / dt), n_neurons), device=device)
    for datum in tqdm(test_loader):
        image = audio_enc(datum['audio']).to(device)
        label = label_enc(datum['label']).to(device)
        inputs = {"X": image.view(time, 1, 1, 22, 22)}
        # Run the network on the input
        network.run(inputs=inputs, time=time)
        # Add to spike record
        spike_record[0] = spikes["Ae"].get("s").squeeze()
        # Get network predictions
        all_activity_pred = all_activity(
            spike_record.to(device), assignments.to(device), n_classes
        ).to(device)
        proportion_pred = proportion_weighting(
            spike_record.to(device), assignments.to(device), proportions.to(device), n_classes
        ).to(device)
        # Compute accuracy
        accuracy["all"] += float(torch.sum(label.long() == all_activity_pred).item())
        accuracy["proportion"] += float(
            torch.sum(label.long() == proportion_pred).item()
        )
        # Reset state variables
        network.reset_state_variables()
    
    print(f'Overall test accuracy is {accuracy["all"] / len(test_loader.dataset):.2f}')
    print(f'Proportion weighting test accuracy is {accuracy["proportion"] / len(test_loader.dataset):.2f}')
except KeyboardInterrupt:
    print('Keyboard interrupt caught.')
finally:
    import os
    if not os.path.isdir('pretrained'):
        os.mkdir('pretrained')
    torch.save(best_network.state_dict(), 'pretrained/network.pt')
