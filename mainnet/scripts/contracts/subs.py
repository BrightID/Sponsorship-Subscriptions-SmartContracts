from . import utils


def owner():
    func_owner = utils.contracts['sp_minter'].functions.owner()
    owner = utils.send_eth_call(func_owner)
    return owner


def is_minter(account):
    func = utils.contracts['subs'].functions.isMinter(account)
    flag = utils.send_eth_call(func)
    return flag


def add_minter(private_key, account):
    func = utils.contracts['subs'].functions.addMinter(account)
    tx_hash = utils.send_transaction(func, 0, private_key)
    return tx_hash


def remove_minter(private_key):
    func = utils.contracts['subs'].functions.renounceMinter()
    tx_hash = utils.send_transaction(func, 0, private_key)
    return tx_hash


def transfer_ownership(private_key, account):
    func = utils.contracts['subs'].functions.transferOwnership(account)
    tx_hash = utils.send_transaction(func, 0, private_key)
    return tx_hash


def is_pauser(account):
    func = utils.contracts['subs'].functions.isPauser(account)
    flag = utils.send_eth_call(func)
    return flag


def add_pauser(private_key, account):
    func = utils.contracts['subs'].functions.addPauser(account)
    tx_hash = utils.send_transaction(func, 0, private_key)
    return tx_hash


def remove_pauser(private_key):
    func = utils.contracts['subs'].functions.renouncePauser()
    tx_hash = utils.send_transaction(func, 0, private_key)
    return tx_hash
