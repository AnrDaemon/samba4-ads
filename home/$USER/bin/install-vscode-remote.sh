#!/bin/sh

if [ "$1" ]; then
    commit="$1"
else
    read -p 'Enter VS Code commit hash (Help -> About): ' commit
fi

[ "$commit" ] && (
    set -e
    if [ -d "$HOME/.vscode-server/bin/$commit" ] ; then
        echo "VS Code server commit:$commit already installed."
        exit
    fi

    curl -sL "https://update.code.visualstudio.com/commit:$commit/server-linux-x64/stable" | \
        tar -C "$HOME" -xz --transform "s#^vscode-server-linux-x64/#.vscode-server/bin/$commit/#"
    echo "VS Code server commit:$commit installed."
)
