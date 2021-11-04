from brownie import FundMe, config, network
from scripts.helpers import get_account, get_eth_price_feed_address

def deploy_fund_me():
    """basic deployer method"""
    account = get_account()
    price_feed_address = get_eth_price_feed_address()
    return FundMe.deploy(price_feed_address, {"from": account}, publish_source=config["networks"][network.show_active()].get("verify"))

def main():
    """runs deployment method"""
    deploy_fund_me()