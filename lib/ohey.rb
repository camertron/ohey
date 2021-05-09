module Ohey
  autoload :Aix,          'ohey/aix'
  autoload :Darwin,       'ohey/darwin'
  autoload :DragonflyBSD, 'ohey/dragonflybsd'
  autoload :FreeBSD,      'ohey/freebsd'
  autoload :Linux,        'ohey/linux'
  autoload :NetBSD,       'ohey/netbsd'
  autoload :OpenBSD,      'ohey/openbsd'
  autoload :Solaris2,     'ohey/solaris2'
  autoload :Windows,      'ohey/windows'

  class << self
    def current_platform
      registered_platforms[os]
    end

    def register_platform(name, klass)
      registered_platforms[name] = klass
    end

    def registered_platforms
      @registered_platforms ||= {}
    end

    def os
      case ::RbConfig::CONFIG['host_os']
        when /aix(.+)$/
          :aix
        when /darwin(.+)$/
          :darwin
        when /linux/
          :linux
        when /freebsd(.+)$/
          :freebsd
        when /openbsd(.+)$/
          :openbsd
        when /netbsd(.*)$/
          :netbsd
        when /dragonfly(.*)$/
          :dragonflybsd
        when /solaris2/
          :solaris2
        when /mswin|mingw32|windows/
          # After long discussion in IRC the "powers that be" have come to a consensus
          # that no Windows platform exists that was not based on the
          # Windows_NT kernel, so we herby decree that "windows" will refer to all
          # platforms built upon the Windows_NT kernel and have access to win32 or win64
          # subsystems.
          :windows
        else
          ::RbConfig::CONFIG['host_os'].to_sym
      end
    end
  end
end

Ohey.register_platform(:aix, Ohey::Aix.new)
Ohey.register_platform(:darwin, Ohey::Darwin.new)
Ohey.register_platform(:dragonflybsd, Ohey::DragonflyBSD.new)
Ohey.register_platform(:freebsd, Ohey::FreeBSD.new)
Ohey.register_platform(:linux, Ohey::Linux.new)
Ohey.register_platform(:netbsd, Ohey::NetBSD.new)
Ohey.register_platform(:openbsd, Ohey::OpenBSD.new)
Ohey.register_platform(:solaris2, Ohey::Solaris2.new)
Ohey.register_platform(:windows, Ohey::Windows.new)
