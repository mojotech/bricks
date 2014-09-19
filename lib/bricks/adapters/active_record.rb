require 'bricks'
require 'active_record'

module Bricks
  module Adapters
    class ActiveRecord
      class Association
        attr_reader :type

        def initialize(klass, kind)
          @class = klass
          @type  = case kind
                   when :belongs_to then                         :parent
                   when :has_many, :has_and_belongs_to_many then :children
                   else "Unknown AR association type: #{kind}."
                   end
        end

        def klass
          @class
        end
      end

      def association?(klass, name, type = nil)
        association(klass, name, type)
      end

      def association(klass, name, type = nil)
        if ar = klass.reflect_on_association(name.to_sym)
          a  = Association.new(ar.klass, ar.macro)

          a if type.nil? || a.type == type
        end
      end

      def find(klass, attrs)
        klass.find(:first, :conditions => attrs)
      end

      Bricks::Builder.adapter = self.new
    end
  end
end
