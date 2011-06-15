require 'bricks'
require 'active_record'

module Bricks
  module Adapters
    module ActiveRecord
      class Association
        attr_reader :type

        def initialize(klass, kind)
          @class = klass
          @type  = case kind
                   when :belongs_to;                         :one
                   when :has_many, :has_and_belongs_to_many; :many
                   else "Unknown AR association type: #{kind}."
                   end
        end

        def klass
          @class
        end
      end

      def association?(name, type = nil)
        association(name, type)
      end

      def association(name, type = nil)
        ar = @class.reflect_on_association(name.to_sym)
        a  = Association.new(ar.klass, ar.macro)

        a if type.nil? || a.type == type
      end

      Bricks::Builder.send(:include, self)
    end
  end
end
