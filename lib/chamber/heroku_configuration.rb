require 'bundler'

class  Chamber
class  HerokuConfiguration
  attr_accessor :heroku_application,
                :variables

  def initialize(options = {})
    self.heroku_application = options.fetch(:app,       false)
    self.variables          = options.fetch(:variables, {})
  end

  def push
    heroku("config:set #{variable_pairs}")
  end

  def heroku(command)
    with_app = heroku_application ? " --app #{heroku_application}" : ""

    Bundler.with_clean_env { system("heroku #{command}#{with_app}") }
  end

  private

  def variable_pairs
    pairs = []

    variables.each_pair do |key, value|
      pairs << "#{key.to_s.upcase}=#{value}"
    end

    pairs.join(' ')
  end
end
end