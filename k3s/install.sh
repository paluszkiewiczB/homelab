#!/bin/bash

function enable_legacy_iptables() {
  # https://rancher.com/docs/k3s/latest/en/advanced/#enabling-legacy-iptables-on-raspbian-buster

  ipt_path="/usr/sbin/iptables-legacy"
  ipt6_path="/usr/sbin/ip6tables-legacy"

  curr_ipt=$(update-alternatives --get-selections | grep iptables | awk '{print $3}')
  curr_ipt6=$(update-alternatives --get-selections | grep ip6tables | awk '{print $3}')

  if [ "$ipt_path" == "$curr_ipt" ] && [ "$ipt6_path" == "$curr_ipt6" ]; then
    echo "legacy iptables were already enabled"
    return 0
  fi

  echo "enabling legacy iptables"
  sudo iptables -F
  sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
  sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
}

function enable_cgroups() {
  # https://rancher.com/docs/k3s/latest/en/advanced/#enabling-cgroups-for-raspbian-buster
  mem="cgroup_memory=1"
  enable="cgroup_enable=memory"
  cmdline_path="/boot/cmdline.txt"
  grep -e "$mem" -e "$enable" $cmdline_path

  if [ "$?" == "1" ]; then
    echo "enabling cgroups"
    echo -n " $mem $enable" >>$cmdline_path
  else
    echo "cgroups were already enabled"
  fi
}

function install_k3s() {
  # https://rancher.com/docs/k3s/latest/en/installation/install-options/#options-for-installation-with-script
  export INSTALL_K3S_VERSION=v1.23.3+k3s1
  export INSTALL_K3S_CHANNEL=stable
  export K3S_KUBECONFIG_MODE="644"
  export INSTALL_K3S_EXEC=" --no-deploy servicelb --no-deploy traefik"

  curl -sfL https://get.k3s.io | sh -
  sudo cat /var/lib/rancher/k3s/server/node-token
}

function main() {
  enable_legacy_iptables
  enable_cgroups
  install_k3s
}
