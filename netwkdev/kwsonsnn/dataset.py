# The following is heavily inspired by 
# https://github.com/BindsNET/bindsnet/blob/master/bindsnet/datasets/spoken_mnist.py

from typing import Tuple, List, Iterable
import os
import torch
import torch.nn.functional as F
import numpy as np
from scipy.io import wavfile
import warnings
from tqdm import tqdm
import tarfile
from urllib.request import urlretrieve

class SpeechCommandsDataset(torch.utils.data.Dataset):
    """
    Handles loading and saving of the Speech Commands audio dataset `(link)
    <https://ai.googleblog.com/2017/08/launching-speech-commands-dataset.html>`_.
    """
    train_pickle = 'train.pt'
    valid_pickle = 'valid.pt'
    test_pickle  = 'test.pt'

    url = 'http://download.tensorflow.org/data/speech_commands_v0.01.tar.gz'
    keywords = ['bed', 'bird', 'cat', 'dog', 'down', 'eight', 'five', 'four',   \
                'go', 'happy', 'house', 'left', 'marvin', 'nine', 'no', 'off',  \
                'on', 'one', 'right', 'seven', 'sheila', 'six', 'stop','three', \
                'tree', 'two', 'up', 'wow', 'yes', 'zero']
    files = ['LICENSE', 'README.md', 'testing_list.txt', 'validation_list.txt']

    def __init__(
        self,
        path: str,
        download: bool = False,
        shuffle: bool = True,
        preprocess: bool = True,
        split: str = 'train',
        num_samples: int = -1,
        kws: List[str] = ['up', 'down', 'left', 'right', 'on', 'off', 'yes', 'no', 'go', 'stop']
    ) -> None:
        """
        Constructor for the ``SpeechCommandsDataset`` class. Assumes data is downloaded
        and unzipped in ``./path``.

        :param path: Pathname of directory in which to store the dataset.
        :param download: Whether to download the dataset.
        :param shuffle: Whether to randomly permute order of dataset.
        :param preprocess: Whether to preprocess the dataset.
        :param split: Train, test, or validation split; in ``{'train', 'test', 'valid'}``.
        :param num_samples: Number of samples to pass to the batch.
        :param kws: List of keywords to use; in {keywords in Speech Commands dataset}.
        """
        super().__init__()
        self.processed = False
        
        self.path = path
        self.shuffle = shuffle
        self.num_samples = num_samples
        self.kws = kws

        # Download the dataset if requested
        if download:
            self._download()

        # Check that specified keywords are legal
        labels = []
        for _, dirs, _ in os.walk(self.path):
            labels.extend(dirs)
        assert all(map(lambda x: x.lower() in labels, self.kws)), \
            'the list of keywords to use should all be part of the dataset'

        # Get the requested split
        if 'train' in split.lower():
            self.audio, self.labels, self.sr = self._get_train()
        elif 'test' in split.lower() or 'valid' in split.lower():
            self.audio, self.labels, self.sr = self._get_test_or_valid('valid' in split.lower())
        else:
            raise ValueError("split must be one of 'train', 'test', or 'valid'")
        
        # Process the data
        if preprocess:
            self._process_data()

    def __len__(self):
        return len(self.audio)

    def __getitem__(self, ind):
        """
        Generates slightly randomized shifts and noise versions of the audio signals.
        """
        if not self.processed:
            audio = self.audio[ind][:self.num_samples]
        else:
            audio = self.audio[ind]

        label = self.labels[ind]
        return {'audio': audio, 'label': label}

    def _get_splitfiles(self) -> List[str]:
        """
        Get the two files determining test and validation splits.
        """
        return [os.path.join(self.path, 'testing_list.txt'), 
                os.path.join(self.path, 'validation_list.txt')]

    def _get_train(self) -> Tuple[List[torch.Tensor], torch.Tensor, int]:
        """
        Get the training set split of the Speech Commands dataset.

        :return: Speech Commands training audio and labels.
        """
        split_files = self._get_splitfiles()
        remove_files = []
        for file in split_files:
            if not os.path.isfile(file):
                raise FileNotFoundError(f"test split file {file} not found")
            else:
                with open(file) as f:
                    lines = f.read().split('\n')
                    #lines = list(filter(lambda x: x[:x.find('/')] in self.kws, lines))
                    lines = [os.path.join(self.path, x) for x in lines]
                    remove_files.extend(lines)
        # Fix difference between Win32 and Unix paths
        remove_files = list(map(lambda x: x.replace('\\', '/'), remove_files))

        # If the training set has not been fetched before, fetch the entire set
        # and save it as a Pickle file
        pickle_file = os.path.join(self.path, SpeechCommandsDataset.train_pickle)
        if not os.path.isfile(pickle_file):
            # Find all files
            files = []
            for d in [os.path.join(self.path, kw) for kw in SpeechCommandsDataset.keywords]:
                for root, _, filenames in os.walk(d):
                    files.extend(list(map(lambda x: os.path.join(root, x), filenames)))
            # Fix difference between Win32 and Unix paths
            files = list(map(lambda x: x.replace('\\', '/'), files))

            # Remove files used as part of the other splits
            files = list(set(files).difference(set(remove_files)))

            # Fetch the unprocessed data
            audio, labels, sr = self._fetch_data(files)

            # Store as a Pickle file
            torch.save((audio, labels, sr), open(pickle_file, 'wb'))

        # Load the dataset from its Pickle file
        all_audio, all_labels, sr = torch.load(open(pickle_file), 'rb')

        # Get only the requested keywords
        audio, labels = [], []
        for a, l in zip(all_audio, all_labels):
            if l in self.kws:
                audio.append(a)
                labels.append(l)
        audio  = np.array(audio)
        labels = np.array(labels)
        
        # If requested, shuffle the data
        if self.shuffle:
            perm = np.random.permutation(np.arange(labels.shape[0]))
            audio, labels = [audio[_] for _ in perm], labels[perm]

        return audio, labels, sr

    def _get_test_or_valid(
        self, valid: bool = False
    ) -> Tuple[List[torch.Tensor], torch.Tensor, int]:
        """
        Get the validation or test set split of the Speech Commands dataset.

        :param valid: Whether to fetch test or validation split.
        :return: Speech Commands test audio and labels.
        """
        split_file = self._get_splitfiles()[1 if valid else 0]

        # First find which files to use
        files = []
        if not os.path.isfile(split_file):
            raise FileNotFoundError(f"test split file {split_file} not found")
        else:
            with open(split_file) as f:
                lines = f.read().split('\n')[:-2]
                #lines = list(filter(lambda x: x[:x.find('/')] in self.kws, lines))
                lines = [os.path.join(self.path, x) for x in lines]
                files.extend(lines)
        # Fix difference between Win32 and Unix paths
        files = list(map(lambda x: x.replace('\\', '/'), files))

        # If the test or validation set has not been fetched before, fetch the entire
        # set and save it as a Pickle file
        pickle_file = os.path.join(self.path, 
            SpeechCommandsDataset.valid_pickle if valid else SpeechCommandsDataset.test_pickle
        )
        if not os.path.isfile(pickle_file):
            # Fetch the unprocessed data
            audio, labels, sr = self._fetch_data(files)

            # Store it as a Pickle file
            torch.save((audio, labels, sr), open(pickle_file, 'wb'))        
        
        # Load the dataset from its Pickle file
        all_audio, all_labels, sr = torch.load(open(pickle_file, 'rb'))

        # Get only the requested keywords
        audio, labels = [], []
        for a, l in zip(all_audio, all_labels):
            if l in self.kws:
                audio.append(a)
                labels.append(l)
        audio  = np.array(audio)
        labels = np.array(labels)
        
        # If requested, shuffle the data
        if self.shuffle:
            perm = np.random.permutation(np.arange(labels.shape[0]))
            audio, labels = [torch.Tensor(audio[_]) for _ in perm], labels[perm]

        return audio, labels, sr
    
    def _download(self) -> None:
        """
        Downloads and unzips the Speech Commands dataset, if it is not already downloaded.
        """
        tar_name = 'dataset.tar.gz'

        def dataset_avail() -> bool:
            return all(map(lambda x: os.path.exists(os.path.join(self.path, x)), SpeechCommandsDataset.keywords)) \
                   and all(map(lambda x: os.path.isfile(os.path.join(self.path, x)), SpeechCommandsDataset.files))

        def tarfile_avail() -> bool:
            return os.path.isfile(os.path.join(self.path, tar_name))

        # Create directory if it does not exist
        if not os.path.isdir(self.path):
            os.mkdir(self.path)
        
        # Check if the dataset is already downloaded
        if not dataset_avail():
            if not tarfile_avail():
                # Download the dataset file
                urlretrieve(url, os.path.join(self.path, tar_name))

            # Extracting leads to all data folders being present in ``data_path``
            cwd = os.getcwd()
            os.chdir(self.path)
            f = tarfile.open(tar_name, 'r:gz')
            f.extractall()
            f.close()
            os.remove(tar_name)
            os.chdir(cwd)

    def _fetch_data(
        self, files: Iterable[str]
    ) -> Tuple[List[np.ndarray], np.ndarray, int]:
        """
        Opens files of Speech Commands data and processes them into ``numpy`` arrays.
        Labels are one-hot encoded according to their position in ``self.kws``.

        :param files: Names of the files containing Spoken MNIST audio to load.
        :return: Processed Speech Commands audio and label data.
        """
        audio, labels = [], []
        exp_sr, _ = wavfile.read(files[0])

        # For subsampling - to center the audio, the subsampled frames are weighted
        # by a window giving central samples greater weight
        frame_length, frame_stride = 8000, 1000
        num_frames = (exp_sr - frame_length) // frame_stride + 1
        indices = (
            np.tile(np.arange(0, frame_length), (num_frames, 1))
            + np.tile(
                np.arange(0, num_frames * frame_stride, frame_stride), (frame_length, 1)
            ).T
        )
        weight = np.tile(np.blackman(frame_length), (num_frames, 1))

        # For each file, fetch the audio signal
        pbar = tqdm(files)
        for f in pbar:
            # Get label from file name
            label = f.split('/')[-2]
            
            # Get signal from .wav file
            sr, signal = wavfile.read(f)
            if sr != exp_sr:
                raise ValueError("all audio files must have the same sampling rate")
            
            # Taken directly from
            # https://github.com/BindsNET/bindsnet/blob/master/bindsnet/datasets/spoken_mnist.py
            # also inspired by
            # https://towardsdatascience.com/speech-classification-using-neural-networks-the-basics-e5b08d6928b7
            pre_emphasis = 0.97
            emphasized_signal = np.append(
                signal[0], signal[1:] - pre_emphasis * signal[:-1]
            )
            
            # Pad to length of 1 second
            signal = np.hstack(
                (signal, np.random.normal(scale=abs(np.median(signal)), size=exp_sr-len(signal)))
            )

            # Pick out sub-part of the signal - first attempt uses 8000 samples (i.e., half)
            frames = signal[indices.astype(np.int32, copy=False)]
            signal = frames[np.argmax(np.sum(np.dot(np.abs(frames), weight.T), 1))]

            # Normalization for easier plotting
            signal /= max(np.abs(signal))
            
            # Append the signal and its label to the lists
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                audio.append(signal), labels.append(label)
        
        return audio, np.array(labels), exp_sr
    
    def _process_data(self) -> None:
        """
        Applies common FFT-related techniques to the audio signals but leaves
        the labels. Must be called explicitly to affect the dataset. Non-reversible.
        """
        if self.processed:
            print('Dataset has already been processed!')
            return
        self.processed = True
        
        # Run through all audio and labels
        audio, labels = [], []
        pbar = tqdm(zip(self.audio, self.labels))
        for signal, label in pbar:
            # Again, taken more or less directly from
            # https://github.com/BindsNET/bindsnet/blob/master/bindsnet/datasets/spoken_mnist.py
            
            # Various sources use different frame sizes - typical values in [10ms, 40ms]
            # Similarly, different strides (and hence, overlaps) are used - typical values in [0%, 75%]
            # For example, https://github.com/BindsNET/bindsnet/blob/master/bindsnet/datasets/spoken_mnist.py
            # uses frame_size=25ms and frame_stride=10ms (60% overlap)
            # whereas Hello Edge (https://arxiv.org/abs/1711.07128)
            # uses frame_size=40ms and frame_stride=20ms (50% overlap)
            # and Benchmarking KWS Efficiency ... (https://arxiv.org/abs/1812.01739)
            # uses frame_size=.... and frame_stride=10ms (... overlap).
            # I choose to use the same setup as Hello Edge targeting a smaller network as presented
            # in Benchmarking KWS Efficiency (i.e., no convolutions).

            # Also, the Mel Spectral Frequency Component analysis transforms the inputs to
            # the same size as the images used as part of the previous work by Anthon (i.e., 22x22).
            # TODO: Make this code more flexible - for example allowing selection of frame_length.
            
            # In seconds ... (like Hello Edge now)
            frame_length = 0.04
            frame_stride = 0.02
            
            assert frame_length <= 1.0, (
                f'frames should be shorter than or equal to signal length, got {frame_length}'
            )
            assert frame_stride < frame_length, (
                f'frame stride should be less than frame length, got {frame_length} and {frame_stride}'
            )
            
            # ... converted to samples
            frame_length, frame_stride = (
                int(round(frame_length * self.sr)),
                int(round(frame_stride * self.sr))
            )
            signal_length = len(signal)
            
            # Pad to ensure at least one frame
            num_frames = int(np.ceil(float(np.abs(signal_length - frame_length)) / frame_stride))
            pad_signal_length = num_frames * frame_stride + frame_length
            signal = np.append(signal, np.zeros((pad_signal_length - signal_length)))
            #signal /= max(np.abs(signal)) # normalization
            
            # Collect frames from signal
            indices = (
                np.tile(np.arange(0, frame_length), (num_frames, 1))
                + np.tile(
                    np.arange(0, num_frames * frame_stride, frame_stride), (frame_length, 1)
                ).T
            )
            frames = signal[indices.astype(np.int32, copy=False)]
            
            # A Hamming window is used to reduce noise in the FFT due to cuts in the signal
            frames *= np.hamming(frame_length)
            
            # Perform FFT (real input signal)
            # According to https://haythamfayek.com/2016/04/21/speech-processing-for-machine-learning.html
            # NFFT is typically either 256 or 512
            NFFT = 512
            f_mag = np.abs(np.fft.rfft(frames, NFFT))
            f_pow = (1.0 / NFFT) * (f_mag ** 2)
            
            # Generate Mel filter banks
            nfilt = 22
            # Convert Hz to Mel (see https://en.wikipedia.org/wiki/Mel_scale)
            low_freq_mel = 0
            high_freq_mel = 2595 * np.log10(1 + (self.sr / 2) / 700)
            # Equally spaced in Mel scale
            mel_points = np.linspace(low_freq_mel, high_freq_mel, nfilt + 2)
            hz_points = 700 * (10 ** (mel_points / 2595) - 1)
            bin = np.floor((NFFT + 1) * hz_points / self.sr)

            fbank = np.zeros((nfilt, int(np.floor(NFFT / 2 + 1))))
            for m in range(1, nfilt + 1):
                f_m_minus = int(bin[m - 1])  # left
                f_m = int(bin[m])  # center
                f_m_plus = int(bin[m + 1])  # right

                for k in range(f_m_minus, f_m):
                    fbank[m - 1, k] = (k - bin[m - 1]) / (bin[m] - bin[m - 1])
                for k in range(f_m, f_m_plus):
                    fbank[m - 1, k] = (bin[m + 1] - k) / (bin[m + 1] - bin[m])

            filter_banks = np.dot(f_pow, fbank.T)
            # Replace zeros with smallest positive number for stability
            filter_banks = np.where(filter_banks == 0, np.finfo(float).eps, filter_banks)
            # Convert to dB
            filter_banks = 20 * np.log10(filter_banks)
            # Fix negative dB numbers after normalization
            filter_banks += np.abs(np.min(filter_banks))
            # Normalize the signal
            filter_banks /= np.max(filter_banks)
            
            # Append the signal and its label to the lists
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                audio.append(torch.Tensor(filter_banks[:nfilt, :nfilt]))
                labels.append(self.kws.index(label))
        
        # Store result
        self.audio, self.labels = torch.stack(audio), torch.Tensor(labels)
