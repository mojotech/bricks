if defined?(ActiveRecord)
  require 'bricks/adapters/active_record'
else
  Rails.logger.warn "No suitable Brick adapter found."
end
