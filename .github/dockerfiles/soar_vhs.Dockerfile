# syntax=docker/dockerfile:1
#SELF: https://raw.githubusercontent.com/Azathothas/soar/refs/heads/main/.github/dockerfiles/soar_vhs.Dockerfile
FROM ghcr.io/charmbracelet/vhs:latest
#Allows to pass -e | --env="OUT_DIR=$VALUE" otherwise sets /soar as default
ARG OUT_DIR="/soar"
ENV LOCAL_PATH="${OUT_DIR}"
#------------------------------------------------------------------------------------#
##Base Deps
RUN <<EOS
  ##Base Deps
  set +e
  export DEBIAN_FRONTEND="noninteractive"
  echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
  packages="apt-transport-https apt-utils autopoint bash bison ca-certificates coreutils curl dos2unix fdupes file findutils fish gettext git gnupg2 gperf imagemagick jq locales locate moreutils nano ncdu p7zip-full rename rsync software-properties-common texinfo sudo tmux unzip util-linux xz-utils wget zip"
  apt-get update -y -qq
  for pkg in $packages; do DEBIAN_FRONTEND="noninteractive" apt install -y --ignore-missing "$pkg"; done
  #NetTools
  packages="dnsutils inetutils-ftp inetutils-ftpd inetutils-inetd inetutils-ping inetutils-syslogd inetutils-tools inetutils-traceroute iproute2 net-tools netcat-traditional"
  for pkg in $packages; do DEBIAN_FRONTEND="noninteractive" apt install -y --ignore-missing "$pkg"; done
  packages="iputils-arping iputils-clockdiff iputils-ping iputils-tracepath iproute2"
  for pkg in $packages; do DEBIAN_FRONTEND="noninteractive" apt install -y --ignore-missing "$pkg"; done
  setcap 'cap_net_raw+ep' "$(which ping)"
EOS
#------------------------------------------------------------------------------------#
##User & Home
RUN <<EOS
  #Setup User
  set +e
  useradd --create-home "soar"
  echo "soar:soar" | chpasswd
  usermod -aG "sudo" "soar"
  usermod -aG "sudo" "root"
  echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> "/etc/sudoers"
  userdel -r "admin" 2>/dev/null || true
  usermod --shell "/bin/bash" "soar" 2>/dev/null
EOS
#------------------------------------------------------------------------------------#
##Prep ENV
RUN <<EOS
 #Prep ENV
  set +e
 #Configure ENV
  curl -qfsSL "https://raw.githubusercontent.com/pkgforge/devscripts/refs/heads/main/Linux/.bashrc" -o "/etc/bash.bashrc"
  ln -svf "/etc/bash.bashrc" "/root/.bashrc" 2>/dev/null || true
  ln -svf "/etc/bash.bashrc" "/home/soar/.bashrc" 2>/dev/null || true
  ln -svf "/etc/bash.bashrc" "/etc/bash/bashrc" 2>/dev/null || true
  #Prep LOCAL_PATH 
  rm -rvf "${LOCAL_PATH}" 2>/dev/null || true
  mkdir -pv "${LOCAL_PATH}"
  chown -R "soar:soar" "${LOCAL_PATH}"
  chmod -R 755 "${LOCAL_PATH}"
 #Soar
  curl -qfsSL "https://github.com/pkgforge/soar/releases/download/nightly/soar-$(uname -m)-linux" -o "/usr/bin/soar"
  chmod +x "/usr/bin/soar"
 #Sanity Check
  if [ ! -f "/usr/bin/soar" ] || [ "$(stat -c %s "/usr/bin/soar")" -le 1000 ]; then
     echo "Soar Wasn't Installed Properly"
     exit 1
  fi
 #Extras
  curl -qfsSL "https://bin.pkgforge.dev/$(uname -m)/7z" -o "/usr/bin/7z"
  curl -qfsSL "https://bin.pkgforge.dev/$(uname -m)/chafa" -o "/usr/bin/chafa"
  curl -qfsSL "https://bin.pkgforge.dev/$(uname -m)/croc" -o "/usr/bin/croc"
  curl -qfsSL "https://bin.pkgforge.dev/$(uname -m)/eget" -o "/usr/bin/eget"
  curl -qfsSL "https://bin.pkgforge.dev/$(uname -m)/micro" -o "/usr/bin/micro"
  curl -qfsSL "https://bin.pkgforge.dev/$(uname -m)/rsync" -o "/usr/bin/rsync"
  chmod -v +x "/usr/bin/7z" "/usr/bin/chafa" "/usr/bin/croc" "/usr/bin/eget" "/usr/bin/micro" "/usr/bin/rsync" || true
EOS
#------------------------------------------------------------------------------------#
#Start
RUN <<EOS
 #Locale
  echo "LC_ALL=en_US.UTF-8" | tee -a "/etc/environment"
  echo "en_US.UTF-8 UTF-8" | tee -a "/etc/locale.gen"
  echo "LANG=en_US.UTF-8" | tee -a "/etc/locale.conf"
  locale-gen "en_US.UTF-8"
 #Dialog
  echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections
  debconf-show debconf 
EOS
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
WORKDIR /soar
#VHS has vhs itself as entrypoint
ENTRYPOINT []
#------------------------------------------------------------------------------------#
