#!/bin/bash

projectdir=$(cd $(dirname $0); pwd)    # directory this script is in
installer=${projectdir}/install        # the name of installer file
preinstall=${projectdir}/preinstall    # name of file with preinstall commands
postinstall=${projectdir}/postinstall  # name of file with postinstall commands
payload=${projectdir}/payload          # the directory of payload files
work=${projectdir}/work                # working directory for this script

# make a clean working directory
rm -rf ${work}
mkdir -p ${work}
cd ${work}

# archive the payload, following links instead of archiving them
mkdir -p ${payload}
tar --dereference -czf payload.tar.gz -C ${payload} .

# build the installer file
cat > ${installer} <<INSTALLER
#!/bin/bash

$([[ -f ${preinstall} ]] && cat ${preinstall})

echo "Extracting payload to \$(pwd)"
(openssl base64 -d | tar -zxf -) <<PAYLOAD
$(openssl base64 < payload.tar.gz)
PAYLOAD

$([[ -f ${postinstall} ]] && cat ${postinstall})
INSTALLER

# make it executable
chmod 0754 ${installer}
