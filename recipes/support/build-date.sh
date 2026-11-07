#!/bin/sh
# Format SOURCE_DATE_EPOCH with either GNU or BSD date.
if [ -z "${SOURCE_DATE_EPOCH:-}" ]; then
    exec date "$@"
fi

case "$SOURCE_DATE_EPOCH" in
    *[!0-9]*)
        echo "SOURCE_DATE_EPOCH must be a nonnegative integer" >&2
        exit 1
        ;;
esac

export LC_ALL=C TZ=UTC
if [ "$#" -eq 0 ]; then
    set -- '+%a %b %e %H:%M:%S UTC %Y'
fi

if date -u -d "@$SOURCE_DATE_EPOCH" "$@" 2>/dev/null; then
    exit 0
fi
exec date -u -r "$SOURCE_DATE_EPOCH" "$@"
