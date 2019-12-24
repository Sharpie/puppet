require 'spec_helper'

require 'puppet_spec/files'
require 'puppet/util/resplayer'

require 'pry'

describe Puppet::Util::Resplayer do
  subject { described_class }

  before(:each) do
    Puppet[:resplay_file] = PuppetSpec::Files.tmpfile('resplay')
  end

  context 'when fetchng splay values' do
    it 'returns file content as an integer' do
      File.write(Puppet[:resplay_file], '42')

      expect(subject.get).to eq(42)
    end

    it 'returns nil if the resplay_file does not exist' do
      File.unlink(Puppet[:resplay_file]) if File.exist?(Puppet[:resplay_file])

      expect(subject.get).to be_nil
    end

    it 'logs an error and returns nil if resplay_file does not contain an integer' do
      File.write(Puppet[:resplay_file], 'majestik møøse')

      expect(Puppet).to receive(:log_exception).with(instance_of(ArgumentError),
                                                     /Could not read an integer value from resplay_file/)

      expect(subject.get).to be_nil
    end

    it 'logs an error and returns nil if resplay_file is not readable' do
      File.write(Puppet[:resplay_file], '42')
      File.chmod(0200, Puppet[:resplay_file])

      expect(Puppet).to receive(:log_exception).with(kind_of(SystemCallError),
                                                     /Could not read an integer value from resplay_file/)

      expect(subject.get).to be_nil
    end
  end

  context 'when setting splay values' do
    it 'replaces resplay_file in an atomic fashion' do
      File.write(Puppet[:resplay_file], '42')

      File.open(Puppet[:resplay_file], 'r') do |fh|
        subject.set(50)

        expect(fh.read).to eq('42')
      end
    end

    it 'logs an error if called with a non-integer argument' do
      expect(Puppet).to receive(:log_exception).with(kind_of(ArgumentError),
                                                     /Could not store value in resplay_file/)

      subject.set('threeve')
    end

    it 'logs an error if resplay_file is not writable' do
      Puppet[:resplay_file] = '/does/not/exist'

      expect(Puppet).to receive(:log_exception).with(kind_of(SystemCallError),
                                                     /Could not store value in resplay_file/)

      subject.set(42)
    end
  end
end
