module Ohey
  class Linux
    OS_RELEASE_PATH         = '/etc/os-release'.freeze
    ORACLE_RELEASE_PATH     = '/etc/oracle-release'.freeze
    ENTERPRISE_RELEASE_PATH = '/etc/enterprise-release'.freeze
    F5_RELEASE_PATH         = '/etc/f5-release'.freeze
    DEBIAN_VERSION_PATH     = '/etc/debian_version'.freeze
    PARALLELS_RELEASE_PATH  = '/etc/parallels-release'.freeze
    EOS_RELEASE_PATH        = '/etc/Eos-release'.freeze
    REDHAT_RELEASE_PATH     = '/etc/redhat-release'.freeze
    SYSTEM_RELEASE_PATH     = '/etc/system-release'.freeze
    SUSE_RELEASE_PATH       = '/etc/SuSE-release'.freeze
    SLACKWARE_VERSION_PATH  = '/etc/slackware-version'.freeze
    EXHERBO_RELEASE_PATH    = '/etc/exherbo-release'.freeze
    CLEARLINUX_RELEASE_PATH = '/usr/lib/os-release'.freeze

    # the platform mappings between the 'ID' field in /etc/os-release and the value
    # ohai uses. If you're adding a new platform here and you want to change the name
    # you'll want to add it here and then add a spec for the platform_id_remap method
    PLATFORM_ID_MAP = {
      'alinux'        => 'alibabalinux',
      'amzn'          => 'amazon',
      'archarm'       => 'arch',
      'cumulus-linux' => 'cumulus',
      'ol'            => 'oracle',
      'opensuse-leap' => 'opensuseleap',
      'rhel'          => 'redhat',
      'sles_sap'      => 'suse',
      'sles'          => 'suse',
      'xenenterprise' => 'xenserver',
    }

    PLATFORM_ID_MAP.freeze

    def name
      @name ||= if os_release_exists?
        platform_id_remap(os_release_info['ID'])
      else
        legacy_platform_detection
      end
    end

    def family
      case name
        when /ubuntu/, /debian/, /linuxmint/, /raspbian/, /cumulus/, /kali/, /pop/
          # apt-get+dpkg almost certainly goes here
          'debian'
        when /centos/, /redhat/, /oracle/, /almalinux/, /rocky/, /scientific/, /enterpriseenterprise/, /xenserver/, /xcp-ng/, /cloudlinux/, /alibabalinux/, /sangoma/, /clearos/, /parallels/, /ibm_powerkvm/, /nexus_centos/, /bigip/ # Note that 'enterpriseenterprise' is oracle's LSB "distributor ID"
          # NOTE: "rhel" should be reserved exclusively for recompiled rhel
          # versions that are nearly perfectly compatible down to the
          # platform_version. The operating systems that are "rhel" should
          # all be as compatible as rhel7 = centos7 = oracle7 = scientific7
          # (98%-ish core RPM version compatibility and the version numbers
          # MUST track the upstream). The appropriate EPEL version repo should
          # work nearly perfectly.  Some variation like the oracle kernel
          # version differences and tuning and extra packages are clearly
          # acceptable. Almost certainly some distros above (xenserver?)
          # should not be in this list. Please use fedora, below, instead.
          # Also note that this is the only platform_family with this strict
          # of a rule, see the example of the debian platform family for how
          # the rest of the platform_family designations should be used.
          #
          # TODO: when XCP-NG 7.4 support ends we can remove the xcp-ng match.
          # 7.5+ reports as xenenterprise which we remap to xenserver.
          'rhel'
        when /amazon/
          'amazon'
        when /suse/, /sles/, /opensuseleap/, /opensuse/, /sled/
          'suse'
        when /fedora/, /arista_eos/
          # In the broadest sense:  RPM-based, fedora-derived distributions
          # which are not strictly re-compiled RHEL (if it uses RPMs, and
          # smells more like redhat and less like SuSE it probably goes here).
          'fedora'
        when /nexus/, /ios_xr/
          'wrlinux'
        when /gentoo/
          'gentoo'
        when /arch/, /manjaro/
          'arch'
        when /exherbo/
          'exherbo'
        when /alpine/
          'alpine'
        when /clearlinux/
          'clearlinux'
        when /mangeia/
          'mandriva'
        when /slackware/
          'slackware'
      end
    end

    def build
      nil
    end

    def version
      @version ||= if os_release_exists?
        # Grab the version from the VERSION_ID field and use the kernel release if that's not
        # available. It should be there for everything, but rolling releases like arch / gentoo
        # where we've traditionally used the kernel as the version

        # centos only includes the major version in os-release for some reason
        if os_release_info['ID'] == 'centos'
          get_redhatish_version(redhat_release)
        # debian testing and unstable don't have VERSION_ID set
        elsif os_release_info['ID'] == 'debian'
          os_release_info['VERSION_ID'] || debian_version
        else
          os_release_info['VERSION_ID'] || uname_r.strip
        end
      else
        legacy_platform_version_detection
      end
    end

    private

    def uname_r
      @uname_r ||= `/bin/uname -r`
    end

    def os_release_file_is_cisco?
      os_release_exists? && os_release_info['CISCO_RELEASE_INFO']
    end

    # our platform names don't match os-release. given a time machine they would but ohai
    # came before the os-release file. This method remaps the os-release names to
    # the ohai names
    def platform_id_remap(id)
      # this catches the centos guest shell in the nexus switch which identifies itself as centos
      return "nexus_centos" if id == "centos" && os_release_file_is_cisco?

      PLATFORM_ID_MAP[id.downcase] || id.downcase
    end

    def read_release_info(file)
      return nil unless File.exist?(file)

      File.read(file).split.inject({}) do |map, line|
        key, value = line.split("=")
        map[key] = value.gsub(/\A"|"\Z/, "") if value
        map
      end
    end

    def os_release_info
      @os_release_info ||= read_release_info(OS_RELEASE_PATH).tap do |release_info|
        cisco_release_info = release_info['CISCO_RELEASE_INFO'] if release_info

        if cisco_release_info && File.exist?(cisco_release_info)
          release_info.merge!(read_os_release_info(cisco_release_info))
        end
      end
    end

    def os_release_exists?
      File.exist?(OS_RELEASE_PATH)
    end

    def lsb
      @lsb ||= {}.tap do |attrs|
        lsb_release_a.split("\n").each do |line|
          case line
            when /^Distributor ID:\s+(.+)/
              attrs[:id] = $1
            when /^Description:\s+(.+)/
              attrs[:description] = $1
            when /^Release:\s+(.+)/
              attrs[:release] = $1
            when /^Codename:\s+(.+)/
              attrs[:codename] = $1
            else
              attrs[:id] = line
          end
        end
      end
    end

    def lsb_release_a
      @lsb_release_a ||= `lsb_release -a`
    end

    def bigip_version
      f5_release.match(/BIG-IP release (\S*)/)[1] # http://rubular.com/r/O8nlrBVqSb
    rescue NoMethodError, Errno::ENOENT, Errno::EACCES # rescue regex failure, file missing, or permission denied
      puts 'Detected F5 Big-IP, but /etc/f5-release could not be parsed to determine platform_version'
      nil
    end

    def oracle_release
      @oracle_release ||= File.read(ORACLE_RELEASE_PATH).chomp
    end

    def enterprise_release
      @enterprise_release ||= File.read(ENTERPRISE_RELEASE_PATH).chomp
    end

    def f5_release
      @f5_release ||= File.read(F5_RELEASE_PATH)
    end

    def debian_version
      @debian_version ||= File.read(DEBIAN_VERSION_PATH).chomp
    end

    def parallels_release
      @parallels_release ||= File.read(PARALLELS_RELEASE_PATH).chomp
    end

    def eos_release
      @eos_release ||= File.read(EOS_RELEASE_PATH)
    end

    def redhat_release
      @redhat_release ||= File.read(REDHAT_RELEASE_PATH).chomp
    end

    def system_release
      @system_release ||= File.read(SYSTEM_RELEASE_PATH).chomp
    end

    def suse_release
      @suse_release ||= File.read(SUSE_RELEASE_PATH)
    end

    def slackware_version
      @slackware_version ||= File.read(SLACKWARE_VERSION_PATH)
    end

    def clearlinux_release
      @clearlinux_release ||= File.read(CLEARLINUX_RELEASE_PATH)
    end

    def get_redhatish_platform(contents)
      contents[/^Red Hat/i] ? 'redhat' : contents[/(\w+)/i, 1].downcase
    end

    def get_redhatish_version(contents)
      contents[/(release)? ([\d\.]+)/, 2]
    end

    def legacy_platform_detection
      # platform [ and platform_version ? ] should be lower case to avoid dealing with RedHat/Redhat/redhat matching
      if File.exist?(ORACLE_RELEASE_PATH) || File.exist?(ENTERPRISE_RELEASE_PATH)
        'oracle'
      elsif File.exist?(F5_RELEASE_PATH)
        'bigip'
      elsif File.exist?(DEBIAN_VERSION_PATH)
        # Ubuntu and Debian both have /etc/debian_version
        # Ubuntu should always have a working lsb, debian does not by default
        /Ubuntu/i.match?(lsb[:id]) ? 'ubuntu' : 'debian'
      elsif File.exist?(PARALLELS_RELEASE_PATH)
        get_redhatish_platform(parallels_release)
      elsif File.exist?(EOS_RELEASE_PATH)
        'arista_eos'
      elsif File.exist?(REDHAT_RELEASE_PATH)
        get_redhatish_platform(redhat_release)
      elsif File.exist?(SYSTEM_RELEASE_PATH)
        get_redhatish_platform(system_release)
      elsif File.exist?(SUSE_RELEASE_PATH)
        if /^openSUSE/.match?(suse_release)
          # opensuse releases >= 42 are openSUSE Leap
          if version.to_i < 42
            'opensuse'
          else
            'opensuseleap'
          end
        else
          'suse'
        end
      elsif os_release_file_is_cisco?
        if os_release_info['ID_LIKE'].nil? || !os_release_info['ID_LIKE'].include?('wrlinux')
          raise 'unknown Cisco /etc/os-release or /etc/cisco-release ID_LIKE field'
        end

        case os_release_info['ID']
          when 'nexus'
            'nexus'
          when 'ios_xr'
            'ios_xr'
          else
            raise 'unknown Cisco /etc/os-release or /etc/cisco-release ID field'
        end
      elsif File.exist?(SLACKWARE_VERSION_PATH)
        'slackware'
      elsif File.exist?(EXHERBO_RELEASE_PATH)
        'exherbo'
      elsif File.exist?(CLEARLINUX_RELEASE_PATH)
        # Clear Linux https://clearlinux.org/
        if /clear-linux-os/.match?(clearlinux_release)
          'clearlinux'
        end
      elsif /RedHat/i.match?(lsb[:id])
        'redhat'
      elsif /Amazon/i.match?(lsb[:id])
        'amazon'
      elsif /ScientificSL/i.match?(lsb[:id])
        'scientific'
      elsif /XenServer/i.match?(lsb[:id])
        'xenserver'
      elsif lsb[:id]
        # LSB can provide odd data that changes between releases, so we currently fall back on it
        # rather than dealing with its subtleties
        lsb[:id].downcase
      end
    end

    def legacy_platform_version_detection
      # platform [ and platform_version ? ] should be lower case to avoid dealing with RedHat/Redhat/redhat matching
      if File.exist?(ORACLE_RELEASE_PATH)
        get_redhatish_version(oracle_release)
      elsif File.exist?(ENTERPRISE_RELEASE_PATH)
        get_redhatish_version(enterprise_release)
      elsif File.exist?(F5_RELEASE_PATH)
        bigip_version
      elsif File.exist?(DEBIAN_VERSION_PATH)
        # Ubuntu and Debian both have /etc/debian_version
        # Ubuntu should always have a working lsb, debian does not by default
        if /Ubuntu/i.match?(lsb[:id])
          lsb[:release]
        else
          debian_version
        end
      elsif File.exist?(PARALLELS_RELEASE_PATH)
        parallels_release.match(/(\d\.\d\.\d)/)[0]
      elsif File.exist?(EOS_RELEASE_PATH)
        eos_release.strip.split[-1]
      elsif File.exist?(REDHAT_RELEASE_PATH)
        get_redhatish_version(redhat_release)
      elsif File.exist?(SYSTEM_RELEASE_PATH)
        get_redhatish_version(system_release)
      elsif File.exist?(SUSE_RELEASE_PATH)
        suse_version = suse_release.scan(/VERSION = (\d+)\nPATCHLEVEL = (\d+)/).flatten.join(".")
        suse_version = suse_release[/VERSION = ([\d\.]{2,})/, 1] if suse_version == ''
        suse_version
      elsif os_release_file_is_cisco?
        os_release_info['VERSION']
      elsif File.exist?(SLACKWARE_VERSION_PATH)
        slackware_version.scan(/(\d+|\.+)/).join
      elsif File.exist?(EXHERBO_RELEASE_PATH)
        # no way to determine platform_version in a rolling release distribution
        # kernel release will be used - ex. 3.13
        uname_r.strip
      elsif File.exist?(CLEARLINUX_RELEASE_PATH)
        if /clear-linux-os/.match?(clearlinux_release) # Clear Linux https://clearlinux.org/
          clearlinux_release[/VERSION_ID=(\d+)/, 1]
        end
      else
        lsb[:release]
      end
    end
  end
end