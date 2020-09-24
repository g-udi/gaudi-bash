# OS detection, default to OSX
case $(uname) in
    FreeBSD)   OS=FreeBSD ;;
    DragonFly) OS=FreeBSD ;;
    OpenBSD)   OS=OpenBSD ;;
    Darwin)    OS=Darwin  ;;
    SunOS)     OS=SunOS   ;;
    *)         OS=Darwin  ;;
esac

# Get current CPU load
case "$OS" in
    Linux)
        local eol
        read GAUDI_CPU_LOAD eol < /proc/loadavg
        GAUDI_CPU_COUNT=$( nproc 2>/dev/null || grep -c '^[Pp]rocessor' /proc/cpuinfo )
        ;;
    FreeBSD|Darwin|OpenBSD)
        local bol eol
        read bol GAUDI_CPU_LOAD eol <<<"$( LC_ALL=C sysctl -n vm.loadavg )"
        GAUDI_CPU_COUNT=$( sysctl -n hw.ncpu )
        GAUDI_HDD_USAGE=$( df -h | grep '/dev/' | while read -r line; do fs=$(echo $line | awk '{print $1}'); name=$(diskutil info $fs | grep 'Volume Name' | awk '{print substr($0, index($0,$3))}'); echo $(echo $line | awk '{print $2, $3, $4, $5}') $(echo $name | awk '{print substr($0, index($0,$1))}'); done | grep -vE '#{exclude}' | head -1 | cut -d ' ' -f4 )
        GAUDI_MEMORY_FREE=$( printf "%.2f" "$(bc -l <<< $(sysctl -n vm.swapusage | awk -F"free = " '{print $2}' | cut -d '.' -f 1)/1024 )")
        ;;
    SunOS)
        read GAUDI_CPU_LOAD <<<"$( LC_ALL=C uptime | sed 's/.*load average: *\([0-9.]*\).*/\1/' )"
        GAUDI_CPU_COUNT=$( kstat -m cpu_info | grep -c "module: cpu_info" )
esac
