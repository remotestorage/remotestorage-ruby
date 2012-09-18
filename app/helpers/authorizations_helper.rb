module AuthorizationsHelper
  def scope_name(path)
    if path.empty?
      "All data"
    end
  end
end
