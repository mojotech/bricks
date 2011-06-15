class TestAdapter
  def associations
    @associations ||= {
      :newspaper => {:klass => Newspaper, :type => :one},
      :readers   => {:klass => Reader,    :type => :many}
    }
  end

  def association?(name, type = nil)
    associations[name] &&
      (type.nil? || associations[name][:type] == type)
  end

  def association(name)
    if association?(name)
      OpenStruct.new(associations[name])
    else
      raise "Invalid name: #{name}."
    end
  end
end
