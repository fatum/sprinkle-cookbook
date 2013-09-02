package :gems do
  user = fetch(:user)

  %w(whenever).each do |_gem|
    runner "sudo -u #{user} -i gem install #{_gem} --no-rdoc --no-ri"
  end
  runner "sudo -u #{user} -i rbenv rehash"
end
