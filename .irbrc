IRB.conf[:SAVE_HISTORY] = 1000

if defined? Rails && Rails.env
  require 'logger'
  logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger = logger if defined? ActiveRecord
  ActiveResource::Base.logger = logger if defined? ActiveResource
end
