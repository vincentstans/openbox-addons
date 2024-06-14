# Tang server port change
mkdir -p /etc/systemd/system/tangd.socket.d/

echo -ne "[Socket]\nListenStream=\nListenStream=8080\n" > /etc/systemd/system/tangd.socket.d/port.conf
systemctl daemon-reload

# Encrypt with 2 tang servers both needed to decrypt
clevis luks bind -d /dev/sdXn sss '{"t":2,"pins":{"tang":[{"url":"http://192.168.145.10"},{"url":"http://www.public.tld"}]}}'

# Encrypt with 1 server can add multiple servers just 1 needs to be online requires 1 luks slot each
clevis luks bind -d /dev/sda5 tang '{"url":"http://192.168.145.10"}'

clevis luks bind -d /dev/sda5 tang '{"url":"http://www.public.tld"}'

# Combine above 2 commands like so requires 1 luke slot
clevis luks bind -d /dev/sda5 sss '{"t":1,"pins":{"tang":[{"url":"http://192.168.145.10"},{"url":"http://www.public.tld"}]}}'

# Repack folder "preseed-iso/" for VM preseed debian
xorriso -as mkisofs -o preseed.iso \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
        -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot \
        -boot-load-size 4 -boot-info-table preseed-iso/

# SHA256SUM check one liner no output is ok.
diff <( curl -s https://www.domain.tld/file.tar.gz -o file.tar.gz; sha256sum file.tar.gz ) <( curl -s https://www.domain.tld/file.tar.gz.sha256sum )
