require 'spec_helper'

describe Ohey do
  describe '#current_platform' do
    before do
      allow(Ohey).to receive(:os).and_return(:linux)
    end

    it 'returns the registered platform' do
      expect(Ohey.current_platform).to be_a(Ohey::Linux)
    end
  end

  describe '#register_platform' do
    it 'registers the platform' do
      Ohey.register_platform(:foo, :foo)
      expect(Ohey.registered_platforms).to include(:foo)
    end
  end
end
