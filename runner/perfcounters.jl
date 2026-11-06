# Hardware and software performance counters for the calling thread (Linux perf_event_open),
# which are much less sensitive to other load on the machine than wall time. Instructions
# in particular measure compile and interpreter work almost independently of contention;
# cycles, cache and branch misses, context switches and page faults say why time differs.
#
# `PerfCounters()` opens them, or returns `nothing` where they can't be opened (not Linux,
# no permission); `read_counters(pc)` gives the counts so far, scaled up where the kernel had
# to multiplex the hardware counters.
module PerfCounters

export open_counters, read_counters, counter_names

const PERF_TYPE_HARDWARE = UInt32(0)
const PERF_TYPE_SOFTWARE = UInt32(1)
# (name, type, config, user mode only)
const EVENTS = (
    ("instructions", PERF_TYPE_HARDWARE, 1, true),
    ("cycles", PERF_TYPE_HARDWARE, 0, true),
    ("cache_misses", PERF_TYPE_HARDWARE, 3, true),
    ("branch_misses", PERF_TYPE_HARDWARE, 5, true),
    ("ctx_switches", PERF_TYPE_SOFTWARE, 3, false),
    ("page_faults", PERF_TYPE_SOFTWARE, 2, false),
)
counter_names() = map(first, EVENTS)

const SYS_perf_event_open = Sys.ARCH === :x86_64 ? 298 : Sys.ARCH === :aarch64 ? 241 : -1
const READ_FORMAT = UInt64(1 | 2)  # TOTAL_TIME_ENABLED | TOTAL_TIME_RUNNING

function open_event(type::UInt32, config::Integer, user_only::Bool)
    attr = zeros(UInt8, 128)  # struct perf_event_attr, PERF_ATTR_SIZE_VER7
    p = pointer(attr)
    GC.@preserve attr begin
        unsafe_store!(Ptr{UInt32}(p), type)
        unsafe_store!(Ptr{UInt32}(p + 4), UInt32(128))
        unsafe_store!(Ptr{UInt64}(p + 8), UInt64(config))
        unsafe_store!(Ptr{UInt64}(p + 32), READ_FORMAT)
        # flags: exclude_kernel (bit 5) and exclude_hv (bit 6) for user mode only
        unsafe_store!(Ptr{UInt64}(p + 40), user_only ? UInt64(1 << 5 | 1 << 6) : UInt64(0))
        # this thread, any CPU, no group, no flags
        fd = ccall(:syscall, Clong, (Clong, Ptr{UInt8}, Cint, Cint, Cint, Culong),
                   SYS_perf_event_open, p, 0, -1, -1, 0)
    end
    return Int(fd)
end

struct Counters
    fds::Vector{Int}
end

function open_counters()
    Sys.islinux() && SYS_perf_event_open > 0 || return nothing
    fds = Int[]
    for (_, type, config, user) in EVENTS
        fd = open_event(type, config, user)
        if fd < 0
            foreach(f -> ccall(:close, Cint, (Cint,), f), fds)
            return nothing
        end
        push!(fds, fd)
    end
    return Counters(fds)
end

function read_counters(pc::Counters)
    buf = zeros(UInt64, 3)  # value, time enabled, time running
    out = Vector{Float64}(undef, length(pc.fds))
    for (i, fd) in enumerate(pc.fds)
        n = ccall(:read, Cssize_t, (Cint, Ptr{UInt64}, Csize_t), fd, buf, sizeof(buf))
        out[i] = n != sizeof(buf) ? NaN : buf[3] == 0 ? 0.0 :
            buf[1] * (buf[3] == buf[2] ? 1.0 : buf[2] / buf[3])
    end
    return out
end

end
