module Ohey
  class FreeBSD
    FAMILY = 'freebsd'.freeze

    def name
      @name ||= uname_s.strip.downcase
    end

    def version
      @version ||= uname_r.strip
    end

    def build
      nil
    end

    def family
      FAMILY
    end

    private

    def uname_s
      @uname_s ||= `uname -s`
    end

    def uname_r
      @uname_r ||= `uname -r`
    end
  end
end