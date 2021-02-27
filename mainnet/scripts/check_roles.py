from contracts import subs_minter
from contracts import sp_minter
from contracts import utils
from contracts import subs
from contracts import sp

contracts = {'sp': sp, 'subs': subs,
             'sp_minter': sp_minter, 'subs_minter': subs_minter}


def check_minters(abbreviation):
    results = []
    minters_filter = utils.contracts[abbreviation].events.MinterAdded.createFilter(
        fromBlock=1, toBlock='latest', argument_filters=None)
    minters = utils.w3.eth.getLogs(minters_filter.filter_params)
    for minter_bytes in minters:
        minter = minters_filter.format_entry(minter_bytes)
        minter_addr = minter['args']['account']
        if contracts[abbreviation].is_minter(minter_addr):
            print('{} was added as a minter.'.format(minter_addr))
            results.append(minter_addr)
        else:
            print('{} was removed as a minter.'.format(minter_addr))
    return results


def check_pausers(abbreviation):
    results = []
    pausers_filter = utils.contracts[abbreviation].events.PauserAdded.createFilter(
        fromBlock=1, toBlock='latest', argument_filters=None)
    minters = utils.w3.eth.getLogs(pausers_filter.filter_params)
    for minter_bytes in minters:
        minter = pausers_filter.format_entry(minter_bytes)
        minter_addr = minter['args']['account']
        if contracts[abbreviation].is_pauser(minter_addr):
            print('{} was added as a pauser.'.format(minter_addr))
            results.append(minter_addr)
        else:
            print('{} was removed as a pauser.'.format(minter_addr))
    return results


def start():
    for abbreviation in contracts:
        print('\nChecking {} contract roles.'.format(abbreviation))
        print('Owner: {}'.format(contracts[abbreviation].owner()))
        if abbreviation in ['sp', 'subs']:
            check_minters(abbreviation)
            check_pausers(abbreviation)


if __name__ == '__main__':
    start()
