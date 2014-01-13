require 'pathname'
require 'yaml'
require 'erb'

###
# Internal: Represents a single file containing settings information in a given
# file set.
#
module  Chamber
class   File < Pathname

  ###
  # Internal: Creates a settings file representing a path to a file on the
  # filesystem.
  #
  # Optionally, namespaces may be passed in which will be passed to the Settings
  # object for consideration of which data will be parsed (see the Settings
  # object's documentation for details on how this works).
  #
  # Examples:
  #
  #   ###
  #   # It can be created by passing namespaces
  #   #
  #   settings_file = Chamber::File.new path:       '/tmp/settings.yml',
  #                                     namespaces: {
  #                                       environment: ENV['RAILS_ENV'] }
  #   # => <Chamber::File>
  #
  #   settings_file.to_settings
  #   # => <Chamber::Settings>
  #
  #   ###
  #   # It can also be created without passing any namespaces
  #   #
  #   Chamber::File.new path: '/tmp/settings.yml'
  #   # => <Chamber::File>
  #
  def initialize(options = {})
    self.namespaces     = options[:namespaces] || {}
    self.decryption_key = options[:decryption_key]
    self.encryption_key = options[:encryption_key]

    super options.fetch(:path)
  end

  ###
  # Internal: Extracts the data from the file on disk.  First passing it through
  # ERB to generate any dynamic properties and then passing the resulting data
  # through YAML.
  #
  # Therefore if a settings file contains something like:
  #
  # ```erb
  # test:
  #   my_dynamic_value: <%= 1 + 1 %>
  # ```
  #
  # then the resulting settings object would have:
  #
  # ```ruby
  # settings[:test][:my_dynamic_value]
  # # => 2
  # ```
  #
  def to_settings
    @data ||= Settings.new(settings:        file_contents_hash,
                           namespaces:      namespaces,
                           decryption_key:  decryption_key,
                           encryption_key:  encryption_key)
  end

  def secure
    secure_settings = to_settings.secure

    ::File.open(self, 'w') { |file| file.write YAML.dump(secure_settings.to_hash) }
  end

  protected

  attr_accessor :namespaces,
                :decryption_key,
                :encryption_key

  private

  def file_contents_hash
    file_contents = self.read
    erb_result    = ERB.new(file_contents).result

    YAML.load(erb_result) || {}
  rescue Errno::ENOENT
    {}
  end
end
end
