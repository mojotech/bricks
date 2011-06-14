require 'bricks'
require 'active_record'

module Bricks
  module Adapters
    module ActiveRecord
      def association?(name)
        @class.reflect_on_association(name.to_sym)
      end

      def association(name)
        @class.reflect_on_association(name.to_sym)
      end

      Bricks::Builder.send(:include, self)
    end
  end
end
