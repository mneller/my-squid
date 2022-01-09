#!/bin/ash
# from Chris H <chris@trash.co.nz>
# Source: https://github.com/kiwichrish/alpine_squid
set -e
# Means exit shell when a command fails (non-zero exit status)

# find chown and squid, just in case
CHOWN=$(/usr/bin/which chown)
SQUID=$(/usr/bin/which squid)

# Set permissions correctly on the Squid cache and log when loaded as a volumes
echo "=========== fixing cache dir permissions"
"$CHOWN" -R squid:squid /squid
"$CHOWN" -R squid:squid /var/log/squid

echo "=========== Check config location"
FILE=/etc/squid/squid.conf
if [ -f "$FILE" ]; then
    echo "=========== Config is there, do nothing"
else
    echo "=========== Config not found, assuming defaults"
    cp /etc/squid.dist/* /etc/squid
fi

# Prepare the cache using Squid.
echo "=========== Initialize cache"
"$SQUID" -z

echo "=========== Sleep a bit"
# Give the Squid cache some time to rebuild.
sleep 5

# Launch squid
echo "Starting Squid..."
exec "$SQUID" -NYCd 1
# -N Prevents Squid from becoming a background daemon process.
# -Y Returns ICP_MISS_NOFETCH instead of ICP_MISS when rebuilding store metadata.
#     For busy parent caches, this option may result in less load while the cache is rebuilding. See Section 10.6.1.2.
# -C Prevents the installation of signal handlers that trap certain fatal signals such as SIGBUS and SIGSEGV.
#    Normally, the signals are trapped by Squid so that it can attempt a clean shutdown. However, trapping the signal
#    may make it harder to debug the problem afterwards.
#    With this option, the fatal signals cause their default actions, which is usually to dump core.
# -d Makes Squid write its debugging messages to stderr (as well as cache.log and syslog, if configured).
#    The level argument specifies the maximum level for messages that should be shown on stderr.
#    In most cases -d1 works well. See Section 16.2 for a description of debugging levels