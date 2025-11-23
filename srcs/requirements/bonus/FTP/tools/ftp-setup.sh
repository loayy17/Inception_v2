#!/bin/bash

# 1) validate FTP environment variables
ftp_env=("$FTP_USER" "$FTP_PASSWORD")
for var in "${ftp_env[@]}"; do
	if [ -z "$var" ]; then
		echo "Error: One or more required environment variables are not set."
		exit 1
	fi
done

# Create nologin shell entry if missing
grep -qxF "/usr/sbin/nologin" /etc/shells || echo "/usr/sbin/nologin" >> /etc/shells

# Create secure chroot dir (mandatory)
mkdir -p /var/run/vsftpd/empty

# Create FTP user if not exists
if ! id "$FTP_USER" >/dev/null 2>&1; then
  useradd -m -d /home/$FTP_USER -s /usr/sbin/nologin $FTP_USER
  echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

# Ensure WordPress folder exists
mkdir -p /var/www/html
chown -R $FTP_USER:$FTP_USER /var/www/html

# Minimal vsftpd.conf inline
cat <<EOF >/etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
pam_service_name=vsftpd
seccomp_sandbox=NO
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40010
chroot_local_user=YES
allow_writeable_chroot=YES
local_root=/var/www/html
secure_chroot_dir=/var/run/vsftpd/empty
EOF

# Start vsftpd
exec /usr/sbin/vsftpd /etc/vsftpd.conf
