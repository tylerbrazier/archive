set -e
cd "$(dirname "$0")"  # always execute from android/ dir

packages=(
vim
curl
man
openssh
)

apt-get -y install "${packages[@]}"

# download dotfiles from github
url="https://raw.githubusercontent.com/tylerbrazier/dotfiles/master/"
for f in bashrc gitconfig; do
  curl -L -s -o "$HOME/.$f" "${url}${f}"
done

# busybox grep doesn't support colors so remove the --color alias
sed -i '/alias grep.*color/d' ~/.bashrc

echo 'nnoremap q :x<cr>' > ~/.vimrc

echo 'source ~/.bashrc' > ~/.bash_profile

# disable vibrate
mkdir -p ~/.config/termux
echo 'bell-character=ignore' > ~/.config/termux/termux.properties

mkdir -p ~/.shortcuts
for f in shortcuts/*; do
  ln -sf "$(realpath "$f")" "$HOME/.shortcuts/$(basename "$f")"
done

bash ../any/keygen.sh

echo 'done'
