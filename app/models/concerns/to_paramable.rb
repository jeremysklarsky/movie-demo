module ToParamable

  def to_param
    self.slug
  end

  def slugify
    self.slug = self.name.gsub(".", "").gsub(" ", "-").downcase
  end

end