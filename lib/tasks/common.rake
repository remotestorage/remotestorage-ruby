
task :repair_directories => :environment do
  User.all.each do |user|
    puts "User: #{user.login}"
    user.nodes.repair_directories
  end
end
