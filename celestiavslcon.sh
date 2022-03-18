#!/bin/bash

curl -s localhost:26657/status

celestia-appd q bank balances $CELESTIA_ADDR

echo $CELESTIA_NODENAME $CELESTIA_CHAIN $CELESTIA_WALLET

celestia-appd tx staking create-validator \
 --amount=1050000celes \
 --pubkey=$(celestia-appd tendermint show-validator) \
 --moniker=$CELESTIA_NODENAME \
 --chain-id=$CELESTIA_CHAIN \
 --commission-rate=0.1 \
 --commission-max-rate=0.2 \
 --commission-max-change-rate=0.01 \
 --min-self-delegation=1000000 \
 --from=$CELESTIA_WALLET

celestia-appd q staking validator $CELESTIA_VALOPER

celestia-appd q staking validators --limit=3000 -oj \
 | jq -r '.validators[] | select(.status=="BOND_STATUS_BONDED") | [(.tokens|tonumber / pow(10;6)), .description.moniker] | @csv' \
 | column -t -s"," | tr -d '"'| sort -k1 -n -r | nl
