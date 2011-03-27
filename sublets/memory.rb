# Memory sublet file
# Created with sur-0.1
configure :memory do |s|
  s.interval = 30
end

on :run do |s|
  file = ""

  begin
    File.open("/proc/meminfo", "r") do |f|
      file = f.read
    end

    # Collect data
    total   = file.match(/MemTotal:\s*(\d+)\s*kB/)[1].to_i || 0
    free    = file.match(/MemFree:\s*(\d+)\s*kB/)[1].to_i || 0
    buffers = file.match(/Buffers:\s*(\d+)\s*kB/)[1].to_i || 0
    cached  = file.match(/Cached:\s*(\d+)\s*kB/)[1].to_i || 0

    used    = (total - (free + buffers + cached)) / 1024
    total   = total / 1024
    percent = (used * 100 / total).round rescue 0

    s.icon = Subtlext::Icon.new("memory.xbm")
    s.data = s.icon + percent.to_s + "%"
    # s.data = used.to_s + "/" + total.to_s
  rescue => err # Sanitize to prevent unloading
    s.data = "subtle"
    p err
  end
end
