class Hash
  def symbolize_keys
    self.each_with_object({}){|(k,v),memo| memo[k.to_s.to_sym]=v}
  end

  def deep_symbolize_keys
    self.each_with_object({}){|(k,v),memo| memo[k.to_s.to_sym]=(v.is_a?(Hash) ? v.deep_symbolize_keys : v)}
  end
end

