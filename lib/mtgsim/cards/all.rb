require_relative "card"

require_relative "./creatures/creature"
Dir[File.dirname(__FILE__) + '/creatures/*.rb'].each do |file|
  require file
end

require_relative "./lands/land"
Dir[File.dirname(__FILE__) + '/lands/*.rb'].each do |file|
  require file
end