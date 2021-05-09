$:.push(File.expand_path('.', __dir__))

require 'ohey'
require 'pry-byebug'

module SpecHelpers
end

RSpec.configure do |config|
  config.include(SpecHelpers)

  # config.before do
  #   Ohey.registered_platforms.dup.each do |name, klass|
  #     Ohey.register_platform(name, klass.new)
  #   end
  # end
end
