require 'digest'

CloudFormation do

  Condition(:DnsSet, FnNot(FnEquals(Ref(:DnsServers), '')))

  Logs_LogGroup(:ClientVpnLogGroup) {
    LogGroupName FnSub("${EnvironmentName}-ClientVpn")
    RetentionInDays 30
  }

  EC2_ClientVpnEndpoint(:ClientVpnEndpoint) {
    Description FnSub("${EnvironmentName} Client Vpn")
    AuthenticationOptions([
      {
        MutualAuthentication: {
          ClientRootCertificateChainArn: Ref(:ClientCertificateArn)
        },
        Type: 'certificate-authentication'
      }
    ])
    ClientCidrBlock Ref(:ClientCidrBlock)
    ConnectionLogOptions({
      CloudwatchLogGroup: Ref(:ClientVpnLogGroup),
      Enabled: true
    })
    ServerCertificateArn Ref(:ServerCertificateArn)
    DnsServers FnIf(:DnsSet, FnSplit(',', Ref(:DnsServers)), Ref('AWS::NoValue'))
    TagSpecifications([{
      ResourceType: "client-vpn-endpoint",
      Tags: [
        { Key: 'Name', Value: FnSub("${EnvironmentName}") }
      ]
    }])
    TransportProtocol Ref(:Protocol)
    SplitTunnel Ref(:SplitTunnel)
  }

  EC2_ClientVpnTargetNetworkAssociation(:ClientVpnTargetNetworkAssociation) {
    ClientVpnEndpointId Ref(:ClientVpnEndpoint)
    SubnetId Ref(:AssociationSubnetId)
  }

  Condition(:EnableRouteToInternet, FnEquals(Ref(:InternetRoute), 'true'))

  EC2_ClientVpnRoute(:RouteToInternet) {
    Condition :EnableRouteToInternet
    DependsOn :ClientVpnTargetNetworkAssociation
    Description 'Route to the internet'
    ClientVpnEndpointId Ref(:ClientVpnEndpoint)
    DestinationCidrBlock '0.0.0.0/0'
    TargetVpcSubnetId Ref(:AssociationSubnetId)
  }

  EC2_ClientVpnAuthorizationRule(:RouteToInternetAuthorizationRule) {
    Condition :EnableRouteToInternet
    DependsOn :ClientVpnTargetNetworkAssociation
    Description 'Route to the internet'
    AuthorizeAllGroups true
    ClientVpnEndpointId Ref(:ClientVpnEndpoint)
    TargetNetworkCidr '0.0.0.0/0'
  }

  routes = external_parameters.fetch(:routes, [])
  routes.each do |route|
    EC2_ClientVpnRoute("#{Digest::MD5.hexdigest(route['cidr'])}Route") {
      DependsOn :ClientVpnTargetNetworkAssociation
      Description route['desc']
      ClientVpnEndpointId Ref(:ClientVpnEndpoint)
      DestinationCidrBlock route['cidr']
      TargetVpcSubnetId Ref(:AssociationSubnetId)
    }

    EC2_ClientVpnAuthorizationRule("#{Digest::MD5.hexdigest(route['cidr'])}Authorization") {
      DependsOn :ClientVpnTargetNetworkAssociation
      Description route['desc']
      AuthorizeAllGroups true
      ClientVpnEndpointId Ref(:ClientVpnEndpoint)
      TargetNetworkCidr route['cidr']
    }
  end

end
