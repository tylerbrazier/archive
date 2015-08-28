#!/bin/bash
set -e -u

finish() {
  echo "$1"
  echo "Press [Enter] to close"
  read
}

trap 'finish "Error in Setup"' ERR

clear  # clear git MOTD

cd "$(dirname "$0")"

iso="${HOME}/.boot2docker/boot2docker.iso"
ssh_id="${HOME}/.ssh/id_boot2docker"
zk_build="$(pwd)/zookeeper_build"    # dir with zk Dockerfile & resources
kafka_build="$(pwd)/kafka_build"     # dir with kafka Dockerfile & resources

echo "Loading configuration.txt..."
source ./configuration.txt
echo


# Replace each '$key' from configuration.txt in *_build/xyz.template with its
# associated 'value' in xyz.
echo "Configuring Dockerfiles and configs for zookeeper and kafka..."
keys=()
lines=$(grep -v '^\s*#' configuration.txt)    # read each noncomment from conf
while IFS= read -r l; do keys+=("${l%=*}"); done <<<"$lines"  # load key names
for f in "$zk_build"/*.template "$kafka_build"/*.template; do
  # Running $out thru sed in for loop like this is not efficient but whatever
  out="$(cat "$f")"
  for k in ${keys[@]}; do
    value=$(eval "echo \${$k}")
    # the 3 following chars need to be escaped for sed: \ / &
    # http://stackoverflow.com/questions/407523
    value=${value//\\/\\\\}      #  \  =>  \\
    value=${value//\//\\\/}      #  /  =>  \/
    value=${value//&/\\&}        #  &  =>  \&
    out="$(echo "$out" | sed 's/\$'"$k"'/'"$value"'/g')"
  done
  echo "Writing from template to ${f%.template}"
  echo "$out" > "${f%.template}"
done
echo


echo "Running stop.sh..."
./stop.sh


# this portion has been taken from the start.sh script in provided by b2d
echo 'Initializing the VM...'
pushd "$b2d_dir" >/dev/null
if [ ! -e "$iso" ]; then
  echo 'Copying initial boot2docker.iso'
  mkdir -p "$(dirname "$iso")"
  cp ./boot2docker.iso "$iso"
fi
./boot2docker.exe init
popd >/dev/null
echo


echo "Creating shared folders on host if needed..."
mkdir -p "$zk_host_data" "$kafka_host_data"
echo

echo "Setting up shared folders on the host. Note that this only needs to be"
echo "set up once; some errors will be thrown if the shared folder has already"
echo "been set up - this is normal."
pushd "$vbox_dir" >/dev/null
if ./VBoxManage.exe sharedfolder add boot2docker-vm \
  --name "$zk_share" \
  --hostpath "$zk_host_data" \
  --automount
then
  echo "Successfully created the shared folder $zk_host_data"
fi
if ./VBoxManage.exe sharedfolder add boot2docker-vm \
  --name "$kafka_share" \
  --hostpath "$kafka_host_data" \
  --automount
then
  echo "Successfully created the shared folder $kafka_host_data"
fi
popd >/dev/null
echo


echo "Starting the VM..."
pushd "$b2d_dir" >/dev/null
./boot2docker.exe start >/dev/null
echo

# We need to create mount points and mount shared folders on boot but
# boot2docker runs completely from RAM. However, b2d mounts a persistent
# directory at /var/lib/boot2docker and if a bootlocal.sh script is found in
# that dir, it will be executed on boot. We can use this to create the mount
# points and mount the shared folders.
echo "Setting up shared folders on the guest via bootlocal.sh..."
cmd='
bootlocal=/var/lib/boot2docker/bootlocal.sh

sudo sh -c "cat > $bootlocal" <<EOF
#!/bin/sh
# https://github.com/boot2docker/boot2docker/blob/v1.3.2/doc/FAQ.md
set -e

[ ! -d '"$zk_b2d_data"' ] && mkdir -p '"$zk_b2d_data"'
chown -R docker '"$zk_b2d_data"'
mount -t vboxsf -o uid=1000,gid=50 '"$zk_share $zk_b2d_data"'

[ ! -d '"$kafka_b2d_data"' ] && mkdir -p '"$kafka_b2d_data"'
chown -R docker '"$kafka_b2d_data"'
mount -t vboxsf -o uid=1000,gid=50 '"$kafka_share $kafka_b2d_data"'
EOF

sudo chmod +x $bootlocal   # make it executable
sudo $bootlocal            # execute it
'
./boot2docker.exe ssh "$cmd"
popd >/dev/null
echo


echo "Copying resources for building the images..."
pushd "$b2d_dir" >/dev/null
# no StrictHostKeyChecking so we don't get prompts
scp -r -oStrictHostKeyChecking=no -i "$ssh_id" "$zk_build" "$kafka_build" \
  docker@$(./boot2docker.exe ip 2>/dev/null):/tmp
popd >/dev/null
echo


echo "Building images..."
zk_dest="/tmp/$(basename "$zk_build")"
kafka_dest="/tmp/$(basename "$kafka_build")"
cmd='
docker images | grep '\'"$zk_image"'\s*'"$zk_tag"\'' >/dev/null \
  && echo "'"${zk_image}:${zk_tag}"' already exists; skipping" \
  || docker build -t '"${zk_image}:${zk_tag} $zk_dest"'

docker images | grep '\'"$kafka_image"'\s*'"$kafka_tag"\'' >/dev/null \
  && echo "'"${kafka_image}:${kafka_tag}"' already exists; skipping" \
  || docker build -t '"${kafka_image}:${kafka_tag} $kafka_dest"'
'
pushd "$b2d_dir" >/dev/null
./boot2docker.exe ssh "$cmd"
popd >/dev/null
echo


echo "Running start.sh..."
./start.sh


finish 'Setup finished successfully'
