#!/usr/bin/env bash

# Install and configure 2 factor authentication for ssh logins.
# You'll still need to run google-authenticator as your normal user.
# https://wiki.archlinux.org/index.php/Google_Authenticator

set -e

fail() {
  echo "$1" >&2; exit 1
}

[ $(id -u) -eq 0 ] || fail 'run as root'

if ! command -v google-authenticator >/dev/null 2>&1; then
  fail 'install libpam-google-authenticator first'
fi

echo 'Starting and enabling sshd'
systemctl start sshd || fail 'make sure openssh server is installed'
systemctl enable sshd


file=/etc/pam.d/sshd
pattern='^auth[[:space:]]*required[[:space:]]*pam_google_authenticator.so'
text='auth  required  pam_google_authenticator.so'
if ! grep -q "$pattern" "$file"; then
  echo "Prepending '$text' to $file"
  sed -i "1i${text}" "$file"  # insert on line 1
fi


file=/etc/ssh/sshd_config
pattern='^#* *ChallengeResponseAuthentication.*'
text='ChallengeResponseAuthentication yes'
if grep -q "$pattern" "$file"; then
  echo "Setting '$text' in $file"
  sed -i "s/${pattern}/${text}/g" "$file"
else
  echo "Appending '$text' to $file"
  printf "\n# for 2 factor auth\n${text}\n" >> "$file"
fi

pattern='^#* *PasswordAuthentication.*'
text='PasswordAuthentication no'
if grep -q "$pattern" "$file"; then
  echo "Setting '$text' in $file"
  sed -i "s/${pattern}/${text}/g" "$file"
else
  echo "Appending '$text' to $file"
  echo "${text}" >> "$file"
fi

echo "Reloading sshd"
systemctl reload sshd


echo "Remember to run google-authenticator as your normal user"
