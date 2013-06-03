#!/bin/sh

BOX_NAME="$1"
SERVER="$2"
#duplicity --s3-use-new-style --file-to-restore=$BOX_NAME restore s3+http://cobalt-home /home/$BOX_NAME
rsync --archive --verbose -e 'ssh -i /tmp/something'  root@${SERVER}:/home/$BOX_NAME/ /home/$BOX_NAME
