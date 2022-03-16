#!/bin/bash
sudo apt update && sudo apt upgrade -y

sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu -y

cd $HOME
ver="1.17.2"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node
git checkout v0.2.0
make install

celestia version

TRUSTED_SERVER="164.68.122.127:26657"
TRUSTED_SERVER="http://$TRUSTED_SERVER"
echo $TRUSTED_SERVER

# init
celestia bridge init --core.remote $TRUSTED_SERVER

# config 
sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-bridge/config.toml

BootstrapPeers="[\"/dns4/andromeda.celestia-devops.dev/ip4/164.68.122.127/tcp/2121/p2p/12D3KooWCYsJUr1PfdAv9cbgDngTVYCPJj51yVqrG65Zj8gzdSnE\", \"/dns4/libra.celestia-devops.dev/ip4/164.68.122.127/tcp/2121/p2p/12D3KooWCYsJUr1PfdAv9cbgDngTVYCPJj51yVqrG65Zj8gzdSnE\", \"/dns4/norma.celestia-devops.dev/ip4/164.68.122.127/tcp/2121/p2p/12D3KooWCYsJUr1PfdAv9cbgDngTVYCPJj51yVqrG65Zj8gzdSnE\"]"

sed -i -e "s|BootstrapPeers *=.*|BootstrapPeers = $BootstrapPeers|" $HOME/.celestia-bridge/config.toml

sudo tee /etc/systemd/system/celestia-bridge.service > /dev/null <<EOF
[Unit]
  Description=celestia-bridge
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$HOME/go/bin/celestia bridge start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-bridge
sudo systemctl daemon-reload

sudo systemctl restart celestia-bridge && journalctl -u celestia-bridge -o cat -f


