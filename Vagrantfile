# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64-audio"
  config.vm.box_url = "https://www.dropbox.com/s/lw1tmmt1xdp0wea/precise64-audio.box"
  config.vm.forward_port 3000, 4000
  config.vm.share_folder "music", "/music", "~/Music/iTunes/iTunes\ Media/Music"
  config.vm.share_folder "radiodan", "/radiodan", "~/Code/radiodan"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "radiodan.pp"
  end
end

