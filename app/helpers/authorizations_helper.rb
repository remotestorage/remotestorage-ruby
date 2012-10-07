module AuthorizationsHelper
  def scope_name(path)
    if path.empty?
      "all data"
    else
      path
    end
  end
end
