#!/bin/sh

BOX_NAME="$1"
duplicity --s3-use-new-style --file-to-restore=$BOX_NAME restore s3+http://cobalt-home /home
