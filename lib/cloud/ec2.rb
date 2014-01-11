module Cloud
  class EC2
  
    def initialize
      @connection = Fog::Compute.new({
        :provider                 => 'AWS'
      })
      #@connection = Fog::Compute.new({
      #  :provider                 => 'AWS',
      #  :aws_access_key_id        => 'ACCESS_KEY',
      #  :aws_secret_access_key    => 'SECRET_KEY'
      #})
    end
    
    def create(args)
      host = args[0]
      type = args[1] ? args[1] : "t1.micro"
      ami = args[2] ? args[2] : "ami-ef5ff086"
      keys = args[3] ? args[3] : "johan-us-east"
      server = @connection.run_instances(ami, 1, 1, 'InstanceType' => type, 'KeyName' => keys)
      id = server.body['instancesSet'].first['instanceId']
      tags = @connection.create_tags(id, 'Name' => fqdn(host))
      server.inspect
    end
    
    def terminate(host)
      @connection.terminate_instances(getinstance(host)).inspect
    end
    
    def start(host)
      @connection.start_instances(getinstance(host)).inspect
    end
    
    def stop(host)
      @connection.stop_instances(getinstance(host)).inspect
    end
    
    def publicip(host, ip)
      @connection.associate_address(getinstance(host),ip).inspect
    end
    
    def getinstance(host)
      instances = @connection.describe_instances.body
      instances['reservationSet'].each do |instance|
        return instance['instancesSet'].first['instanceId'] if instance['instancesSet'].first['tagSet']['Name'] == fqdn(host)
      end
    end
    
    def fqdn(host)
      host+".hostedpuppet.net"
    end
    
    def describe
      instances = @connection.describe_instances.body
      output = Array.new
      output[output.length] = ['name', 'type', 'state', 'ipaddress']
      instances['reservationSet'].each do |instance|
        x = instance['instancesSet'].first
        name = x['tagSet']['Name']
        type = x['instanceType']
        state = x['instanceState']['name']
        ipaddress = x['ipAddress']
        output[output.length] = [name, type, state, ipaddress]
      end
      return output
    end
  
  end # class EC2
end # module Cloud
