#include all middleware in our middleware directory
#it appears that the autoloader isn't yet running at this stage, so we're just
#doing a simple autoload approach
include_path = Rails.root.join('lib', 'middleware')
Dir.entries(include_path).select {|entry| entry.match(/rb$/)}.each do |entry|
  require "#{include_path}/#{entry}"
end

#inserts our custom rack middleware
Persimmon::Application.configure do
  config.middleware.use(QuerySessionizer)
end
