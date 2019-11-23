from . import utils


def owner():
    func_owner = utils.contracts['sp_minter'].functions.owner()
    owner = utils.send_eth_call(func_owner)
    return owner


def transfer_ownership(private_key, account):
    func = utils.contracts['sp_minter'].functions.transferOwnership(account)
    tx_hash = utils.send_transaction(func, 0, private_key)
    return tx_hash
