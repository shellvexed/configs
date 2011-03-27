# Temp sublet file
# Created with sur-0.1

# Hwmon class
class Hwmon # {{{
  # Monitor name
  attr_accessor :name

  ## initialize {{{
  # Create a new instance
  # @param  [String]  path  Path of the hwmon
  ##

  def initialize(path)
    @path      = path
    @cur_temp  = 0

    # Read name
    @name = read_value(File.join(path, "name"))

    @path = File.join(path, "temp1_input")
  end # }}}

  ## update {{{
  # Update monitor data
  ##

  def update
    @cur_temp = read_value(@path).to_f
    @cur_temp = @cur_temp / 1000
  rescue
    @cur_temp = 0.0
  end # }}}

  ## to_s {{{
  # Convert data to string for given scale
  # @param  [String]  scale      Temperatur scale
  # @param  [Bool]    show_name  Show monitor name
  # @return [String] Formatted string
  ##

  def to_s(scale = "C", show_name = true)
    # Covnert scale
    case(scale)
      when "K" then degree = @cur_temp + 273.15
      when "F" then degree = @cur_temp * 1.8 + 32
      when "R" then degree = @cur_temp * 1.8 + 491.67
      when "D" then degree = (100 - @cur_temp) * 1.5
      when "N" then degree = @cur_temp * 0.33
      when "C" then degree = @cur_temp
    end

    # Assemble string
    if(show_name)
      "%s %1.f°%s" % [ @name, degree, scale ]
    else
      "%1.f°%s" % [ degree, scale ]
    end
  end # }}}

  private

  def read_value(path) # {{{
    ret = nil

    # Check if file exist
    if(File.exist?(path))
      ret = IO.readlines(path).first.chop
    end

    ret
  end # }}}
end # }}}

configure :temp do |s| # {{{
  s.interval = 60
  s.icon     = Subtlext::Icon.new("temp.xbm")
  s.monitors = []

  # Config
  s.scale     = s.config[:scale] || "C"
  s.show_name = s.config[:show_name].nil? ? true : s.config[:show_name]
  monitors    = s.config[:monitors] || []

  # Sanitize data
  if(monitors.is_a?(String))
    monitors = monitors.delete(" ").split(",")
  end

  if(s.scale.is_a?(String))
    s.scale.upcase!

    # Check if scale is valid
    unless(["K", "F", "R", "D", "N", "C" ].include?(s.scale))
      s.warn "Unknown scale `#{s.scale}', falling back to C\n"
      s.scale = "C"
    end
  else
    s.scale = "C"
  end

  # Create monitors
  mons = Dir["/sys/class/hwmon/*"].map { |mon| h = Hwmon.new(mon) }

  # Keep order
  if(monitors.empty?)
    s.monitors = mons
  else
    monitors.each do |name|
      found = false

      # Check if hwmon is in list
      mons.each do |mon|
        if(name == mon.name)
          s.monitors << mon
          found = true
        end
      end

      s.warn "Unknown monitor `#{name}'\n" unless(found)
    end
  end
end # }}}

on :run do |s| # {{{
  begin
    data = []

    # Update monitors
    s.monitors.each do |mon|
      mon.update

      data << mon.to_s(s.scale, s.show_name)
    end

    s.data = "%s%s" % [ s.icon, data.join(" ") ]
  rescue => err # Sanitize to prevent unloading
    s.data = "subtle"
    p err, err.backtrace
  end
end # }}}
