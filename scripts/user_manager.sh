#!/usr/bin/env bash
set -euo pipefail

usage() { echo "Usage: $0 <users.csv>"; exit 1; }
[[ $# -ne 1 ]] && usage

csv="$1"
[[ ! -f "$csv" ]] && { echo "CSV not found: $csv" >&2; exit 1; }

while IFS=, read -r username action; do
	[[ "$username" == "username" ]] && continue
	[[ -z "$username" ]] && continue
	
	case "$action" in
		create)
			if id "$username" &>/dev/null; then
				echo "User $username already exists"
			else
				sudo useradd -m "$username"
				echo "User $username was created"
			fi
			;;
		delete)
			if id "$username" &>/dev/null; then
				sudo userdel -r "$username"
				echo "User $username was deleted"
			else
				echo "User $username not found"
			fi
			;;
		*)
			echo "Unknown action '$action' for $username" >&2
			;;
	esac
done < "$csv"
