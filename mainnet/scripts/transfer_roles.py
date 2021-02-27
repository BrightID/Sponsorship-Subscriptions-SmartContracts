from contracts import subs_minter
from contracts import sp_minter
from contracts import config
from contracts import subs
from contracts import sp

contracts = {'sp': sp, 'subs': subs,
             'sp_minter': sp_minter, 'subs_minter': subs_minter}


def transfer_minter_role(abbreviation):
    print('Add {} as new minter'.format(config.AGENT_ADDR))
    add_res = contracts[abbreviation].add_minter(
        config.DEPLOYER_PK, config.AGENT_ADDR)
    print(add_res)
    print('Renounce deployer minter role.')
    rm_res = contracts[abbreviation].remove_minter(config.DEPLOYER_PK)
    print(rm_res)


def transfer_pauser_role(abbreviation):
    print('Add {} as new pauser'.format(config.AGENT_ADDR))
    add_res = contracts[abbreviation].add_pauser(
        config.DEPLOYER_PK, config.AGENT_ADDR)
    print(add_res)
    print('Renounce deployer pauser role.')
    rm_res = contracts[abbreviation].remove_pauser(config.DEPLOYER_PK)
    print(rm_res)


def transfer_owner_role(abbreviation):
    print('Transfe ownership to {}'.format(config.AGENT_ADDR))
    res = contracts[abbreviation].transfer_ownership(
        config.DEPLOYER_PK, config.AGENT_ADDR)
    print(res)


def start():
    for abbreviation in contracts:
        print('\nTransfer roles: {} contract'.format(abbreviation))
        if abbreviation in ['sp', 'subs']:
            transfer_minter_role(abbreviation)
            transfer_pauser_role(abbreviation)
        transfer_owner_role(abbreviation)


if __name__ == '__main__':
    start()
