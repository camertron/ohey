require 'wmi-lite/wmi'

module Ohey
  class Windows
    FAMILY = 'windows'.freeze

    def name
      @name ||= os_type_decode(host['ostype'])
    end

    def version
      @version ||= host['version']
    end

    def build
      nil
    end

    def family
      FAMILY
    end

    private

    # decode the OSType field from WMI Win32_OperatingSystem class
    # https://msdn.microsoft.com/en-us/library/aa394239(v=vs.85).aspx
    # @param [Integer] sys_type OSType value from Win32_OperatingSystem
    # @return [String] the human consumable OS type value
    def os_type_decode(sys_type)
      case sys_type
        when 18 then "WINNT" # most likely so first
        when 0 then "Unknown"
        when 1 then "Other"
        when 14 then "MSDOS"
        when 15 then "WIN3x"
        when 16 then "WIN95"
        when 17 then "WIN98"
        when 19 then "WINCE"
      end
    end

    def wmi
      @wmi ||= WmiLite::Wmi.new
    end

    def host
      @host ||= wmi.first_of('Win32_OperatingSystem')
    end
  end
end
