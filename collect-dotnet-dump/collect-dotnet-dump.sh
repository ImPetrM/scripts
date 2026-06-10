#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <container_id_or_name> <dump_name>"
    echo "Example: $0 my-super-service service-dump"
    exit 1
fi

CONTAINER="$1"
DUMP_NAME="$2"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FINAL_NAME="${DUMP_NAME}_${TIMESTAMP}.dmp"

DOTNET_DUMP="${HOME}/.dotnet/tools/dotnet-dump"

cleanup_container_dump() {
    if [ -n "${PID:-}" ]; then
        sudo rm -f "/proc/$PID/root/tmp/$FINAL_NAME" 2>/dev/null || true
    fi
}

PID=$(docker inspect -f '{{.State.Pid}}' "$CONTAINER")

if [ -z "$PID" ] || [ "$PID" = "0" ]; then
    echo "Container '$CONTAINER' is not running or PID not found."
    exit 1
fi

echo "---"
echo "Container: $CONTAINER"
echo "Host PID:  $PID"
echo "Output:    $FINAL_NAME"
echo "---"
echo

echo "Collecting dump..."

sudo TMPDIR="/proc/$PID/root/tmp" \
"$DOTNET_DUMP" collect \
-p 1 \
-o "/tmp/$FINAL_NAME"

trap cleanup_container_dump EXIT

echo "Copying dump..."

sudo cp "/proc/$PID/root/tmp/$FINAL_NAME" "./$FINAL_NAME"

echo "Changing ownership..."

sudo chown "$USER:$USER" "./$FINAL_NAME"

echo "Removing temporary dump from container..."

cleanup_container_dump
trap - EXIT

echo "Finished."
ls -lh "./$FINAL_NAME"
