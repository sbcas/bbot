# the class all plugins extend
class IrbotPlugin
  def usage
    ''
  end

  def match?(cmd)
    false
  end
end
