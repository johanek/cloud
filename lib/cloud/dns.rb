module Cloud
  class DNS
  
    def initialize
      @dns = Fog::DNS.new({
        :provider     => 'Zerigo',
      })
      #@dns = Fog::DNS.new({
      #  :provider     => 'Zerigo',
      #  :zerigo_email => 'EMAIL',
      #  :zerigo_token => 'TOKEN'
      #})
    end
    
    def add(host, ip)
      zone = @dns.zones.get('johan.org.uk')
      record = zone.records.create(
        :value => ip,
        :name  => host,
        :type  => 'A',
        :ttl   => '900'
      )
      record.inspect
    end
    
    def del(host)
      fqdn = "#{host}.johan.org.uk"
      recordid = @dns.find_hosts(fqdn).body['hosts'].first['id']
      result = @dns.delete_host(recordid)
      result.headers.inspect
    end
  
  
  end # Class DNS
end # Module Cloud
