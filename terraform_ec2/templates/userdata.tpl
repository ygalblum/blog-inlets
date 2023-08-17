#!/bin/bash
export AUTHTOKEN="${token}"
export IP=$(curl -sfSL https://checkip.amazonaws.com)

curl -SLsf https://github.com/inlets/inlets-pro/releases/download/${inlets_version}/inlets-pro -o /tmp/inlets-pro && \
  chmod +x /tmp/inlets-pro  && \
  mv /tmp/inlets-pro /usr/local/bin/inlets-pro && \
  chcon -u system_u -r object_r -t bin_t  /usr/local/bin/inlets-pro

curl -SLsf https://github.com/inlets/inlets-pro/releases/download/${inlets_version}/inlets-pro-http.service -o inlets-pro.service && \
  mv inlets-pro.service /etc/systemd/system/inlets-pro.service && \
  chcon -u system_u -r object_r -t systemd_unit_file_t  /etc/systemd/system/inlets-pro.service && \
  echo "AUTHTOKEN=$AUTHTOKEN" >> /etc/default/inlets-pro && \
  echo "IP=$IP" >> /etc/default/inlets-pro && \
  echo "DOMAINS=--letsencrypt-domain=${domain}" >> /etc/default/inlets-pro && \
  echo "ISSUER=--letsencrypt-issuer=${lets_encrypt_issuer}" >> /etc/default/inlets-pro && \
  echo "EMAIL=--letsencrypt-email=${lets_encrypt_email}" >> /etc/default/inlets-pro && \
  systemctl daemon-reload && \
  systemctl enable --now inlets-pro
