from .model import ShowCaseNet

import os
import shutil
import tarfile
from urllib.request import urlretrieve
from bindsnet.network import Network

def download(data_path: str) -> None:
    """
    Download the Speech Commands dataset if it is not already downloaded.

    :param data_path: a string representing the download position of the dataset.
    """
    url = 'http://download.tensorflow.org/data/speech_commands_v0.01.tar.gz'
    tar_name = 'dataset.tar.gz'

    # Create directory if it does not exist
    if not os.path.isdir(data_path):
        os.mkdir(data_path)

    # Check if the dataset is already downloaded
    if not dataset_avail(data_path):
        if not tarfile_avail(data_path, tar_name):
            # Download the dataset file
            urlretrieve(url, os.path.join(data_path, tar_name))
        
        # Extracting leads to all data folders being present in ``data_path``
        cwd = os.getcwd()
        os.chdir(data_path)
        f = tarfile.open(tar_name, 'r:gz')
        f.extractall()
        f.close()
        os.remove(tar_name)
        os.chdir(cwd)

def dataset_avail(data_path: str) -> bool:
    """
    Check if the Speech Commands dataset is available at the specified location.

    :param data_path: the path to the dataset

    :return: whether the dataset is downloaded and unpacked
    """
    folders = ['_background_noise_', 'bed', 'bird', 'cat', 'dog', 'down', 'eight', \
               'five', 'four', 'go', 'happy', 'house', 'left', 'marvin', 'nine',   \
               'no', 'off', 'on', 'one', 'right', 'seven', 'sheila', 'six', 'stop',\
               'three', 'tree', 'two', 'up', 'wow', 'yes', 'zero']
    files   = ['LICENSE', 'README.md', 'testing_list.txt', 'validation_list.txt']
    return all(map(lambda x: os.path.exists(os.path.join(data_path, x)), folders)) \
           and all(map(lambda x: os.path.isfile(os.path.join(data_path, x)), files))
    
def tarfile_avail(data_path: str, tar_name: str) -> bool:
    """
    Check if the Speech Commands tarfile is available at the specified location.

    :param data_path: the path to the tarfile
    :param tar_name: the name of the tarfile

    :return: whether the tarfile exists
    """
    return os.path.isfile(os.path.join(data_path, tar_name))

def get_default_net() -> Network:
    """
    Return the default configuration net used in all scripts. Edit it here for easy
    global changes.

    :return: the default ShowCaseNet object
    """
    return ShowCaseNet(
        n_inpt=22*22,
        n_neurons=200,
        exc=22.5*1000,
        inh=22.5*1000,
        dt=1.0,
        norm=78.4*1000,
        nu=[1e-1, 1e-1],
        inpt_shape=(1, 22, 22),
        theta_plus=0.05*1000
    )
