require 'hashie/mash'

module  Chamber
module  Filters
class   TranslateSecureKeysFilter
  def initialize(options = {})
    self.data = options.fetch(:data).dup
  end

  def self.execute(options = {})
    new(options).send(:execute)
  end

  protected

  attr_accessor :data

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      value = execute(value) if value.respond_to? :each_pair
      key   = key.to_s
      key   = key.sub(SECURE_KEY_TOKEN, '') if key.match(SECURE_KEY_TOKEN)

      settings[key] = value
    end

    settings
  end
end
end
end
