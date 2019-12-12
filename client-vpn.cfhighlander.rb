CfhighlanderTemplate do
  Name 'client-vpn'
  Description "client-vpn - #{component_version}"

  Parameters do
    ComponentParam 'EnvironmentName', 'dev'

    ComponentParam 'AssociationSubnetId', type: 'AWS::EC2::Subnet::Id'
    ComponentParam 'ClientCidrBlock', '10.250.0.0/16',
        description: 'The IPv4 address range, in CIDR notation, from which to assign client IP addresses.'
    ComponentParam 'DnsServers', '',
        description: 'Set a comma delimated string of dns server IPs'
    ComponentParam 'SplitTunnel', 'false', allowedValues: ['true','false'], 
        description: 'If true split tunnel only pushes the routes on the vpn. If false the vpn will push a default which overwrites the client route table with the entry 0.0.0.0/0 to route all traffic over the VPN.'
    ComponentParam 'InternetRoute', 'true', allowedValues: ['true','false'], 
        description: 'create a default route to the internet'
    ComponentParam 'Protocol', 'udp', allowedValues: ['udp','tcp'],
        description: 'set the protocol for the vpn connections'
    ComponentParam 'ClientCertificateArn', 
        description: 'arn of the acm imported client certificate'
    ComponentParam 'ServerCertificateArn', 
        description: 'arn of the acm imported server certificate'
  end

end
