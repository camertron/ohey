require 'spec_helper'

describe Ohey::Linux do
  subject { described_class.new }

  describe "#family" do
    %w{oracle centos redhat scientific enterpriseenterprise xenserver cloudlinux ibm_powerkvm parallels nexus_centos clearos bigip}.each do |p|
      it "returns rhel for #{p} platform" do
        allow(subject).to receive(:name).and_return(p)
        expect(subject.family).to eq('rhel')
      end
    end

    %w{suse sles opensuse opensuseleap sled}.each do |p|
      it "returns suse for #{p} family" do
        allow(subject).to receive(:name).and_return(p)
        expect(subject.family).to eq('suse')
      end
    end

    %w{fedora arista_eos}.each do |p|
      it "returns fedora for #{p} family" do
        allow(subject).to receive(:name).and_return(p)
        expect(subject.family).to eq('fedora')
      end
    end

    %w{nexus ios_xr}.each do |p|
      it "returns wrlinux for #{p} family" do
        allow(subject).to receive(:name).and_return(p)
        expect(subject.family).to eq('wrlinux')
      end
    end

    %w{arch manjaro}.each do |p|
      it "returns arch for #{p} family" do
        allow(subject).to receive(:name).and_return(p)
        expect(subject.family).to eq('arch')
      end
    end

    %w{amazon slackware gentoo exherbo alpine clearlinux}.each do |same_name|
      it "returns #{same_name} for #{same_name} family" do
        allow(subject).to receive(:name).and_return(same_name)
        expect(subject.family).to eq(same_name)
      end
    end

    it 'returns mandriva for mangeia platform' do
      allow(subject).to receive(:name).and_return('mangeia')
      expect(subject.family).to eq('mandriva')
    end
  end

  context 'on system with /etc/os-release' do
    before do
      allow(File).to receive(:exist?).with('/etc/os-release').and_return(true)
    end

    context 'when os-release data is correct' do
      let(:os_data) do
        <<~OS_DATA
          NAME="Ubuntu"
          VERSION="14.04.5 LTS, Trusty Tahr"
          ID=ubuntu
          ID_LIKE=debian
          PRETTY_NAME="Ubuntu 14.04.5 LTS"
          VERSION_ID="14.04"
        OS_DATA
      end

      before do
        allow(File).to receive(:read).with('/etc/os-release').and_return(os_data)
      end

      describe '#platform' do
        it 'correctly identifies the platform' do
          expect(subject.name).to eq('ubuntu')
        end
      end

      describe '#family' do
        it 'correctly identifies the platform family' do
          expect(subject.family).to eq('debian')
        end
      end

      describe '#build' do
        it 'correctly identifies the platform build' do
          expect(subject.build).to eq(nil)
        end
      end

      describe '#version' do
        it 'correctly identifies the version' do
          expect(subject.version).to eq('14.04')
        end
      end
    end

    context 'when os-release data is missing a version_id' do
      let(:os_data) do
        <<~OS_DATA
          NAME="Arch Linux"
          PRETTY_NAME="Arch Linux"
          ID=arch
          ID_LIKE=archlinux
        OS_DATA
      end

      before do
        allow(File).to receive(:read).with('/etc/os-release').and_return(os_data)
        allow(subject).to receive(:uname_r).and_return("3.18.2-2-ARCH\n")
      end

      describe '#name' do
        it 'correctly identifies the platform' do
          expect(subject.name).to eq('arch')
        end
      end

      describe '#family' do
        it 'correctly identifies the platform family' do
          expect(subject.family).to eq('arch')
        end
      end

      describe '#build' do
        it 'correctly identifies the platform build' do
          expect(subject.build).to eq(nil)
        end
      end

      describe '#version' do
        it 'correctly identifies the version' do
          expect(subject.version).to eq('3.18.2-2-ARCH')
        end
      end
    end

    context 'when platform requires remapping' do
      let(:os_data) do
        <<~OS_DATA
          NAME="openSUSE Leap"
          VERSION="15.0"
          ID="opensuse-leap"
          ID_LIKE="suse opensuse"
          VERSION_ID="15.0"
          PRETTY_NAME="openSUSE Leap 15.0"
        OS_DATA
      end

      before do
        allow(File).to receive(:read).with('/etc/os-release').and_return(os_data)
      end

      describe '#name' do
        it 'correctly identifies the platform' do
          expect(subject.name).to eq('opensuseleap')
        end
      end

      describe '#family' do
        it 'correctly identifies the family' do
          expect(subject.family).to eq('suse')
        end
      end

      describe '#build' do
        it 'correctly identifies the platform build' do
          expect(subject.build).to eq(nil)
        end
      end

      describe '#version' do
        it 'correctly identifies the platform version' do
          expect(subject.version).to eq('15.0')
        end
      end
    end

    context 'when on centos where version data in os-release is wrong' do
      let(:os_data) do
        <<~OS_DATA
          NAME="CentOS Linux"
          VERSION="7 (Core)"
          ID="centos"
          ID_LIKE="rhel fedora"
          VERSION_ID="7"
          PRETTY_NAME="CentOS Linux 7 (Core)"
        OS_DATA
      end

      let(:redhat_data) { 'CentOS Linux release 7.5.1804 (Core)' }

      before do
        allow(File).to receive(:read).with('/etc/os-release').and_return(os_data)
        allow(File).to receive(:read).with('/etc/redhat-release').and_return(redhat_data)
      end

      describe '#platform' do
        it 'correctly identifies the platform' do
          expect(subject.name).to eq('centos')
        end
      end

      describe '#family' do
        it 'correctly identifies the platform family' do
          expect(subject.family).to eq('rhel')
        end
      end

      describe '#build' do
        it 'correctly identifies the platform build' do
          expect(subject.build).to eq(nil)
        end
      end

      describe '#version' do
        it 'correctly identifies the version' do
          expect(subject.version).to eq('7.5.1804')
        end
      end
    end

    context 'when on debian and version data in os-release is missing' do
      let(:os_data) do
        <<~OS_DATA
          PRETTY_NAME="Debian GNU/Linux bullseye/sid"
          NAME="Debian GNU/Linux"
          ID=debian
          HOME_URL="https://www.debian.org/"
          SUPPORT_URL="https://www.debian.org/support"
          BUG_REPORT_URL="https://bugs.debian.org/"
        OS_DATA
      end

      let(:debian_data) { 'bullseye/sid' }

      before do
        allow(File).to receive(:read).with('/etc/os-release').and_return(os_data)
        allow(File).to receive(:read).with('/etc/debian_version').and_return(debian_data)
      end

      describe '#platform' do
        it 'correctly identifies the platform' do
          expect(subject.name).to eq('debian')
        end
      end

      describe '#family' do
        it 'correctly identifies the platform family' do
          expect(subject.family).to eq('debian')
        end
      end

      describe '#build' do
        it 'correctly identifies the platform build' do
          expect(subject.build).to eq(nil)
        end
      end

      describe '#version' do
        it 'correctly identifies the platform version' do
          expect(subject.version).to eq('bullseye/sid')
        end
      end
    end
  end

  context "when on system without /etc/os-release (legacy)" do
    let(:have_debian_version) { false }
    let(:have_redhat_release) { false }
    let(:have_exherbo_release) { false }
    let(:have_eos_release) { false }
    let(:have_suse_release) { false }
    let(:have_system_release) { false }
    let(:have_slackware_version) { false }
    let(:have_enterprise_release) { false }
    let(:have_oracle_release) { false }
    let(:have_parallels_release) { false }
    let(:have_os_release) { false }
    let(:have_os_release) { false }
    let(:have_usr_lib_os_release) { false }
    let(:have_cisco_release) { false }
    let(:have_f5_release) { false }

    before do
      allow(File).to receive(:exist?).with('/etc/debian_version').and_return(have_debian_version)
      allow(File).to receive(:exist?).with('/etc/redhat-release').and_return(have_redhat_release)
      allow(File).to receive(:exist?).with('/etc/exherbo-release').and_return(have_exherbo_release)
      allow(File).to receive(:exist?).with('/etc/Eos-release').and_return(have_eos_release)
      allow(File).to receive(:exist?).with('/etc/SuSE-release').and_return(have_suse_release)
      allow(File).to receive(:exist?).with('/etc/system-release').and_return(have_system_release)
      allow(File).to receive(:exist?).with('/etc/slackware-version').and_return(have_slackware_version)
      allow(File).to receive(:exist?).with('/etc/enterprise-release').and_return(have_enterprise_release)
      allow(File).to receive(:exist?).with('/etc/oracle-release').and_return(have_oracle_release)
      allow(File).to receive(:exist?).with('/etc/parallels-release').and_return(have_parallels_release)
      allow(File).to receive(:exist?).with('/etc/os-release').and_return(have_os_release)
      allow(File).to receive(:exist?).with('/etc/f5-release').and_return(have_f5_release)
      allow(File).to receive(:exist?).with('/usr/lib/os-release').and_return(have_usr_lib_os_release)
      allow(File).to receive(:exist?).with('/etc/shared/os-release').and_return(have_cisco_release)

      allow(File).to receive(:read).with("PLEASE STUB ALL plugin.read CALLS")
    end

    context "on lsb compliant distributions" do
      context 'ubuntu' do
        before do
          allow(subject).to receive(:lsb).and_return({ id: 'Ubuntu', release: '18.04' })
        end

        it 'sets platform to lowercased lsb[:id]' do
          expect(subject.name).to eq('ubuntu')
        end

        it 'sets platform_version to lsb[:release]' do
          expect(subject.version).to eq('18.04')
        end

        it 'sets platform to ubuntu and platform_family to debian lsb[:id] contains Ubuntu' do
          expect(subject.name).to eq('ubuntu')
          expect(subject.family).to eq('debian')
        end
      end

      context 'debian' do
        before do
          allow(subject).to receive(:lsb).and_return({ id: 'Debian', release: '18.04' })
        end

        it 'sets platform to debian and platform_family to debian lsb[:id] contains Debian' do
          expect(subject.name).to eq('debian')
          expect(subject.family).to eq('debian')
        end
      end

      context 'red hat' do
        before do
          allow(subject).to receive(:lsb).and_return({ id: 'RedHatEnterpriseServer', release: '7.5' })
        end

        it "sets platform to redhat and platform_family to rhel when lsb[:id] contains Redhat" do
          expect(subject.name).to eq('redhat')
          expect(subject.family).to eq('rhel')
        end
      end

      context 'amazon' do
        before do
          allow(subject).to receive(:lsb).and_return({ id: 'AmazonAMI', release: '2018.03' })
        end

        it 'sets platform to amazon and platform_family to rhel when lsb[:id] contains Amazon' do
          expect(subject.name).to eq('amazon')
          expect(subject.family).to eq('amazon')
        end
      end

      context 'scientific' do
        before do
          allow(subject).to receive(:lsb).and_return({ id: 'ScientificSL', release: '7.5' })
        end

        it 'sets platform to scientific when lsb[:id] contains ScientificSL' do
          expect(subject.name).to eq('scientific')
        end
      end

      context 'ibm' do
        before do
          allow(subject).to receive(:lsb).and_return({ id: 'IBM_PowerKVM', release: '2.1' })
        end

        it 'sets platform to ibm_powerkvm and platform_family to rhel when lsb[:id] contains IBM_PowerKVM' do
          expect(subject.name).to eq('ibm_powerkvm')
          expect(subject.family).to eq('rhel')
        end
      end
    end

    context 'on debian' do
      let(:have_debian_version) { true }
      let(:lsb) { {} }

      before do
        expect(subject).to receive(:lsb).and_return(lsb)
      end

      it 'reads the version from /etc/debian_version' do
        expect(File).to receive(:read).with('/etc/debian_version').and_return('9.5')
        expect(subject.version).to eq('9.5')
      end

      it 'correctly strips any newlines' do
        expect(File).to receive(:read).with('/etc/debian_version').and_return("9.5\n")
        expect(subject.version).to eq('9.5')
      end

      context 'ubuntu' do
        let(:lsb) { { id: 'Ubuntu', release: '18.04' } }

        # Ubuntu has /etc/debian_version as well
        it 'detects Ubuntu as itself rather than debian' do
          expect(subject.name).to eq('ubuntu')
        end
      end
    end

    context 'on slackware' do
      let(:have_slackware_version) { true }
      let(:lsb) { {} }

      before do
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      it 'sets platform and platform_family to slackware' do
        allow(File).to receive(:read).with('/etc/slackware-version').and_return('Slackware 12.0.0')
        expect(subject.name).to eq('slackware')
        expect(subject.family).to eq('slackware')
      end

      it 'sets platform_version on slackware' do
        allow(File).to receive(:read).with('/etc/slackware-version').and_return('Slackware 12.0.0')
        expect(subject.version).to eq('12.0.0')
      end
    end

    context 'on arista eos' do
      let(:have_system_release) { true }
      let(:have_redhat_release) { true }
      let(:have_eos_release) { true }
      let(:lsb) { {} }

      before do
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      it 'sets platform to arista_eos' do
        expect(File).to receive(:read).with('/etc/Eos-release').and_return('Arista Networks EOS 4.21.1.1F')
        expect(subject.name).to eq("arista_eos")
        expect(subject.family).to eq("fedora")
        expect(subject.version).to eq("4.21.1.1F")
      end
    end

    context 'on f5 big-ip' do
      let(:have_f5_release) { true }
      let(:lsb) { {} }

      before do
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      it "sets platform to bigip" do
        expect(File).to receive(:read).with('/etc/f5-release').and_return('BIG-IP release 13.0.0 (Final)')
        expect(subject.name).to eq('bigip')
        expect(subject.family).to eq('rhel')
        expect(subject.version).to eq('13.0.0')
      end
    end

    context 'on exherbo' do
      let(:have_exherbo_release) { true }
      let(:lsb) { {} }

      before do
        allow(subject).to receive(:uname_r).and_return("3.18.2-2-ARCH\n")
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      it 'sets platform and platform_family to exherbo' do
        expect(subject.name).to eq('exherbo')
        expect(subject.family).to eq('exherbo')
      end

      it 'sets platform_version to kernel release' do
        expect(subject.version).to eq('3.18.2-2-ARCH')
      end
    end

    context 'on redhat breeds' do
      let(:lsb) { {} }

      before do
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      context 'with lsb_release results' do
        context 'red hat' do
          let(:lsb) { { id: 'RedHatEnterpriseServer', release: '7.5' } }

          it 'sets the platform to redhat and platform_family to rhel even if the LSB name is something absurd but redhat-like' do
            expect(subject.name).to eq('redhat')
            expect(subject.version).to eq('7.5')
            expect(subject.family).to eq('rhel')
          end
        end

        context 'centos' do
          let(:lsb) { { id: 'CentOS', release: '7.5' } }

          it 'sets the platform to centos and platform_family to rhel' do
            expect(subject.name).to eq('centos')
            expect(subject.version).to eq('7.5')
            expect(subject.family).to eq('rhel')
          end
        end
      end

      context 'without lsb_release results' do
        let(:have_redhat_release) { true }

        it 'reads the platform as centos and version as 7.5' do
          expect(File).to receive(:read).with('/etc/redhat-release').and_return('CentOS Linux release 7.5.1804 (Core)')
          expect(subject.name).to eq('centos')
          expect(subject.version).to eq('7.5.1804')
        end

        it 'reads platform of Red Hat with a space' do
          expect(File).to receive(:read).with('/etc/redhat-release').and_return('Red Hat Enterprise Linux Server release 6.5 (Santiago)')
          expect(subject.name).to eq('redhat')
        end

        it 'reads the platform as redhat without a space' do
          expect(File).to receive(:read).with('/etc/redhat-release').and_return('RedHat release 5.3')
          expect(subject.name).to eq('redhat')
          expect(subject.version).to eq('5.3')
        end
      end
    end

    context 'on pcs linux' do
      let(:have_redhat_release) { true }
      let(:have_parallels_release) { true }
      let(:lsb) { {} }

      before do
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      context 'with lsb_result' do
        let(:lsb) { { id: 'CloudLinuxServer', release: '6.5' } }

        it 'reads the platform as parallels and version as 6.0.5' do
          allow(File).to receive(:read).with('/etc/redhat-release').and_return('CloudLinux Server release 6.5 (Pavel Popovich)')
          expect(File).to receive(:read).with('/etc/parallels-release').and_return('Parallels Cloud Server 6.0.5 (20007)')
          expect(subject.name).to eq('parallels')
          expect(subject.version).to eq('6.0.5')
          expect(subject.family).to eq('rhel')
        end
      end

      context 'without lsb_results' do
        it 'reads the platform as parallels and version as 6.0.5' do
          allow(File).to receive(:read).with('/etc/redhat-release').and_return('CloudLinux Server release 6.5 (Pavel Popovich)')
          expect(File).to receive(:read).with('/etc/parallels-release').and_return('Parallels Cloud Server 6.0.5 (20007)')
          expect(subject.name).to eq('parallels')
          expect(subject.version).to eq('6.0.5')
          expect(subject.family).to eq('rhel')
        end
      end
    end

    context 'on oracle enterprise linux' do
      let(:have_redhat_release) { true }
      let(:lsb) { {} }

      before do
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      context 'with lsb_results' do
        context 'when on version 5.x' do
          let(:have_enterprise_release) { true }
          let(:lsb) { { id: 'EnterpriseEnterpriseServer', release: '5.7' } }

          it 'reads the platform as oracle and version as 5.7' do
            allow(File).to receive(:read).with('/etc/redhat-release').and_return('Red Hat Enterprise Linux Server release 5.7 (Tikanga)')
            expect(File).to receive(:read).with('/etc/enterprise-release').and_return('Enterprise Linux Enterprise Linux Server release 5.7 (Carthage)')
            expect(subject.name).to eq('oracle')
            expect(subject.version).to eq('5.7')
          end
        end

        context 'when on version 6.x' do
          let(:have_oracle_release) { true }
          let(:lsb) { { id: 'OracleServer', release: '6.1' } }

          it 'reads the platform as oracle and version as 6.1' do
            allow(File).to receive(:read).with('/etc/redhat-release').and_return('Red Hat Enterprise Linux Server release 6.1 (Santiago)')
            expect(File).to receive(:read).with('/etc/oracle-release').and_return('Oracle Linux Server release 6.1')
            expect(subject.name).to eq('oracle')
            expect(subject.version).to eq('6.1')
          end
        end
      end

      context 'without lsb_results' do
        context 'when on version 5.x' do
          let(:have_enterprise_release) { true }

          it 'reads the platform as oracle and version as 5' do
            allow(File).to receive(:read).with('/etc/redhat-release').and_return('Enterprise Linux Enterprise Linux Server release 5 (Carthage)')
            expect(File).to receive(:read).with('/etc/enterprise-release').and_return('Enterprise Linux Enterprise Linux Server release 5 (Carthage)')
            expect(subject.name).to eq('oracle')
            expect(subject.version).to eq('5')
          end

          it 'reads the platform as oracle and version as 5.1' do
            allow(File).to receive(:read).with('/etc/redhat-release').and_return('Enterprise Linux Enterprise Linux Server release 5.1 (Carthage)')
            expect(File).to receive(:read).with('/etc/enterprise-release').and_return('Enterprise Linux Enterprise Linux Server release 5.1 (Carthage)')
            expect(subject.name).to eq('oracle')
            expect(subject.version).to eq('5.1')
          end

          it 'reads the platform as oracle and version as 5.7' do
            allow(File).to receive(:read).with('/etc/redhat-release').and_return('Red Hat Enterprise Linux Server release 5.7 (Tikanga)')
            expect(File).to receive(:read).with('/etc/enterprise-release').and_return('Enterprise Linux Enterprise Linux Server release 5.7 (Carthage)')
            expect(subject.name).to eq('oracle')
            expect(subject.version).to eq('5.7')
          end
        end

        context 'when on version 6.x' do
          let(:have_oracle_release) { true }

          it 'reads the platform as oracle and version as 6.0' do
            allow(File).to receive(:read).with('/etc/redhat-release').and_return('Red Hat Enterprise Linux Server release 6.0 (Santiago)')
            expect(File).to receive(:read).with('/etc/oracle-release').and_return('Oracle Linux Server release 6.0')
            expect(subject.name).to eq('oracle')
            expect(subject.version).to eq('6.0')
          end

          it 'reads the platform as oracle and version as 6.1' do
            allow(File).to receive(:read).with('/etc/redhat-release').and_return('Red Hat Enterprise Linux Server release 6.1 (Santiago)')
            expect(File).to receive(:read).with('/etc/oracle-release').and_return('Oracle Linux Server release 6.1')
            expect(subject.name).to eq('oracle')
            expect(subject.version).to eq('6.1')
          end
        end
      end
    end

    context 'on suse' do
      context 'when on versions that have no /etc/os-release but /etc/SuSE-release (e.g. SLES12.1)' do
        let(:have_suse_release) { true }
        let(:have_os_release) { false }
        let(:lsb) { {} }

        before do
          allow(subject).to receive(:lsb).and_return(lsb)
        end

        describe 'with lsb_release results' do
          let(:lsb) { { id: 'SUSE LINUX', release: '2.1' } }

          it 'reads the platform as opensuse on openSUSE' do
            expect(File).to receive(:read).with('/etc/SuSE-release').and_return("openSUSE 12.1 (x86_64)\nVERSION = 12.1\nCODENAME = Asparagus\n")
            expect(subject.name).to eq('opensuse')
            expect(subject.family).to eq('suse')
          end
        end
      end

      context 'when on openSUSE and older SLES versions' do
        let(:have_suse_release) { true }

        describe 'without lsb_release results' do
          it 'sets platform and platform_family to suse and bogus verion to 10.0' do
            expect(File).to receive(:read).with('/etc/SuSE-release').at_least(:once).and_return('VERSION = 10.0')
            expect(subject.name).to eq('suse')
            expect(subject.family).to eq('suse')
          end

          it 'reads the version as 11.2' do
            expect(File).to receive(:read).with('/etc/SuSE-release').and_return("SUSE Linux Enterprise Server 11.2 (i586)\nVERSION = 11\nPATCHLEVEL = 2\n")
            expect(subject.name).to eq('suse')
            expect(subject.version).to eq('11.2')
            expect(subject.family).to eq('suse')
          end

          it '[OHAI-272] should read the version as 11.3' do
            expect(File).to receive(:read).with('/etc/SuSE-release').once.and_return("openSUSE 11.3 (x86_64)\nVERSION = 11.3")
            expect(subject.name).to eq('opensuse')
            expect(subject.version).to eq('11.3')
            expect(subject.family).to eq('suse')
          end

          it '[OHAI-272] should read the version as 11.4' do
            expect(File).to receive(:read).with('/etc/SuSE-release').once.and_return("openSUSE 11.4 (i586)\nVERSION = 11.4\nCODENAME = Celadon")
            expect(subject.name).to eq('opensuse')
            expect(subject.version).to eq('11.4')
            expect(subject.family).to eq('suse')
          end

          it 'reads the platform as opensuse on openSUSE' do
            expect(File).to receive(:read).with('/etc/SuSE-release').and_return("openSUSE 12.2 (x86_64)\nVERSION = 12.2\nCODENAME = Mantis\n")
            expect(subject.name).to eq('opensuse')
            expect(subject.family).to eq('suse')
          end

          it 'reads the platform as opensuseleap on openSUSE Leap' do
            expect(File).to receive(:read).with('/etc/SuSE-release').and_return("openSUSE 42.1 (x86_64)\nVERSION = 42.1\nCODENAME = Malachite\n")
            expect(subject.name).to eq('opensuseleap')
            expect(subject.family).to eq('suse')
          end
        end
      end
    end

    context 'on clearlinux' do
      let(:lsb) { {} }
      let(:have_usr_lib_os_release) { true }
      let(:os_release_content) do
        <<~CLEARLINUX_RELEASE
          NAME="Clear Linux OS"
          VERSION=1
          ID=clear-linux-os
          ID_LIKE=clear-linux-os
          VERSION_ID=26290
          PRETTY_NAME="Clear Linux OS"
        CLEARLINUX_RELEASE
      end

      before do
        expect(File).to receive(:read).with('/usr/lib/os-release').and_return(os_release_content)
        allow(subject).to receive(:lsb).and_return(lsb)
      end

      it 'sets platform to clearlinux and platform_family to clearlinux' do
        expect(subject.name).to eq('clearlinux')
        expect(subject.family).to eq('clearlinux')
        expect(subject.version).to eq('26290')
      end
    end
  end
end
