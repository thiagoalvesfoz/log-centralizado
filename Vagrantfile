cluster = {
  "graylog" => { 
    :box_image => "generic/ubuntu1804", 
    :ip => "172.30.0.200", 
    :mem => 4096,
    :cpus => 2,
    :script => "./install.sh",
    :file => "./server.conf",
    :graylog_password => "admin@123"
  },
}

Vagrant.configure("2") do |config|
  
    cluster.each do |hostname, info| 

        config.vm.define hostname do |cfg|

            cfg.vm.box = info[:box_image]
            cfg.vm.box_check_update = false
            cfg.vm.network :private_network, ip: info[:ip]

            cfg.vm.provider :virtualbox do |vb, override|
                vb.name = hostname
                vb.memory = info[:mem] if info[:mem]
                vb.cpus = info[:cpus] if info[:cpus]
            end 
            
            cfg.vm.provision :file,  source: info[:file], destination: "/tmp/graylog/server.conf"
            cfg.vm.provision :shell, path: info[:script], :args => info[:graylog_password];
        end #end config
    end #end cluster each
end #end vagrant