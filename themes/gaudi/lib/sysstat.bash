###############
# OS specific #
###############

# OS detection, default to OSX
case $(uname) in
    FreeBSD)   OS=FreeBSD ;;
    DragonFly) OS=FreeBSD ;;
    OpenBSD)   OS=OpenBSD ;;
    Darwin)    OS=Darwin  ;;
    SunOS)     OS=SunOS   ;;
    *)         OS=Darwin   ;;
esac

# Get cpu count
case "$OS" in
    Linux)   GAUDI_CPU_COUNT=$( nproc 2>/dev/null || grep -c '^[Pp]rocessor' /proc/cpuinfo ) ;;
    FreeBSD|Darwin|OpenBSD) GAUDI_CPU_COUNT=$( sysctl -n hw.ncpu ) ;;
    SunOS)   GAUDI_CPU_COUNT=$( kstat -m cpu_info | grep -c "module: cpu_info" ) ;;
esac

# Get current CPU load
case "$OS" in
    Linux)
        _cpu_load () {
            local eol
            read GAUDI_CPU_LOAD eol < /proc/loadavg
        }
        ;;
    FreeBSD|Darwin|OpenBSD)
        _cpu_load () {
            local bol eol
            # If you have problems with syntax coloring due to the following
            # line, do this: ln -s liquidprompt liquidprompt.bash
            # and edit liquidprompt.bash
            read bol GAUDI_CPU_LOAD eol <<<"$( LC_ALL=C sysctl -n vm.loadavg )"
        }
        ;;
    SunOS)
        _cpu_load () {
            read GAUDI_CPU_LOAD <<<"$( LC_ALL=C uptime | sed 's/.*load average: *\([0-9.]*\).*/\1/' )"
        }
esac