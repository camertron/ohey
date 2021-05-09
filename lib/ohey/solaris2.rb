module Ohey
  class Solaris2
    UNAME_PATH = '/sbin/uname'.freeze
    RELEASE_PATH = '/etc/release'.freeze

    def name
      @name ||= release.find do |line|
        case line
          when /.*SmartOS.*/
            break 'smartos'
          when /^\s*OmniOS.*r(\d+).*$/
            break 'omnios'
          when /^\s*OpenIndiana.*(Development oi_|Hipster )(\d\S*)/
            break 'openindiana'
          when /^\s*(Oracle Solaris|Solaris)/
            break 'solaris2'
        end
      end
    end

    def version
      @version ||= version_from_release || version_from_uname
    end

    def build
      @build ||= uname.find do |line|
        case line
          when /^KernelID =\s+(.+)$/
            break $1
        end
      end
    end

    def family
      name
    end

    private

    def version_from_uname
      uname.find do |line|
        case line
          when /^Release =\s+(.+)$/
            break $1
        end
      end
    end

    def version_from_release
      release.find do |line|
        case line
          when /^\s*OmniOS.*r(\d+).*$/
            break $1
          when /^\s*OpenIndiana.*(Development oi_|Hipster )(\d\S*)/
            break $2
        end
      end
    end

    def uname
      @uname ||= `#{uname_exec} -X`.split("\n")
    end

    def uname_exec
      @uname_exec ||= File.exist?(UNAME_PATH) ? UNAME_PATH : 'uname'
    end

    def release
      @release ||= File.read(RELEASE_PATH).split("\n")
    end
  end
end