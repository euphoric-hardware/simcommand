from .model import ShowCaseNet

from bindsnet.network import Network

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
        nu=[1e-4, 1e-2], #[1e-1, 1e-1]
        inpt_shape=(1, 22, 22),
        theta_plus=0.05*1000
    )
