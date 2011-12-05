# Mpd sublet file
# Created with sur-0.1
require "socket"

# Class Pointer {{{
class Pointer
  attr_accessor :value

  def initialize(value = nil)
    @value = value
  end

  def to_s
    value.to_s
  end
end # }}}

# Class Mpd {{{
class Mpd
  # Mpd state
  attr_accessor :state

  # Mpd options
  attr_accessor :repeat
  attr_accessor :random
  attr_accessor :database

  # Mpd socket
  attr_accessor :socket

  # Mpd current song
  attr_accessor :current_song

  ## initialize {{{
  # Create a new mpd object
  # @param [String]  host      Hostname
  # @param [Fixnum]  port      Port
  # @param [String]  password  Password
  ##

  def initialize(host, port, password = nil)
    @host         = host
    @port         = port
    @password     = password
    @socket       = nil
    @state        = :off
    @repeat       = false
    @random       = false
    @database     = false
    @current_song = {}
  end # }}}

  ## connect {{{
  # Open connection to mpd
  # @return [Bool] Whether connection succeed
  ##

  def connect
    begin
      @socket = TCPSocket.new(@host, @port)

      # Handle SIGPIPE
      trap "PIPE" do
        @socket = nil
        disconnect
      end

      # Wait for mpd header
      safe_read(1)

      # Send password if any
      unless(@password.nil?)
        safe_write("password #{@password}")
        return false unless(get_ok(1))
      end

      parse_status
      parse_current
      idle
    rescue Errno::ECONNREFUSED
      puts "mpd not running"
    rescue
    end

    !@socket.nil?
  end # }}}

  ## disconnect {{{
  # Send close and shutdown
  ###

  def disconnect
    safe_write("close") unless(@socket.nil?)

    @socket = nil
    @state  = :off
  end # }}}

  ## action # {{{
  # Send action to mpd
  # @param [String]  command  Mpd action
  ##

  def action(command)
    noidle
    safe_write(command)
  end # }}}

  ## update {{{
  # Update mpd
  # @return [Bool] Whether update was successful
  ##

  def update
    get_ok(1)
    parse_status
    parse_current
    idle

    !@socket.nil?
  end # }}}

  private

  ## safe_read {{{
  # Read data from socket
  # @param [Fixnum]  timeout  Timeout in seconds
  # @return [String] Read data
  ##

  def safe_read(timeout = 0)
    line = ""

    unless(@socket.nil?)
      begin
        sets = select([ @socket ], nil, nil, timeout)
        line = @socket.readline unless(sets.nil?) #< No nil is a socket hit
      rescue EOFError
        puts "mpd read: EOF"
        @socket = nil
        disconnect
      rescue
        disconnect
      end
    end

    line
  end # }}}

  ## safe_write {{{
  # Write dats to socket
  # @param [String]  str  String to write
  ##

  def safe_write(str)
    return if(str.nil? or str.empty?)

    unless(@socket.nil?)
      begin
        @socket.write("%s\n" % [ str ])
      rescue
        disconnect
      end
    end
  end # }}}

  ## idle {{{
  # Send idle command
  ##

  def idle
    safe_write("idle player options update") unless(@socket.nil?)
  end # }}}

  ## noidle {{{
  # Send noidle command
  ###

  def noidle
    safe_write("noidle")
    get_ok(1)
  end # }}}

  ## get_ok {{{
  # Get ok or error
  # @param [Fixnum]  timeout  Timeout in seconds
  # @return [Bool] Whether mpd return ok
  ##

  def get_ok(timeout = 0)
    unless(@socket.nil?)
      line = safe_read(timeout)
      line = safe_read(timeout) if(line.match(/^changed/)) #< Skip changed message

      # Check result
      if(line.match(/^OK/))
        true
      elsif((match = line.match(/^ACK \[(.*)\] \{(.*)\} (.*)/)))
        disconnect

        # Probably non-recoverable
        puts "mpd %s error: %s" % [ match[2], match[3] ]

        false
      end
    end
  end # }}}

  ## get_reply {{{
  # Send command and return reply as hash
  # @oaran [String]  command  Command to send
  # return [Hash] Data hash
  ###

  def get_reply(command)
    hash = {}

    unless(@socket.nil?)
      begin
        safe_write(command)

        while
          line = safe_read(1)

          # Check response
          if(line.match(/^OK/))
            break
          elsif((match = line.match(/^ACK \[(.*)\] \{(.*)\} (.*)/)))
            disconnect

            # Probably non-recoverable
            puts "mpd %s error: %s" % [ match[2], match[3] ]

            raise #< Exit loop
          elsif((match = line.match(/^(\w+): (.+)$/)))
            hash[match[1].downcase] = match[2]
          end
        end
      rescue
        hash = {}
      end
    end

    hash
  end # }}}

  ## parse_status {{{
  # Parse mpd status
  ###

  def parse_status
    unless(@socket.nil?)
      status = get_reply("status")

      # Convert state
      @state = case status["state"]
        when "play"  then :play
        when "pause" then :pause
        when "stop"  then :stop
        else :off
      end

      # Set modes
      @repeat   = (0 == status["repeat"].to_i) ? false : true
      @random   = (0 == status["random"].to_i) ? false : true
      @database = !status["updating_db"].nil?
    end
  end # }}}

  ## parse_current {{{
  # Parse mpd current song
  ##

  def parse_current
    unless(@socket.nil?)
      @current_song = get_reply("currentsong") 
    else
      @current_song = {}
    end
  end # }}}
