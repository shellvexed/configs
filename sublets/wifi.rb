# Wifi sublet file
# Created with sur-0.1
require "socket"

# Copied from wireless.h
SIOCGIWESSID      = 0x8B1B
IW_ESSID_MAX_SIZE = 32

configure :wifi do |s| # {{{
  s.interval = 240
  s.icon     = Subtlext::Icon.new("wifi_01.xbm")
  s.device   = s.config[:device] || "wlan0"
end # }}}

on :run do |s| # {{{
  # Get data
  wireless = IO.readlines("/proc/net/wireless", "r").join

  link, level, noise = wireless.scan(/#{s.device}:\s*\d*\s*([0-9-]+).\s+([0-9-]+).\s+([0-9-]+)/).flatten

  # Get essid
  # removed - ETW
  #sock = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM, 0)

  #template = "a16pI2"
  #iwessid  = [ s.device, " " * IW_ESSID_MAX_SIZE, IW_ESSID_MAX_SIZE, 1 ].pack(template)

  #sock.ioctl(SIOCGIWESSID, iwessid)

  #interface, essid, len, flags = iwessid.unpack(template)
  # ETW

  link = (7000 / link.to_i).round rescue 0
  #s.data = "%s%s (%d/100)" % [ s.icon, essid.strip, link ]
  s.data = s.icon + link.to_s + "%"
end # }}}
