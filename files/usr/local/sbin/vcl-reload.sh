#!/bin/bash
# Reload a varnish config
# Author: Kristian Lyngstol

# Original version: http://kristian.blog.linpro.no/2009/02/18/easy-reloading-of-varnish-vcl/

if [ $# -lt 1 -o $# -gt 2 ]; then
  echo "Usage: $0 vcl_file [secret_file]"
  exit 1
fi
FILE=$1

if [ $# -eq 2 ]; then
  SECRET_OPT="-S $2"
fi

# Hostname and management port
# (defined in /etc/default/varnish or on startup)
HOSTPORT="localhost:6082"
NOW=`date +%F_%T`
TMPDIR=`mktemp -d`

error()
{
    echo 1>&2 "Failed to reload $FILE."
    exit 1
}
# varnishadm from 3.0.5 upstream package does some stuff as "varnish" user…
chmod 0750 $TMPDIR
chgrp varnish $TMPDIR
echo "@@@ Checking VCL file syntax:"
varnishd -d -s malloc -n "$TMPDIR" -f $FILE < /dev/null || error

rm -f "$TMPDIR/_.vsm" && rmdir "$TMPDIR"

echo -e "\n@@@ Loading new VCL file:"
varnishadm $SECRET_OPT -T $HOSTPORT vcl.load reload$NOW $FILE || error
varnishadm $SECRET_OPT -T $HOSTPORT vcl.use reload$NOW || error


echo -e "\n@@@ Currently available VCL configs:"
varnishadm $SECRET_OPT -T $HOSTPORT vcl.list

exit 0

