# Europa

*This package is based on [Vaprobash](http://github.com/fideloper/vaprobash) and [Laravel Homestead](http://github.com/laravel/homestead).*

## Prerequisites/Dependencies

Before you get started with setting up the environment, make sure you have [Composer](https://getcomposer.org/doc/00-intro.md), [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed.

Also, if you don't already, make sure composer is installed globally. If you're doing a fresh installation, simply run

~~~
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
~~~

If the `mv` command fails, run it with sudo.

Before getting to setup, make sure `~/.composer/vendor/bin` is in your `PATH`. This can be done by calling  
    PATH=$PATH:~/.composer/vendor/bin

## Setup

Getting yourself up and running with the Europa development box is super easy, it's just a few commands away.

First, install the Europa repository globally by calling  
    composer global require eyp-developers/europa ~1.0

When this is done, the europa commands should be available to you. Now, to get your provisioning settings ready, call    
    europa init

This will place the `.europa` directory in your home folder (~/.europa), which contains the configuration file. To make configuration setup easier for you, there's a command. If you want to change anything regarding the setup, call  
    europa edit
    
In the file, `europa.yaml`, you will find several options. For the complete list of options, please see *Configuration*. Configure to your liking, and be aware that there are more variables you can set than just the ones in the default.

Once you're satisfied with your configuration, you can call  
    europa up
    
For those familiar with Vagrant, this is the same as calling `vagrant up` in the directory of the box. This will set up the database, configure the sites defined in the config, and run a few more provisioners such as installing php 5.6 and git.