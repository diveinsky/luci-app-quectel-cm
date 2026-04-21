#!/bin/sh

REGISTRY_FILE="/etc/luci-useradmin.users"

ensure_registry_file() {
    [ -f "$REGISTRY_FILE" ] || touch "$REGISTRY_FILE" 2>/dev/null || true
}

register_user() {
    local username="$1"

    ensure_registry_file

    grep -Fx "$username" "$REGISTRY_FILE" >/dev/null 2>&1 || echo "$username" >> "$REGISTRY_FILE" 2>/dev/null || true
}

unregister_user() {
    local username="$1"

    ensure_registry_file
    grep -Fxv "$username" "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" 2>/dev/null || true
    mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE" 2>/dev/null || true
}

list_users() {
    local rpcd_dump
    local users

    rpcd_dump="$(uci show rpcd 2>/dev/null)"
    ensure_registry_file

    users="$(cat "$REGISTRY_FILE" 2>/dev/null)"

    if [ -z "$users" ]; then
        users="$(awk -F: '$6 ~ "^/home/" && $7 == "/bin/false" { print $1 }' /etc/passwd)"
    fi

    printf '%s\n' "$users" | while read -r user; do
        [ -n "$user" ] || continue

        if printf '%s\n' "$rpcd_dump" | grep -F "username='$user'" >/dev/null 2>&1; then
            printf '%s\t%s\n' "$user" "yes"
        else
            printf '%s\t%s\n' "$user" "no"
        fi
    done
}

delete_user() {
    local username="$1"
    local section_id

    if [ -z "$username" ]; then
        echo "Usage: $0 --delete <username>"
        exit 1
    fi

    section_id="login_$(printf '%s' "$username" | tr -c 'A-Za-z0-9_' '_')"

    if grep -q "^${username}:" /etc/passwd; then
        userdel "$username" || exit 1
        echo "Linux user deleted"
    else
        echo "Linux user not found"
    fi

    unregister_user "$username"

    uci -q delete "rpcd.${section_id}"
    uci commit rpcd || exit 1

    echo "LuCI user '${username}' deleted successfully"
    echo "Restart rpcd to apply LuCI login changes"
}

create_user() {
    local username="$1"
    local password="$2"
    local section_id

    if [ -z "$username" ] || [ -z "$password" ]; then
        echo "Usage: $0 <username> <password>"
        exit 1
    fi

    if ! grep -q "^${username}:" /etc/passwd; then
        useradd -M -s /bin/false "$username" || exit 1
        echo "${username}:${password}" | chpasswd || exit 1
        echo "Linux user created"
    else
        echo "Linux user already exists"
    fi

    register_user "$username"

    section_id="login_$(printf '%s' "$username" | tr -c 'A-Za-z0-9_' '_')"

    uci -q delete "rpcd.${section_id}"
    uci set "rpcd.${section_id}=login"
    uci set "rpcd.${section_id}.username=${username}"
    uci set "rpcd.${section_id}.password=\$p\$${username}"
    uci add_list "rpcd.${section_id}.read=*"
    uci add_list "rpcd.${section_id}.write=*"
    uci commit rpcd || exit 1

    echo "LuCI user '${username}' added successfully"
    echo "Shell disabled, LuCI login enabled after rpcd restart"
}

case "$1" in
    --list)
        list_users
        ;;
    --create-async)
        shift
        ( create_user "$1" "$2" ) >/tmp/luci-useradmin.last 2>&1 &
        echo "User creation started"
        ;;
    --delete)
        delete_user "$2"
        ;;
    --delete-async)
        shift
        ( delete_user "$1" ) >/tmp/luci-useradmin.last 2>&1 &
        echo "User deletion started"
        ;;
    *)
        create_user "$1" "$2"
        ;;
esac
