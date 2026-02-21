#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}   DOCKSHIELD: Docker Security Auditor v1.0       ${NC}"
echo -e "${BLUE}==================================================${NC}"

if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}[!] Error: Docker is not installed.${NC}"
    exit 1
fi

containers=$(docker ps -q)

if [ -z "$containers" ]; then
    echo -e "${YELLOW}[-] No running containers found.${NC}"
    exit 0
fi

echo -e "${YELLOW}[*] Analyzing $(echo "$containers" | wc -l) running containers...${NC}"

for id in $containers; do
    name=$(docker inspect --format '{{.Name}}' "$id" | sed 's/\///')
    echo -e "\n${PURPLE}--- Container: $name ($id) ---${NC}"

    privileged=$(docker inspect --format '{{.HostConfig.Privileged}}' "$id")
    if [ "$privileged" == "true" ]; then
        echo -e "${RED}[!!!] DANGER: Container is PRIVILEGED! (Host takeover risk)${NC}"
    else
        echo -e "${GREEN}[+] Not privileged.${NC}"
    fi

    user=$(docker inspect --format '{{.Config.User}}' "$id")
    if [ -z "$user" ] || [ "$user" == "root" ] || [ "$user" == "0" ]; then
        echo -e "${YELLOW}[!] WARNING: Running as ROOT user.${NC}"
    else
        echo -e "${GREEN}[+] Running as non-root user ($user).${NC}"
    fi

    sock_mount=$(docker inspect --format '{{range .Mounts}}{{.Source}}{{end}}' "$id" | grep "docker.sock")
    if [ ! -z "$sock_mount" ]; then
        echo -e "${RED}[!!!] CRITICAL: docker.sock is mounted! (Container can escape)${NC}"
    else
        echo -e "${GREEN}[+] Docker socket not mounted.${NC}"
    fi

    mem_limit=$(docker inspect --format '{{.HostConfig.Memory}}' "$id")
    if [ "$mem_limit" == "0" ]; then
        echo -e "${YELLOW}[!] WARNING: No memory limits set (DoS risk).${NC}"
    else
        echo -e "${GREEN}[+] Memory limit: $((mem_limit / 1024 / 1024)) MB${NC}"
    fi

    net_mode=$(docker inspect --format '{{.HostConfig.NetworkMode}}' "$id")
    if [ "$net_mode" == "host" ]; then
        echo -e "${RED}[!] WARNING: Using HOST network mode.${NC}"
    else
        echo -e "${GREEN}[+] Network isolation: $net_mode${NC}"
    fi
done

echo -e "\n${BLUE}==================================================${NC}"
echo -e "${BLUE}   Audit Complete. Securing containers is key!    ${NC}"
echo -e "${BLUE}==================================================${NC}"
