module Ohey
  class Aix
    NAME = 'aix'.freeze
    FAMILY = 'aix'.freeze

    def name
      NAME
    end

    def family
      FAMILY
    end

    def build
      nil
    end

    def version
      @version ||= begin
        release = uname_rvp[0]
        version = uname_rvp[1]
        [version, release].join(".")
      end
    end

    def uname_rvp
      @uname_rvp ||= `uname -rvp`.split
    end
  end
end
