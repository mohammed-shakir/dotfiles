#!/usr/bin/env bash
#
#
# Arch Linux Ultimate Maintenance Script
# Supports Wayland/Hyprland setups too.
# Usage: sudo arch_maintenance.sh [options]
#
# Options:
#   -h, --help          Show this help message
#   -a, --aggressive    Aggressive cleanup (full cache, temp files, home cache)
#   -t, --clean-trash   Empty all users' trash
#   -n, --no-aur        Skip AUR package updates
#   -y, --yes           Auto-confirm all prompts
#   -r, --reboot        Reboot after maintenance
#
# Example: sudo arch_maintenance.sh --aggressive --clean-trash --yes --reboot
#
set -euo pipefail

###─── Colours (optional) ─────────────────────────────────────────────────────###
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

###─── Parse args ──────────────────────────────────────────────────────────────###
AGGRESSIVE=false
CLEAN_TRASH=false
NO_AUR=false
AUTO_CONFIRM=false
DO_REBOOT=false

function usage() {
	cat <<EOF
Arch Linux Ultimate Maintenance

Usage: sudo $(basename "$0") [options]

Options:
  -h, --help          Show this help
  -a, --aggressive    Aggressive mode
  -t, --clean-trash   Empty users' trash
  -n, --no-aur        Skip AUR updates
  -y, --yes           Auto-confirm
  -r, --reboot        Reboot when done
EOF
	exit 0
}

while [[ $# -gt 0 ]]; do
	case $1 in
	-h | --help) usage ;;
	-a | --aggressive) AGGRESSIVE=true ;;
	-t | --clean-trash) CLEAN_TRASH=true ;;
	-n | --no-aur) NO_AUR=true ;;
	-y | --yes) AUTO_CONFIRM=true ;;
	-r | --reboot) DO_REBOOT=true ;;
	*)
		echo "Unknown option: $1"
		usage
		;;
	esac
	shift
done

###─── Sanity check ────────────────────────────────────────────────────────────###
if [[ $EUID -ne 0 ]]; then
	echo -e "${RED}⚠️  Please run as root (or via sudo).${NC}"
	exit 1
fi

function confirm() {
	[[ "$AGGRESSIVE" == true || "$AUTO_CONFIRM" == true ]] && return 0
	read -rp "$1 [y/N] " resp
	[[ "${resp,,}" =~ ^y(es)?$ ]]
}

echo -e "${CYAN}🕒 Starting Arch maintenance at $(date)${NC}"

###─── Refresh keyring ─────────────────────────────────────────────────────────###
echo -e "\n${GREEN}🔑 Refreshing pacman keyring…${NC}"
pacman -S --needed archlinux-keyring --noconfirm

###─── Firmware updates ────────────────────────────────────────────────────────###
echo -e "\n${GREEN}🔄 Updating firmware via fwupd…${NC}"
fwupdmgr refresh && fwupdmgr update -y

###─── Docker cleanup ──────────────────────────────────────────────────────────###
if command -v docker &>/dev/null; then
	echo -e "\n${GREEN}🐋 Checking Docker daemon…${NC}"
	if docker info &>/dev/null; then
		echo -e "${GREEN}✔ Docker daemon is up; pruning…${NC}"
		if docker system prune -af --volumes; then
			echo -e "${GREEN}✔ Docker prune completed.${NC}"
		else
			echo -e "${YELLOW}⚠️  Docker prune failed; skipping…${NC}"
		fi
	else
		echo -e "${YELLOW}⚠️  Docker daemon not running; skipping prune.${NC}"
	fi
fi

###─── Snapper snapshot ─────────────────────────────────────────────────────────###
if command -v snapper &>/dev/null && snapper list-configs | grep -q '^root\s'; then
	echo -e "\n${GREEN}📸 Creating btrfs snapshot via snapper…${NC}"
	snapper --config root create --description "pre-maintenance"
fi

###─── Detect AUR helper ────────────────────────────────────────────────────────###
AUR_HELPER=""
if ! $NO_AUR; then
	for h in yay paru; do
		if command -v "$h" &>/dev/null; then
			AUR_HELPER=$h
			break
		fi
	done
	if [[ -z $AUR_HELPER ]]; then
		echo -e "${YELLOW}ℹ️  No AUR helper found; skipping AUR updates.${NC}"
		NO_AUR=true
	fi
fi

###─── Backup pacman DB ────────────────────────────────────────────────────────###
echo -e "\n${GREEN}💾 Backing up pacman database…${NC}"
BACKUP_DIR="/var/lib/pacman/backup"
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/pacman-db-$(date +%F).tar.gz" -C /var/lib/pacman local

