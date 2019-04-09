#!/bin/bash
set -e

# Customized installation and setup script to be run on a fresh ubuntu server.
# Edit the configuration variables below and run the script as root.

### configuration:
superuser=somebody
packages=(
man
htop
iptables
openssh-server
openssh-client
libpam-google-authenticator
nodejs-legacy  # legacy package includes /usr/bin/node symlink
npm
)
### end configuration


apt-get update
apt-get install "${packages[@]}"

cd "$(dirname "$0")"  # make sure we're executing from ubuntu/ dir

# setup iptables and enable them to be loaded on boot
../any/iptables.sh
mkdir -p /etc/network/if-pre-up.d
printf '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables/iptables.rules\n' \
  > /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables

# allow members of 'sudo' group to run sudo without a password
if grep -q '^#* *%sudo' /etc/sudoers; then
  sed -i 's/^#* *%sudo.*/%sudo ALL=\(ALL\) NOPASSWD: ALL/' /etc/sudoers
else
  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

# Run any/2fa.sh, stripping out the line that enables sshd; this command
# currently fails on ubuntu 16.04. Ubuntu enables the service when the package
# is installed anyway. The issue appears to be fixed in systemd v231:
# https://github.com/systemd/systemd/issues/3010
sed '/systemctl enable sshd/d' ../any/2fa.sh | bash -

# create a swapfile of size 2x system memory if it doesn't exist
if grep -q '^[^#].*\s.\+\sswap' /etc/fstab; then
  echo 'swap entry exists in /etc/fstab; skipping swap setup'
elif [ -e /swapfile ]; then
  echo '/swapfile already exists; skipping'
else
  mem="$(grep MemTotal /proc/meminfo | awk '{print $2}')" # in KB
  size="$(($mem * 2))K"
  echo "creating /swapfile of size $size"
  fallocate -l "$size" /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile	none	swap	defaults	0	0" >> /etc/fstab
fi

# add superuser if he doesn't already exist
if ! id -u "$superuser" >/dev/null 2>&1; then
  useradd -m -g users -G sudo -s /bin/bash "$superuser"
  echo "Added user $superuser"
  passwd "$superuser"
fi

# run commands as superuser
sudo -u "$superuser" -i -H bash -c '
if [ ! -d ~/linux ]; then
  git clone https://github.com/tylerbrazier/linux.git ~/linux

  # generate ssh key pair and upload the public key to github, DO, etc.
  ~/linux/any/keygen.sh

  cd ~/linux
  git remote set-url origin git@github.com:tylerbrazier/linux.git
fi

if [ ! -d ~/dotfiles ]; then
  git clone https://github.com/tylerbrazier/dotfiles.git ~/dotfiles
  ~/dotfiles/install.sh -f -p

  cd ~/dotfiles
  git remote set-url origin git@github.com:tylerbrazier/dotfiles.git
fi

[ -f ~/.google_authenticator ] || google-authenticator
'

echo 'done'
