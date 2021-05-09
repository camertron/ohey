require 'spec_helper'

describe Ohey::Solaris2 do
  subject { described_class.new }

  before do
    allow(subject).to receive(:uname).and_return(uname_x)
    allow(subject).to receive(:release).and_return(release)
    allow(File).to receive(:exist?).with('/sbin/uname').and_return(true)
  end

  describe 'on SmartOS' do
    let(:uname_x) do
      <<~UNAME_X.split("\n")
        System = SunOS
        Node = node.example.com
        Release = 5.11
        KernelID = joyent_20120130T201844Z
        Machine = i86pc
        BusType = <unknown>
        Serial = <unknown>
        Users = <unknown>
        OEM# = 0
        Origin# = 1
        NumCPU = 16
      UNAME_X
    end

    let(:release) do
      ["  SmartOS 20120130T201844Z x86_64\n"]
    end

    describe '#name' do
      it 'correctly identifies the platform' do
        expect(subject.name).to eq('smartos')
      end
    end

    describe '#family' do
      it 'correctly identifies the platform family' do
        expect(subject.family).to eq('smartos')
      end
    end

    describe '#build' do
      it 'correctly identifies the platform build' do
        expect(subject.build).to eq('joyent_20120130T201844Z')
      end
    end

    describe '#version' do
      it 'correctly identifies the platform version' do
        expect(subject.version).to eq('5.11')
      end
    end
  end

  describe 'on Solaris 11' do
    let(:uname_x) do
      <<~UNAME_X.split("\n")
        System = SunOS
        Node = node.example.com
        Release = 5.11
        KernelID = 11.1
        Machine = i86pc
        BusType = <unknown>
        Serial = <unknown>
        Users = <unknown>
        OEM# = 0
        Origin# = 1
        NumCPU = 1
      UNAME_X
    end

    let(:release) do
      ["                             Oracle Solaris 11.1 X86\n"]
    end

    describe '#name' do
      it 'correctly identifies the platform' do
        expect(subject.name).to eq('solaris2')
      end
    end

    describe '#family' do
      it 'correctly identifies the platform family' do
        expect(subject.family).to eq('solaris2')
      end
    end

    describe '#build' do
      it 'correctly identifies the platform build' do
        expect(subject.build).to eq('11.1')
      end
    end

    describe '#version' do
      it 'correctly identifies the platform version' do
        expect(subject.version).to eq('5.11')
      end
    end
  end

  describe 'on OmniOS' do
    let(:uname_x) do
      <<~UNAME_X.split("\n")
        System = SunOS
        Node = omniosce-vagrant
        Release = 5.11
        KernelID = omnios-r151026-673c59f55d
        Machine = i86pc
        BusType = <unknown>
        Serial = <unknown>
        Users = <unknown>
        OEM# = 0
        Origin# = 1
        NumCPU = 1
      UNAME_X
    end

    let(:release) do
      [
        "  OmniOS v11 r151026\n  Copyright 2017 OmniTI Computer "\
        "Consulting, Inc. All rights reserved.\n  Copyright 2018 "\
        "OmniOS Community Edition (OmniOSce) Association.\n  All "\
        "rights reserved. Use is subject to licence terms."
      ]
    end

    describe '#name' do
      it 'correctly identifies the platform' do
        expect(subject.name).to eq('omnios')
      end
    end

    describe '#family' do
      it 'correctly identifies the platform family' do
        expect(subject.family).to eq('omnios')
      end
    end

    describe '#build' do
      it 'correctly identifies the platform build' do
        expect(subject.build).to eq('omnios-r151026-673c59f55d')
      end
    end

    describe '#version' do
      it 'correctly identifies the platform version' do
        expect(subject.version).to eq('151026')
      end
    end
  end

  describe 'on OpenIndiana Hipster' do
    let(:uname_x) do
      <<~UNAME_X.split("\n")
        System = SunOS
        Node = openindiana
        Release = 5.11
        KernelID = illumos-c3e16711de
        Machine = i86pc
        BusType = <unknown>
        Serial = <unknown>
        Users = <unknown>
        OEM# = 0
        Origin# = 1
        NumCPU = 1
      UNAME_X
    end

    let(:release) do
      [
        "             OpenIndiana Hipster 2020.04 (powered by illumos)\n"\
        "        OpenIndiana Project, part of The Illumos Foundation (C) 2010-2020\n"\
        "                        Use is subject to license terms.\n"\
        "                           Assembled 03 May 2020"
      ]
    end

    describe '#name' do
      it 'correctly identifies the platform' do
        expect(subject.name).to eq('openindiana')
      end
    end

    describe '#family' do
      it 'correctly identifies the platform family' do
        expect(subject.family).to eq('openindiana')
      end
    end

    describe '#build' do
      it 'correctly identifies the platform build' do
        expect(subject.build).to eq('illumos-c3e16711de')
      end
    end

    describe '#version' do
      it 'correctly identifies the platform version' do
        expect(subject.version).to eq('2020.04')
      end
    end
  end

  describe 'on OpenIndiana pre-Hipster' do
    let(:uname_x) do
      <<~UNAME_X.split("\n")
        System = SunOS
        Node = openindiana
        Release = 5.11
        KernelID = illumos-cf2fa55
        Machine = i86pc
        BusType = <unknown>
        Serial = <unknown>
        Users = <unknown>
        OEM# = 0
        Origin# = 1
        NumCPU = 2
      UNAME_X
    end

    let(:release) do
      [
        "             OpenIndiana Development oi_151.1.8 (powered by illumos)\n"\
        "        Copyright 2011 Oracle and/or its affiliates. All rights reserved\n"\
        "                        Use is subject to license terms.\n"\
        "                           Assembled 20 July 2013"
      ]
    end

    describe '#name' do
      it 'correctly identifies the platform' do
        expect(subject.name).to eq('openindiana')
      end
    end

    describe '#family' do
      it 'correctly identifies the platform family' do
        expect(subject.family).to eq('openindiana')
      end
    end

    describe '#build' do
      it 'correctly identifies the platform build' do
        expect(subject.build).to eq('illumos-cf2fa55')
      end
    end

    describe '#version' do
      it 'correctly identifies the platform version' do
        expect(subject.version).to eq('151.1.8')
      end
    end
  end
end
