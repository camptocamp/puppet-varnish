#!/bin/bash
# Reload a varnish config
# Author: Kristian Lyngstol

# Original version: http://kristian.blog.linpro.no/2009/02/18/easy-reloading-of-varnish-vcl/

if [ $# -ne 1 ]; then
  echo "Usage: $0 vcl_file"
  exit 1
fi

FILE=$1

# Hostname and management port
# (defined in /etc/default/varnish or on startup)
HOSTPORT="localhost:6082"
NOW=`date +%F_%T`

error()
{
    echo 1>&2 "Failed to reload $FILE."
    exit 1
}

varnishadm -T $HOSTPORT vcl.load reload$NOW $FILE || error
varnishadm -T $HOSTPORT vcl.use reload$NOW || error
echo Current configs:
varnishadm -T $HOSTPORT vcl.list

exit 0

