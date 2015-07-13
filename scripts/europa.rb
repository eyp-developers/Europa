class Europa
  def Europa.configure(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

    # Configure Local Variable To Access Scripts From Remote Location
    scriptDir = File.dirname(__FILE__)

    github_url = "../Europa"

# Server Configuration

    hostname        = "eyp.dev"
    public_folder   = "/vagrant"

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Configure The Box
    config.vm.box = "ubuntu/trusty64"
    config.vm.hostname = "europa"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.name = 'europa'
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    end

    # Configure A Few VMware Settings
    ["vmware_fusion", "vmware_workstation"].each do |vmware|
      config.vm.provider vmware do |v|
        v.vmx["displayName"] = "europa"
        v.vmx["memsize"] = settings["memory"] ||= 2048
        v.vmx["numvcpus"] = settings["cpus"] ||= 1
        v.vmx["guestOS"] = "ubuntu-64"
      end
    end

    ####
    # Base items
    ########

    # Provision Base Packages
    server_swap = settings["swap"] ||= 1024
    server_timezone = settings["timezone"] ||= 'UTC'
    config.vm.provision "shell", path: "scripts/base.sh", args: [server_swap, server_timezone]

    # optimize base box
    config.vm.provision "shell", path: "scripts/base_box_optimizations.sh", privileged: true

    # Provision PHP
    php_timezone = server_timezone
    hhvm = settings["hhvm"] ||= "false"
    php_version = settings["php_version"] ||= "5.6"
    config.vm.provision "shell", path: "scripts/php.sh", args: [php_timezone, hhvm, php_version]

    # Provision Vim
    config.vm.provision "shell", path: "scripts/vim.sh"

    ####
    # Web server
    ########

    server_ip = settings["ip"] ||= "192.168.10.10"

    if (settings['nginx'] == 'true')
      # Provision Nginx Base
      config.vm.provision "shell", path: "scripts/nginx.sh", args: [server_ip, public_folder, hostname]
    else
      # Provision Apache Base
      config.vm.provision "shell", path: "scripts/apache.sh", args: [server_ip, public_folder, hostname]
    end

    ####
    # MySQL
    ########

    mysql_user = settings["db_user"] ||= 'europa'
    mysql_root_password = settings["db_password"] ||= 'secret'
    mysql_version = '5.6'
    mysql_enable_remote = 'true'

    config.vm.provision "shell", path: "scripts/mysql.sh", args: [mysql_user, mysql_root_password, mysql_version, mysql_enable_remote]


    # Standardize Ports Naming Schema
    if (settings.has_key?("ports"))
      settings["ports"].each do |port|
        port["guest"] ||= port["to"]
        port["host"] ||= port["send"]
        port["protocol"] ||= "tcp"
      end
    else
      settings["ports"] = []
    end

    # Default Port Forwarding
    default_ports = {
      80   => 8000,
      443  => 44300,
      3306 => 33060,
      5432 => 54320
    }

    # Use Default Port Forwarding Unless Overridden
    default_ports.each do |guest, host|
      unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
        config.vm.network "forwarded_port", guest: guest, host: host
      end
    end

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"]
      end
    end

    # Configure The Public Key For SSH Access
    if settings.include? 'authorize'
      config.vm.provision "shell" do |s|
        s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
        s.args = [File.read(File.expand_path(settings["authorize"]))]
      end
    end

    # Copy The SSH Private Keys To The Box
    if settings.include? 'keys'
      settings["keys"].each do |key|
        config.vm.provision "shell" do |s|
          s.privileged = false
          s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
          s.args = [File.read(File.expand_path(key)), key.split('/').last]
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'folders'
      settings["folders"].each do |folder|
        mount_opts = folder["type"] == "nfs" ? ['actimeo=1'] : []
        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, mount_options: mount_opts
      end
    end

    # Install All The Configured Nginx/Apache Sites
    if settings["nginx"]
      settings["sites"].each do |site|
        config.vm.provision "shell" do |s|
            if (site.has_key?("hhvm") && site["hhvm"])
              s.path = scriptDir + "/serve-hhvm.sh"
              s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
            else
              s.path = scriptDir + "/serve.sh"
              s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
            end
        end
      end
    else
      settings["sites"].each do |site|
        config.vm.provision "shell" do |s|
          s.path = scriptDir + "/serve-apache.sh"
          s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
        end
      end
    end

    # Configure All Of The Configured Databases
    settings["databases"].each do |db|
      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/create-mysql.sh"
        s.args = [db]
      end

#      config.vm.provision "shell" do |s|
#        s.path = scriptDir + "/create-postgres.sh"
#        s.args = [db]
#      end
    end

    # Configure All Of The Server Environment Variables
    if settings.has_key?("variables")
      settings["variables"].each do |var|
        config.vm.provision "shell" do |s|
          s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php5/fpm/php-fpm.conf"
          s.args = [var["key"], var["value"]]
        end

        config.vm.provision "shell" do |s|
            s.inline = "echo \"\n#Set europa environment variable\nexport $1=$2\" >> /home/vagrant/.profile"
            s.args = [var["key"], var["value"]]
        end
      end

      config.vm.provision "shell" do |s|
        s.inline = "service php5-fpm restart"
      end
    end

    # Update Composer On Every Provision
    config.vm.provision "shell" do |s|
      s.inline = "/usr/local/bin/composer self-update"
    end
  end
end
