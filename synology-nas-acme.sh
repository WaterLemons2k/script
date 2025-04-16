#!/bin/bash

# Usage: `curl -LO https://github.com/WaterLemons2k/Shell/raw/main/synology-nas-acme.sh && ./synology-nas-acme.sh`
# Based on https://github.com/acmesh-official/acme.sh/wiki/Synology-NAS-Guide
set -euo pipefail

VER=1.0.2
NAME="synology-nas-acme.sh"
ACME_HOME="/usr/local/share/acme.sh"

_log() {
  echo "[$NAME] $1"
}

# Running command as root
as_root() {
  if [ "$(whoami)" != "root" ]; then
    _log "Not root! Try running \`$1\` as root."
  fi

  sudo -E su -c "$1"
  exit
}

# Whether the current user is root. If not, try running as root.
is_root() {
  if [ "$(whoami)" != "root" ]; then
    as_root "bash $0"
  fi
}

# Defines env if it is not defined.
define_env() {
  local _env=$1
  local _msg=$2

  if [ -z "${!_env:-}" ]; then
    read -rp "$_msg" value
    export "$_env"="$value"
  fi
}

# Installation of acme.sh
# https://github.com/acmesh-official/acme.sh/wiki/Synology-NAS-Guide#installation-of-acmesh
install() {
  cd ~
  wget -O master.tar.gz https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
  tar xvf master.tar.gz
  cd acme.sh-master/

  define_env "ACME_EMAIL" "Input the email used in \`acme.sh --accountemail\`: "

  sudo ./acme.sh --install --nocron --home "$ACME_HOME" --accountemail "$ACME_EMAIL"

  cd ..
  rm -r acme.sh-master/ master.tar.gz
}

# Install acme.sh if 'ACME_HOME' is not exists.
ensure_acme_installed() {
  if [ ! -d "$ACME_HOME" ]; then
    _log "acme.sh not found, installing..."
    install
    return
  fi
}

# ensure that the current path is set to the 'ACME_HOME' path.
set_current_path_to_ACME_HOME() {
  if [ "$PWD" != "$ACME_HOME" ]; then
    cd "$ACME_HOME"
  fi
}

# ensure that 'CERT_DOMAIN' is defined.
define_CERT_DOMAIN() {
  define_env "CERT_DOMAIN" "Input the domain used in the acme.sh certificate domain: "
}

# Create the certificate
# https://github.com/acmesh-official/acme.sh/wiki/Synology-NAS-Guide#creating-the-certificate
# Now, the server 'letsencrypt' and dns 'dns_cf' are used by default.
create() {
  set_current_path_to_ACME_HOME
  define_CERT_DOMAIN

  define_env "CF_Token" "Input the CloudFlare API token used as the \`CF_Token\` env: "
  define_env "CF_Email" "Input the CloudFlare email used as the \`CF_Email\` env: "

  CERT_DNS=dns_cf
  ./acme.sh --issue --server letsencrypt --home . -d "$CERT_DOMAIN" --dns "$CERT_DNS"
}

# Deploy the default certificate
# https://github.com/acmesh-official/acme.sh/wiki/Synology-NAS-Guide#deploy-the-default-certificate
deploy() {
  set_current_path_to_ACME_HOME
  define_CERT_DOMAIN


  SYNO_CREATE=1 SYNO_USE_TEMP_ADMIN=1 ./acme.sh --deploy --insecure --home . -d "$CERT_DOMAIN" --deploy-hook synology_dsm
}

cron() {
  as_root "$ACME_HOME/acme.sh --cron --home $ACME_HOME"
}

_done() {
  _log "All done! Please refer to
https://github.com/acmesh-official/acme.sh/wiki/Synology-NAS-Guide#configuring-certificate-renewal
or run \`bash $CURRENT_DIR/$0 cron\` as root to configure certificate renewal."
}

# https://github.com/acmesh-official/acme.sh/blob/0da839cce35f4ab014a6d62133fac03c8f4c6979/acme.sh#L6713
version() {
  _log "v$VER"
}

# https://github.com/acmesh-official/acme.sh/blob/0da839cce35f4ab014a6d62133fac03c8f4c6979/acme.sh#L6843
help() {
  version
  echo "Usage: $NAME <command>
Commands:
  cron                   Run cron job to renew all the certs."
}

main() {
  CURRENT_DIR=$PWD

  # Do not install acme.sh in the `sudo su` shell!
  # It may cause this script exit prematurely.
  ensure_acme_installed

  if is_root; then
    create
    deploy
  fi

  _done
}

# If the script is not passed only one argument, run the main function.
if [ $# -ne 1 ]; then
  main
  exit
fi

$1
