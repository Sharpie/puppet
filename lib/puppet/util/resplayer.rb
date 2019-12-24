# Tools for re-splaying agent run schedules
#
# This module contains functions for setting and retrieving
# a "resplay" value which is used by Puppet daemons to adjust
# their run schedules.
module Puppet::Util::Resplayer
  require 'puppet/util'
  require 'puppet/file_system'

  def self.get
    if Puppet::FileSystem.exist?(Puppet[:resplay_file])
      value = nil

      begin
        value = Integer(Puppet::FileSystem.read(Puppet[:resplay_file]).chomp)
      rescue StandardError => e
        #TRANSLATORS "resplay_file" is the name of a Puppet setting that should not be translated
        Puppet.log_exception(e, _('Could not read an integer value from resplay_file: %{path}') %
                                {path: Puppet[:resplay_file]})
      end

      value
    else
      nil
    end
  end

  def self.set(seconds)
    unless seconds.kind_of?(Integer)
      raise ArgumentError,
        'Puppet::Util::Resplayer.set must be called with an Integer. Got an argument of type: %{klass}' %
        {klass: seconds.class}
    end

    # TODO: Use Puppet::FileSystem.replace_file in 6.x and drop
    #       puppet/util requirement above.
    Puppet::Util.replace_file(Puppet[:resplay_file], 0644) do |fh|
      fh.write(seconds)
    end
  rescue StandardError => e
    #TRANSLATORS "resplay_file" is the name of a Puppet setting that should not be translated
    Puppet.log_exception(e, _('Could not store value in resplay_file: %{path}') %
                            {path: Puppet[:resplay_file]})
  end

  def self.clear!
    if Puppet::FileSystem.exist?(Puppet[:resplay_file])
      Puppet::FileSystem.unlink(Puppet[:resplay_file])
    end
  rescue StandardError => e
    #TRANSLATORS "resplay_file" is the name of a Puppet setting that should not be translated
    Puppet.log_exception(e, _('Exception raised while clearing resplay_file: %{path}') %
                            {path: Puppet[:resplay_file]})
  end
end
