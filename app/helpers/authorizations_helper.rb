module AuthorizationsHelper
  def scope_name(path)
    if path.empty?
      "All data"
    else
      path.capitalize
    end
  end
end
