from kwsonsnn.dataset import SpeechCommandsDataset

import argparse
from tqdm import tqdm
import numpy as np
from pandas import DataFrame
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim

###############################################################################
# Argument parsing                                                            #
###############################################################################
print('Initializing parser')
parser = argparse.ArgumentParser()
parser.add_argument("--use_mnist", dest="use_mnist", action="store_true")
parser.add_argument("--seed", type=int, default=2)
parser.add_argument("--epochs", type=int, default=100)
parser.add_argument("--lr", type=float, default=0.0002)
parser.add_argument("--n_train", type=int, default=-1)
parser.add_argument("--n_valid", type=int, default=-1)
parser.add_argument("--gpu", dest="gpu", action="store_true")
parser.set_defaults(use_mnist=False, gpu=False)

args = parser.parse_args()

use_mnist = args.use_mnist
seed = args.seed
epochs = args.epochs
lr = args.lr
n_train = args.n_train
n_valid = args.n_valid
gpu = args.gpu

if use_mnist:
    import os
    from torchvision import transforms
    from torchvision.datasets import MNIST

###############################################################################
# Setup                                                                       #
###############################################################################
# Network and GPU-related setup
print('Setting up network')

class ShowCaseNetPT(nn.Module):
    def __init__(self):
        super(ShowCaseNetPT, self).__init__()

        # Build a very simple model with two layers
        self.ff1 = nn.Linear(
            in_features=22*22,
            out_features=200
        )
        self.ff2 = nn.Linear(
            in_features=200,
            out_features=200
        )

    def forward(self, X):
        return F.softmax(self.ff2(F.relu(self.ff1(X.view(-1)))), dim=0)

network = ShowCaseNetPT()
device = torch.device(f'cuda' if gpu and torch.cuda.is_available() else 'cpu')
print(f'Using device = {str(device)}')
network = network.to(device)
if gpu and torch.cuda.is_available():
    torch.cuda.manual_seed(seed)
else:
    torch.manual_seed(seed)

# Get the dataset
print('Fetching the dataset')
kws = ['up', 'down', 'left', 'right', 'on', 'off', 'yes', 'no', 'go', 'stop']
data_path = './data'
train_data = MNIST(
    os.path.join(".", "mnist"), 
    download=True,
    transform=transforms.Compose(
        [transforms.Resize(size=(22,22)), transforms.ToTensor()]
    )
) if use_mnist else SpeechCommandsDataset(data_path, download=True, kws=kws)
valid_data = MNIST(
    os.path.join(".", "mnist"), 
    download=False,
    transform=transforms.Compose(
        [transforms.Resize(size=(22,22)), transforms.ToTensor()]
    ),
    train=False
) if use_mnist else SpeechCommandsDataset(data_path, download=False, split='valid', kws=kws)
test_data = None if use_mnist else SpeechCommandsDataset(data_path, download=False, split='test', kws=kws)

# Wrap in dataloaders
train_loader = torch.utils.data.DataLoader(
    train_data, batch_size=1, pin_memory=gpu and torch.cuda.is_available(), shuffle=True
)
valid_loader = torch.utils.data.DataLoader(
    valid_data, batch_size=1, pin_memory=gpu and torch.cuda.is_available(), shuffle=True
)
test_loader  = None if use_mnist else torch.utils.data.DataLoader(
    test_data,  batch_size=1, pin_memory=gpu and torch.cuda.is_available(), shuffle=True
)
n_train = n_train if n_train != -1 else len(train_loader.dataset)
n_valid = n_valid if n_valid != -1 else len(valid_loader.dataset)
n_classes = 10 if use_mnist else len(kws)

# For checkpointing purposes
best_network = network
best_acc     = 1 / n_classes

# Get predicted class
def get_pred(Y_hat):
    # Convert Y_hat to the right size
    Y_hat = Y_hat.view(n_classes, -1)
    Y_hat = Y_hat.sum(1)
    return Y_hat.argmax()

# Custom loss function to use the same network
def cust_crit(Y_hat, Y):
    # Convert Y_hat to the right size
    Y_hat = Y_hat.view(n_classes, -1)
    Y_hat = Y_hat.sum(1)

    # One-hot encode Y
    oh = torch.zeros(n_classes, device=device)
    oh[Y.long().item()] = 1
    Y = oh

    # Return mean absolute error
    return torch.sum(torch.abs(Y_hat - Y)) / n_classes

###############################################################################
# Training, validation, and test loops                                        #
###############################################################################
criterion = cust_crit
optimizer = optim.Adam(network.parameters(), lr=lr)
try:
    print('Begin training loop.')
    epochbar = tqdm(range(epochs))
    for ep in epochbar:
        # Training
        print(f'Epoch {ep}, learning rate {lr}')
        network.train()
        hit = 0
        epoch_training_loss = 0
        for (i, datum) in tqdm(enumerate(train_loader)):
            if i >= n_train:
                break
            optimizer.zero_grad()
            inputs = datum[0] if use_mnist else datum['audio'].to(device)
            target = datum[1] if use_mnist else torch.Tensor([datum['label']]).to(device)
            output = network(inputs)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()
            epoch_training_loss += loss.item()

            if target.long().item() == get_pred(output).long().item():
                hit += 1
        print(f'\ttraining loss: {epoch_training_loss / n_train}, accuracy: {hit / n_train}')

        # Validation
        network.eval()
        epoch_validation_loss = 0
        hit = 0
        confusion = DataFrame([[0] * n_classes for _ in range(n_classes)])
        with torch.no_grad():
            for (i, datum) in tqdm(enumerate(valid_loader)):
                if i >= n_valid:
                    break
                inputs = datum[0] if use_mnist else datum['audio'].to(device)
                target = datum[1] if use_mnist else torch.Tensor([datum['label']]).to(device)
                output = network(inputs)
                loss = criterion(output, target)
                epoch_validation_loss += loss.item()

                confusion[target.long().item()][get_pred(output).long().item()] += 1
                if target.long().item() == get_pred(output).long().item():
                    hit += 1
        print(f'\tvalidation loss: {epoch_validation_loss / n_valid}, accuracy: {hit / n_valid}')
        print('Confusion matrix:')
        print(confusion)

    if use_mnist:
        exit(0)
    
    print('Begin test.')
    network.eval()
    hit = 0
    test_loss = 0
    with torch.no_grad():
        for (i, datum) in tqdm(enumerate(test_loader)):
            inputs = datum[0] if use_mnist else datum['audio'].to(device)
            target = datum[1] if use_mnist else torch.Tensor([datum['label']]).to(device)
            output = network(inputs)
            loss = criterion(output, target)
            test_loss += loss.item()

            if target.long().item() == get_pred(output).long().item():
                hit += 1
    print(f'\ttest loss: {test_loss / len(test_loader.dataset)}, accuracy: {hit / len(test_loader.dataset)}')

except KeyboardInterrupt:
    print('Keyboard interrupt caught.')
finally:
    import os
    if not os.path.isdir('pretrained'):
        os.mkdir('pretrained')
    torch.save(best_network.state_dict(), 'pretrained/networkpt.pt')
