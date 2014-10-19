#!/usr/bin/env bash

sudo service nginx restart
sudo killall -9 uwsgi
sudo /var/lib/procyon/bin/uwsgi --ini /var/lib/procyon/procyon.ini --py-auto-reload=3 &
echo -e "Nginx and uWSGI should have restarted\n"
