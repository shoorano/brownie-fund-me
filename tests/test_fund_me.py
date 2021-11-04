import pytest
from brownie import accounts, network, exceptions
from scripts.helpers import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy import deploy_fund_me

def test_fund():
    """tests fund method"""
    account = get_account()
    fund_me = deploy_fund_me()
    entrance_fee = fund_me.getEntranceFee()*1.1
    tx = fund_me.fund({"from": account, "amount": entrance_fee})
    tx.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == entrance_fee

def test_withdraw():
    """tests withdraw method"""
    account = get_account()
    fund_me = deploy_fund_me()
    tx_2 = fund_me.withdraw({"from": account})
    tx_2.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == 0

def test_only_owner_can_withdraw():
    """"""
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("only for local testing")
    fund_me = deploy_fund_me()
    bad_actor = accounts[1]
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withdraw({"from": bad_actor})