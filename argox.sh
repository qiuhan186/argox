#!/bin/bash

rm -rf 2go >/dev/null 2>&1

ARCH=$(uname -m)
case $ARCH in
    "aarch64" | "arm64" | "arm")
        ARCH="arm64"
        ;;
    "x86_64" | "amd64" | "x86")
        ARCH="amd64"
        ;;
    "s390x" | "s390")
        ARCH="s390x"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

command -v curl &>/dev/null && COMMAND="curl -sLo" || command -v wget &>/dev/null && COMMAND="wget -qO" || { echo "Error: neither curl nor wget found, please install one of them." >&2; exit 1; }

$COMMAND 2go "https://qiuhan186.github.io/argox/argox"

chmod +x 2go && ./2go

OLD_UUID="fdeeda45-0a8e-4570-bcc6-d68c995f5830"
NEW_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || echo "$(date +%s)-$$-$(hostname)" | md5sum | cut -d' ' -f1 | sed 's/\([0-9a-f]\{8\}\)/\1-/; s/\([0-9a-f-]\{13\}\)\([0-9a-f]\{4\}\)/\1\2-/; s/\([0-9a-f-]\{18\}\)\([0-9a-f]\{4\}\)/\1\2-/; s/\([0-9a-f-]\{23\}\)\([0-9a-f]\{12\}\)/\1\2/' | head -c 36)

if [ -n "$NEW_UUID" ]; then
    echo "[argox] 生成随机 UUID: $NEW_UUID"
    
    if [ -f .tmp/config.json ]; then
        sed -i "s/$OLD_UUID/$NEW_UUID/g" .tmp/config.json
    fi
    
    if [ -f .tmp/sub.txt ]; then
        sed -i "s/$OLD_UUID/$NEW_UUID/g" .tmp/sub.txt
    fi
    
    echo ""
    echo "========== 节点链接（已替换为随机 UUID）=========="
    cat .tmp/sub.txt 2>/dev/null
fi

echo -e "\n\033[1;32m安装完成\033[0m"
echo -e "\n\033[1;32m一键卸载命令：pkill -f '\\.tmp/'\033[0m"
rm -rf 2go >/dev/null 2>&1
