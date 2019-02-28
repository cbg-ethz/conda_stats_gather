
Installing on RedHat 7
----------------------

Inside ETHZ network, the server is accessible at :

 - <http://bs-bewi08.ethz.ch/>

`production-server` is the branch currently deployed on the server

    sudo setfacl --modify='g:bsse-beerenwinkel:rwx' /opt
    sudo git clone --shared --branch production-server git@github.com:DrYak/conda_stats_gather.git
    cd conda_stats_gather

### Dependencies

RH7 has out dated Perl and Python. Luckily SCL (software Collection) makes it possible to install more modern stacks

    sudo yum install texlive-latex-bin-bin  texlive-pdfpages texlive-pdftex-def texlive-ifluatex texlive-collection-fontsrecommended
    sudo yum install rh-perl526-perl
    sudo yum install rh-python36 rh-python36-python-six rh-python36-numpy rh-python36-scipy rh-python36-python-pip rh-python36-python-setuptools
    scl enable rh-python36 -- sudo pip3 install matplotlib pandas seaborn
    
    wget -O- http://www2.warwick.ac.uk/fac/sci/statistics/staff/academic/firth/software/pdfjam/pdfjam_latest.tgz | tar xzC /opt
    sudo ln -sf /opt/pdfjam/bin/pdfjam /usr/local/bin/
    
    scl enable rh-python36 -- scl enable rh-perl526 -- make

### Installing services

    sudo systemctl link /opt/conda_stats_gather/conda_stats_gather.service
    sudo systemctl link /opt/conda_stats_gather/conda_stats_gather.timer
    sudo systemctl link /opt/conda_stats_gather/make_pdf.service
    sudo systemctl link /opt/conda_stats_gather/make_pdf.timer
    sudo systemctl daemon-reload
    sudo systemctl enable conda_stats_gather.service
    sudo systemctl enable /opt/conda_stats_gather/conda_stats_gather.timer
    sudo systemctl start conda_stats_gather.timer
    sudo systemctl enable /opt/conda_stats_gather/make_pdf.timer
    sudo systemctl start make_pdf.timer
    systemctl list-timers -a

### Webserver

Note there is a [bug](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=471388) in the default RedHat lighttpd configuration.
(As the logs will tell you: *use `server.use-ipv6` only for hostnames, not without server.bind / empty address)

    sudo yum install lighttpd
    sudo sed -i -r s@^(server.use-ipv6.*)$@#\1@g';s@^#(include.*vhosts\.d.*)$@\1@g' /etc/lighttpd/lighttpd.conf
    sudo ln -s /opt/conda_stats_gather/stats.lighttpd.conf /etc/lighttpd/vhosts.d/90-stats.conf
    sudo systemctl restart lighttpd.service
    sudo systemctl status lighttpd.service
    
### Firewall

`/etc/sysconfig/iptables` needs the following extra rules :

    -A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
    -A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT

Then:

    sudo systemctl reload iptables.service
    sudo /sbin/iptables -L
