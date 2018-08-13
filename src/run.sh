#!/bin/bash

/usr/local/bin/init.sh 
/usr/local/bin/goaccess.sh

exec /usr/bin/supervisord -n
