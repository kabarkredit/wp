#!/bin/bash

# Dapatkan IP publik
public_ip=$(curl -s http://ifconfig.co)

# Cloudflare API credentials
zone_id="dc2c089d4d91e4386398886cfd2f3142"
record_id="7f97b7e04a4ef7e4944ac51dd22d8a4e"  # Ganti dengan ID rekaman yang diperoleh dari langkah sebelumnya
api_token="eOaBwLelOxI1vf9PcE7ae8OCVaqHYeuNjQGapdB9"
record_name="www.sxmjn.biz.id"  # Ganti dengan nama rekaman yang sesuai

# Fungsi untuk memperbarui rekaman DNS di Cloudflare
update_dns() {
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
        -H "Authorization: Bearer $api_token" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"'$record_name'","content":"'$public_ip'","ttl":120,"proxied":false}'
}

# Tampilkan informasi sistem menggunakan landscape-sysinfo
landscape_info=$(landscape-sysinfo)

# Tampilkan informasi sistem dan IP publik
echo "$landscape_info"
echo "Public IP: $public_ip"

# Perbarui DNS
update_dns
