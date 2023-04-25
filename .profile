export TERMINAL=alacritty

export clean_path="$PATH"

if [ -d "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi

export PATH="$HOME/.local/bin/:$PATH"
export PATH="$PATH:/opt/microchip/xc16/v2.00/bin"
export PATH="$PATH:/opt/microchip/xc32/v4.10/bin"
export PATH="$PATH:/opt/microchip/xc8/v2.40/bin"
