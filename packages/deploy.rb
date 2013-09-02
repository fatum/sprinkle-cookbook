package :deploy, :provides => :deployer do
  description 'Create deploy user'

  requires :create_deploy_user, :add_deploy_ssh_keys, :set_permissions
end

package :create_deploy_user do
  description "Create the deploy user"
  user = fetch(:user)

  runner "useradd --create-home --shell /bin/bash --user-group --groups users,sudo #{user}"

  verify do
    has_directory "/home/#{user}"
  end
end

package :add_deploy_ssh_keys_for_root do
  id_rsa_pub = `cat ~/.ssh/id_rsa.pub`
  authorized_keys_file = "/root/.ssh/authorized_keys"

  push_text id_rsa_pub, authorized_keys_file
end

package :add_deploy_ssh_keys do
  description "Add deployer public key to authorized ones"
  requires :create_deploy_user
  requires :add_deploy_ssh_keys_for_root

  user = fetch(:user)

  id_rsa_pub = `cat ~/.ssh/id_rsa.pub`
  authorized_keys_file = "/home/#{user}/.ssh/authorized_keys"

  push_text id_rsa_pub, authorized_keys_file do
    # Ensure there is a .ssh folder.
    pre :install, "mkdir -p /home/#{user}/.ssh"
  end

  #verify do
    # not working! oO
  #  file_contains authorized_keys_file, id_rsa_pub
  #end
end

package :set_permissions do
  user = fetch(:user)

  description "Set correct permissons and ownership"
  requires :add_deploy_ssh_keys

  noop do
    ## hook does not work in :add_deploy_ssh_keys
    pre :install, "mkdir -p /home/#{user}/.ssh"
  end

  runner "chmod 0700 /home/#{user}/.ssh"
  runner "chown -R #{user}:#{user} /home/#{user}/.ssh"
  runner "chmod 0700 /home/#{user}/.ssh/authorized_keys"

  runner "chown -R #{user}:#{user} /srv"
end
