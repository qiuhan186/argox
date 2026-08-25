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
    
    # 杀掉旧 xray 进程（用旧配置启动的），用新配置重启
    XRAY_PID=$(pgrep -f '/tmp/.tmp/config.json' 2>/dev/null)
    if [ -n "$XRAY_PID" ]; then
        kill "$XRAY_PID" 2>/dev/null
        sleep 1
    fi
    
    # 重新启动 xray 用新配置
    if command -v xray &>/dev/null; then
        nohup xray run -c .tmp/config.json > .tmp/xray.log 2>&1 &
        sleep 1
    elif [ -f .tmp/xray ]; then
        chmod +x .tmp/xray
        nohup .tmp/xray run -c .tmp/config.json > .tmp/xray.log 2>&1 &
        sleep 1
    fi
    
    echo ""
    echo "========== 节点链接（随机 UUID）=========="
    cat .tmp/sub.txt 2>/dev/null
fi

echo -e "\n\033[1;32m安装完成\033[0m"
echo -e "\n\033[1;32m一键卸载命令：pkill -f '\\.tmp/'\033[0m"
rm -rf 2go >/dev/null 2>&1
