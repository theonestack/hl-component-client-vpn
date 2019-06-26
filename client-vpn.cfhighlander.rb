CfhighlanderTemplate do
  Name 'client-vpn'
  Description "client-vpn - #{component_version}"

  Parameters do
    ComponentParam 'EnvironmentName', 'dev'

    ComponentParam 'AssociationSubnetId', type: 'AWS::EC2::Subnet::Id'
    ComponentParam 'ClientCidrBlock', '10.250.0.0/16', description: 'The IPv4 address range, in CIDR notation, from which to assign client IP addresses.'
    ComponentParam 'DnsServers', ''

    ComponentParam 'ClientCertificateArn', description: 'arn of the acm imported client certificate'
    ComponentParam 'ServerCertificateArn', description: 'arn of the acm imported server certificate'

  end

end
