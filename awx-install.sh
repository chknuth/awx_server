#! /bin/bash
#
# AWX Installation nach https://awx.wiki/installation/section-one/subsection-two
#
# Vorbereitungen
echo "Vorbereitungen"
sudo yum -y install policycoreutils-python
sudo semanage port -a -t http_port_t -p tcp 8050
sudo semanage port -a -t http_port_t -p tcp 8051
sudo semanage port -a -t http_port_t -p tcp 8052
sudo setsebool -P httpd_can_network_connect 1

# firewall unter Centos image nicht scharf, daher Zeilen als Kommentar
# sudo systemctl stop firewalld
# sudo systemctl disable firewalld

# Repo zum Herunterladen von AWX vorbereiten
echo "Repositories einrichten"
sudo yum -y install epel-release # bereits installiert
sudo yum -y install centos-release-scl centos-release-scl-rh
sudo yum install -y wget
sudo wget -O /etc/yum.repos.d/ansible-awx.repo https://copr.fedorainfracloud.org/coprs/mrmeee/ansible-awx/repo/epel-7/mrmeee-ansible-awx-epel-7.repo

sudo echo "[bintraybintray-rabbitmq-rpm] 
name=bintray-rabbitmq-rpm 
baseurl=https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/v3.7.x/el/7/
gpgcheck=0 
repo_gpgcheck=0 
enabled=1" > rabbitmq.repo

sudo mv rabbitmq.repo /etc/yum.repos.d/

echo "[bintraybintray-rabbitmq-erlang-rpm] 
name=bintray-rabbitmq-erlang-rpm 
baseurl=https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/21/el/7/
gpgcheck=0 
repo_gpgcheck=0 
enabled=1" > rabbitmq-erlang.repo
sudo mv rabbitmq-erlang.repo /etc/yum.repos.d/

# Install RabbitMQ
echo "RabbitMQ installieren"
sudo yum -y install rabbitmq-server

# Install GIT
echo "GIT installieren"
sudo yum -y install rh-git29

# Install PostgreSQL and memcached
echor "PostgreSQL installieren"
sudo yum install -y rh-postgresql10 memcached

# Install NGINX
echo "NGINX installieren"
sudo yum -y install nginx

# Install Python dependecies (needs cleaning, probably too much)
# CentOS
echo "Python Zusatz installieren"
sudo yum -y install rh-python36
sudo yum -y install --disablerepo='*' --enablerepo='copr:copr.fedorainfracloud.org:mrmeee:ansible-awx, base' -x *-debuginfo rh-python36*

# Install AWX-RPM:
echo "AWX installieren"
sudo yum install -y ansible-awx

#
# Configurations
#
# Initialize DB
echo "DB konfigurieren"
cd /tmp
sudo scl enable rh-postgresql10 "postgresql-setup initdb"

# Start services: Postgresql Database
sudo systemctl start rh-postgresql10-postgresql.service

# Start services: RabbitMQ
sudo systemctl start rabbitmq-server

# Create Postgres user and DB:
cd /tmp
sudo scl enable rh-postgresql10 "su postgres -c \"createuser -S awx\""
sudo scl enable rh-postgresql10 "su postgres -c \"createdb -O awx awx\""

# Import Database data:
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage migrate"

# Initial configuration of AWX
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'root@localhost', 'password')" | sudo -u awx scl enable rh-python36 rh-postgresql10 "GIT_PYTHON_REFRESH=quiet awx-manage shell"
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage create_preload_data" # Optional Sample Configuration
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage provision_instance --hostname=$(hostname)"
sudo -u awx scl enable rh-python36 rh-postgresql10 rh-git29 "GIT_PYTHON_REFRESH=quiet awx-manage register_queue --queuename=tower --hostnames=$(hostname)"

# Configure NGINX as proxy:
sudo wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/MrMEEE/awx-build/master/nginx.conf

# Start Services
sudo systemctl start awx

# Enable Services
sudo systemctl enable awx