###─── Mirrorlist update ──────────────────────────────────────────────────────###
if command -v reflector &>/dev/null && confirm "Update pacman mirrorlist?"; then
	echo -e "\n${GREEN}🌐 Updating mirrorlist with reflector…${NC}"
	reflector --latest 10 --protocol https --fastest 10 --threads 10 --sort rate --save /etc/pacman.d/mirrorlist
else
	echo -e "${YELLOW}⏩ Skipping mirrorlist update.${NC}"
fi

###─── System update ───────────────────────────────────────────────────────────###
echo -e "\n${GREEN}📦 Updating system packages…${NC}"
if $AGGRESSIVE; then
	pacman -Syyu --noconfirm
else
	pacman -Syu --noconfirm
fi

if ! $NO_AUR; then
	echo -e "\n${GREEN}📦 Updating AUR packages via $AUR_HELPER…${NC}"
	sudo -u "$SUDO_USER" env HOME="/home/$SUDO_USER" TERM="$TERM" \
		"$AUR_HELPER" -Syu --noconfirm
fi

###─── Remove orphaned packages ─────────────────────────────────────────────────###
ORPHANS=$(pacman -Qtdq 2>/dev/null || true)
if [[ -n $ORPHANS ]]; then
	echo -e "\n${GREEN}🗑️  Found orphaned packages:${NC}"
	echo "$ORPHANS"
	if confirm "Remove them?"; then
		pacman -Rns --noconfirm $ORPHANS || true
	else
		echo -e "${YELLOW}⏩ Skipping orphan removal.${NC}"
	fi
else
	echo -e "${GREEN}✅ No orphaned packages found.${NC}"
fi

###─── Clean pacman cache ───────────────────────────────────────────────────────###
echo -e "\n${GREEN}🧹 Cleaning pacman cache…${NC}"
if $AGGRESSIVE; then
	pacman -Scc --noconfirm
else
	paccache -r --keep 3
fi

###─── Clean AUR helper cache ──────────────────────────────────────────────────###
if [[ -n $AUR_HELPER && -d /home/"$SUDO_USER"/.cache/"$AUR_HELPER" ]]; then
	echo -e "\n${GREEN}🧹 Cleaning $AUR_HELPER build cache…${NC}"
	su - "$SUDO_USER" -c "$AUR_HELPER -Sc --noconfirm"
fi

###─── Clean user caches ───────────────────────────────────────────────────────###
echo -e "\n${GREEN}🧹 Cleaning users' ~/.cache…${NC}"
for dir in /home/*; do
	[[ -d $dir/.cache ]] || continue
	if $AGGRESSIVE; then
		rm -rf "$dir/.cache"
	else
		rm -rf "$dir/.cache/"*
	fi

done

###─── Empty Trash ─────────────────────────────────────────────────────────────###
if $CLEAN_TRASH && confirm "Empty all users' trash?"; then
	echo -e "\n${GREEN}🗑️  Emptying Trash…${NC}"
	for td in /home/*/.local/share/Trash; do
		rm -rf "$td/files"/* "$td/info"/*
	done
	rm -rf /root/.local/share/Trash/files/* /root/.local/share/Trash/info/*
fi

###─── Journal & logs ───────────────────────────────────────────────────────────###
echo -e "\n${GREEN}📚 Vacuuming journal logs…${NC}"
journalctl --vacuum-time=2weeks
journalctl --vacuum-size=100M

###─── Update locate DB ────────────────────────────────────────────────────────###
echo -e "\n${GREEN}🔍 Updating mlocate database…${NC}"
if ! command -v updatedb &>/dev/null; then
	echo -e "${YELLOW}⚠️  'updatedb' not found, installing mlocate…${NC}"
	pacman -S --needed mlocate --noconfirm
fi
updatedb

###─── SSD TRIM ────────────────────────────────────────────────────────────────###
if confirm "Perform SSD TRIM?"; then
	echo -e "\n${GREEN}💽 Running fstrim…${NC}"
	fstrim -av
fi

###─── Clean temp files ─────────────────────────────────────────────────────────###
if $AGGRESSIVE; then
	echo -e "\n${GREEN}🧹 Removing /tmp and /var/tmp…${NC}"
	rm -rf /tmp/* /var/tmp/*
fi

echo -e "\n${CYAN}🏁 Maintenance complete at $(date)!${NC}"

if $DO_REBOOT; then
	echo -e "\n${YELLOW}🔄 Rebooting…${NC}"
	sleep 3
	reboot
fi
