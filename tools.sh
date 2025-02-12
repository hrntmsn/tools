#!/bin/bash
sudo apt update
sudo apt-get full-upgrade
sudo apt-get install jq

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case $(uname -m) in
    armv8\.[1-3]|arm64|armv8|aarch64) GOARCH="arm64" ;;
    armv[4-7]*)           GOARCH="armv6l" ;;
    amd64|x86_64|x64)     GOARCH="amd64" ;;
    i386|i686|386)        GOARCH="386" ;;
    *) echo "Unknown architecture"; exit 1 ;;
esac
if ! command -v go &> /dev/null; then
    VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | grep -o '^go[0-9.]*')
    wget "https://go.dev/dl/$VERSION.$OS-$GOARCH.tar.gz"
    sudo tar -C /usr/local -xzf $VERSION.$OS-$GOARCH.tar.gz
    sudo rm -rf $VERSION.$OS-$GOARCH.tar.gz
	echo "$VERSION.$OS-$GOARCH successfully installed!"
fi
if ! grep -q '/usr/local/go/bin' ~/.profile; then
cat << EOF >> ~/.profile
# Set Go PATH and environment variables
if [ -d "/usr/local/go/bin" ]; then
    export GOARCH=$GOARCH
    export GOOS=$OS
    export PATH=\$PATH:/usr/local/go/bin
    export GOPATH=\$HOME/go
    export GOROOT=/usr/local/go
fi
EOF
fi
case $(uname -m) in
    armv8\.[1-3]|arm64|armv8|aarch64) NJARCH="arm64" ;;
    armv[4-7]*)           NJARCH="armv7l" ;;
    amd64|x86_64|x64)     NJARCH="x64" ;;
    *) echo "Unknown architecture"; exit 1 ;;
esac
if ! command -v go &> /dev/null; then
    VERSION=$(curl -s 'https://nodejs.org/download/release/index.json' | jq -r '.[0].version')
    wget "https://nodejs.org/download/release/$VERSION/node-$VERSION-linux-$NJARCH.tar.gz"
    sudo tar -xzf node-$VERSION-linux-$NJARCH.tar.gz
    sudo rm -rf node-$VERSION-linux-$NJARCH.tar.gz
    sudo sudo mv node-$VERSION-linux-$NJARCH /usr/local/
	echo "node-$VERSION-linux-$NJARCH successfully installed!"
fi
if ! grep -q '/usr/local/node-v23.5.0-linux-arm64/bin' ~/.profile; then
cat << EOF >> ~/.profile

# Set NodeJS PATH and environment variables
if [ -d "/usr/local/node-v23.5.0-linux-arm64/bin" ]; then
    export PATH=$PATH:/usr/local/node-v23.5.0-linux-arm64/bin
fi
EOF
fi
case $(uname -m) in
    armv8\.[1-3]|arm64|armv8|aarch64) VSARCH="arm64" ;;
    armv[4-7]*)           VSARCH="armhf" ;;
    amd64|x86_64|x64)     VSARCH="x64" ;;
    *) echo "Unknown architecture"; exit 1 ;;
esac
if ! command -v code &> /dev/null; then
    VERSION=$(curl -s https://update.code.visualstudio.com/api/releases/stable | jq -r '.[0]')
	if [[ "$OS" == "linux" ]]; then
    	if grep -q "ID=debian" /etc/os-release; then
            wget https://update.code.visualstudio.com/$VERSION/linux-deb-$VSARCH/stable -O vscode$VERSION.linux-deb-$VSARCH.deb
            sudo apt install ./vscode$VERSION.linux-deb-$VSARCH.deb && sudo rm -rf vscode$VERSION.linux-deb-$VSARCH.deb
		    echo "vscode$VERSION.linux-deb-arm64 successfully installed!"
	    else
	        echo "Distro doesn't support"
	    fi
	else
	echo "Karnel doesn't support"
    fi
fi
source ~/.profile
source ~/.bashrc