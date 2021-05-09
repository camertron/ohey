module Ohey
  class Darwin
    NAME = 'mac_os_x'.freeze
    FAMILY = 'mac_os_x'.freeze

    def name
      NAME
    end

    def family
      FAMILY
    end

    def build
      @build ||= sw_vers.each do |line|
        case line
          when /^BuildVersion:\s+(.+)$/
            break $1
        end
      end
    end

    def version
      @version ||= sw_vers.each do |line|
        case line
          when /^ProductVersion:\s+(.+)$/
            break $1
        end
      end
    end

    private

    def sw_vers
      @sw_vers ||= `/usr/bin/sw_vers`.split("\n")
    end
  end
end