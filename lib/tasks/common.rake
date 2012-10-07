
task :repair_directories do
  User.all.each do |user|
    puts "User: #{user.login}"
    user.nodes.repair_directories
  end
end
