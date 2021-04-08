# Reused from
# https://github.com/Thonner/bindsnet/blob/master/bindsnet/encoding/encodings.py

import torch
from bindsnet.encoding import Encoder

class RateEncoder(Encoder):
    def __init__(self, time: int, dt: float = 1.0, **kwargs):
        """
        Creates a callable RateEncoder which encodes as defined in ``bindsnet.encoding``
        
        :param time: Length of Rate spike train per input variable.
        :param dt: Simulation time step.
        """
        super().__init__(time, dt=dt, **kwargs)

        self.enc = rate

def rate(datum: torch.Tensor, time: int, dt: float = 1.0, **kwargs) -> torch.Tensor:
    """
    Direct rate based incoding
    """
    assert (datum >= 0).all(), "Inputs must be non-negative"

    # Get shape and size of data.
    shape, size = datum.shape, datum.numel()
    datum = datum.flatten()
    time = int(time / dt)

    # Compute firing rates in seconds as function of data intensity,
    # accounting for simulation time step.
    rate = torch.zeros(size, device=datum.device)
    rate[datum != 0] = 1 / datum[datum != 0] * (1000 / dt)
    
    timeRates = torch.ones(time+1, size, device=datum.device)
    for i in range(time+1):
        timeRates[i] = rate
        
    # Calculate spike times by cumulatively summing over time dimension.
    times = torch.cumsum(timeRates, dim=0).long()
    times[times >= time + 1] = 0

    # Create tensor of spikes.
    spikes = torch.zeros(time + 1, size, device=datum.device).byte()
    spikes[times, torch.arange(size)] = 1
    spikes = spikes[1:]

    return spikes.view(time, *shape)

class RatePeriod(Encoder):
    def __init__(self, time: int, dt: float = 1.0, **kwargs):
        """
        Creates a callable RatePeriod which returns the period of spikes as defined in
        ``bindsnet.encoding``

        :param time: Length of rate spike train per input variable.
        :param dt: Simulation time step.
        """
        super().__init__(time, dt=dt, **kwargs)

        self.enc = ratePeriod

def ratePeriod(datum: torch.Tensor, time: int, dt: float = 1.0, **kwargs) -> torch.Tensor:
    """
    Indirect period-based rate encoding
    """
    assert (datum >= 0).all(), "Inputs must be non-negative"

    # Get shape and size of data.
    shape, size = datum.shape, datum.numel()
    datum = datum.flatten()
    time = int(time / dt)

    # Compute firing rates in seconds as function of data intensity,
    # accounting for simulation time step.
    rate = torch.zeros(size, device=datum.device)
    rate[datum != 0] = 1 / datum[datum != 0] * (1000 / dt)
    
    return torch.clamp(rate.round(), min=0, max=time).long()

# Everything below here is new
class RankOrderDirect(Encoder):
    def __init__(self, time: int, dt: float = 1.0, **kwargs):
        """
        Creates a callable RankOrderDirect which returns the period of rank-order
        encoded spikes as defined in ``bindsnet.encoding``

        :param time: Length of input spike train per input variable.
        :param dt: Simulation time step.
        """
        super().__init__(time, dt=dt, **kwargs)

        self.enc = rankOrderDirect

def rankOrderDirect(datum: torch.Tensor, time: int, dt: float = 1.0, **kwargs) -> torch.Tensor:
    """
    Direct rank order coding (alternative to BindsNET's implementation).    
    """
    assert (datum >= 0).all(), "Inputs must be non-negative"

    # Get shape and size of data.
    shape, size = datum.shape, datum.numel()
    datum = datum.flatten()
    time = int(time / dt)

    # Compute encoding. One spike in each time step based on sorted data.
    spikeTimes = torch.argsort(datum)
    spikes = torch.zeros(time*size, device=datum.device)
    for i in range(min(time, size)):
        spikes[i*size + spikeTimes[i]] = 1

    # Calculate return shape.
    rShape = [time]
    rShape.extend(shape)
    
    return torch.reshape(spikes, tuple(rShape))

class RankOrderPeriod(Encoder):
    def __init__(self, time: int, dt: float = 1.0, **kwargs):
        """
        Creates a callable RankOrderPeriod which returns the period of rank-order
        encoded spikes as defined in ``bindsnet.encoding``

        :param time: Length of input spike train per input variable.
        :param dt: Simulation time step.
        """
        super().__init__(time, dt=dt, **kwargs)

        self.enc = rankOrderPeriod

def rankOrderPeriod(datum: torch.Tensor, time: int, dt: float = 1.0, **kwargs) -> torch.Tensor:
    """
    Indirect period-based rank-order encoding
    """
    assert (datum >= 0).all(), "Inputs must be non-negative"

    return torch.argsort(datum.flatten())