end # }}}

configure :mpd do |s| # {{{
  # Icons
  s.icons = {
    :play     => Subtlext::Icon.new("play.xbm"),
    :pause    => Subtlext::Icon.new("pause.xbm"),
    :stop     => Subtlext::Icon.new("stop.xbm"),
    :prev     => Subtlext::Icon.new("prev.xbm"),
    :next     => Subtlext::Icon.new("next.xbm"),
    :note     => Subtlext::Icon.new("note.xbm"),
    :repeat   => Subtlext::Icon.new("repeat.xbm"),
    :random   => Subtlext::Icon.new("shuffle.xbm"),
    :database => Subtlext::Icon.new("diskette.xbm")
  }

  # Options
  s.def_action     = s.config[:def_action]
  s.wheel_up       = s.config[:wheel_up]
  s.wheel_down     = s.config[:wheel_down]
  s.format_string  = s.config[:format_string] || "%note%%artist% - %title%"

  # Sanitize actions
  valid = [ "play", "pause 0", "pause 1", "stop", "previous", "next", "stop" ]

  s.def_action = "next"     unless(valid.include?(s.def_action))
  s.wheel_up   = "next"     unless(valid.include?(s.wheel_up))
  s.wheel_down = "previous" unless(valid.include?(s.wheel_down))

  # Parse format string once
  fields = [ "%note%", "%artist%", "%album%", "%title%", "%track%", "%id%" ]

  s.format_values = {}

  s.format_string.gsub!(/%[^%]+%/) do |f|
    if(fields.include?(f))
      name = f.delete("%")

      if("%note%" == f)
        format_values[name] = self.icons[:note]
      else
        format_values[name] = Pointer.new
      end

      "%s"
    else
      ""
    end
  end

  # Create mpd object
  host, password = (s.config[:host] || ENV["MPD_HOST"] || "localhost").split("@")
  port           = s.config[:port]  || ENV["MPD_PORT"] || 6600

  s.mpd = Mpd.new(host, port, password)

  watch(s.mpd.socket) if(s.mpd.connect)

  update_status
end # }}}

helper do |s| # {{{
  def update_status # {{{
    mesg  = "mpd not running"
    modes = ""
    icon  = :play

    unless(self.mpd.socket.nil?)
      if(:play == self.mpd.state or :pause == self.mpd.state)
        # Select icon
        icon = case self.mpd.state
          when :play  then :pause
          when :pause then :play
        end

        # Sanity?
        self.format_values.each do |k, v|
          if(self.mpd.current_song.include?(k))
            self.format_values[k].value = self.mpd.current_song[k] || "n/a"
          end
        end

        # Modes
        modes << self.icons[:repeat]   if(self.mpd.repeat)
        modes << self.icons[:random]   if(self.mpd.random)
        modes << self.icons[:database] if(self.mpd.database)
        modes = " %s" % [ modes ] unless(modes.empty?)

        # Assemble format
        mesg = self.format_string % self.format_values.values
      elsif(:stop == self.mpd.state)
        mesg = "mpd stopped"
        icon = :play
      end
    end

    self.data = "%s%s%s%s%s %s" % [
      self.icons[icon], self.icons[:stop],
      self.icons[:prev], self.icons[:next],
      modes, mesg
    ]

  end # }}}
end # }}}

on :mouse_down do |s, x, y, b| # {{{
  if(s.mpd.socket.nil?)
    watch(s.mpd.socket) if(s.mpd.connect)
    update_status
  else
    # Send to socket
    s.mpd.action(
      case b
        when 1
          case x
            when 2..17
              case s.mpd.state
                when :stop  then "play"
                when :pause then "pause 0"
                when :play  then "pause 1"
              end
            when 18..33 then "stop"
            when 34..49 then "previous"
            when 50..65 then "next"
            else s.def_action
          end
        when 4 then s.wheel_up
        when 5 then s.wheel_down
      end
    )
  end
end # }}}

on :watch do |s| # {{{
  unwatch unless(s.mpd.update)
  update_status
end # }}}
