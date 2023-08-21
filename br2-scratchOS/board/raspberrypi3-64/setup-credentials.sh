#!/usr/bin/bash -xe

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOMEDIR=$(eval echo "~`whoami`")
OWNER=$(whoami)


# Actually generate a private key
if [[ ! -f ${HOMEDIR}/.ssh/id_rsa ]]; then
	ssh-keygen -f ${HOMEDIR}/.ssh/id_rsa -t rsa -N ''
fi

# ensure that we have a public key for our RSA key and that it's authorized
ssh-keygen -f ${HOMEDIR}/.ssh/id_rsa -y > ${HOMEDIR}/.ssh/id_rsa.pub
cat ${HOMEDIR}/.ssh/id_rsa.pub >> ${HOMEDIR}/.ssh/authorized_keys


# ignore requests against github.com
# TODO: maybe...re-evaluate this
#echo -e "Host github.com\n\tStrictHostKeyChecking no\n" > ${HOMEDIR}/.ssh/config
