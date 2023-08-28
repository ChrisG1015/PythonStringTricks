prefix=$(echo "$url" | sed -n 's|\(https://.*amazon\.aws\.com\).*|\1|p')
suffix=$(echo "$url" | sed -n 's|https://.*amazon\.aws\.com\(/out/.*\)|\1|p')
