CloudFormation do

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
    # DnsServers([ "8.8.8.8" ])
    ServerCertificateArn Ref(:ServerCertificateArn)
    TagSpecifications([{
      ResourceType: "client-vpn-endpoint",
      Tags: [
        { Key: 'Name', Value: FnSub("${EnvironmentName}") }
      ]
    }])
    TransportProtocol protocol
  }

  EC2_ClientVpnTargetNetworkAssociation(:ClientVpnTargetNetworkAssociation) {
    ClientVpnEndpointId Ref(:ClientVpnEndpoint)
    SubnetId Ref(:AssociationSubnetId)
  }

  if route_to_internet
    EC2_ClientVpnRoute(:RouteToInternet) {
      Description 'Route to the internet'
      ClientVpnEndpointId Ref(:ClientVpnEndpoint)
      DestinationCidrBlock '0.0.0.0/0'
      TargetVpcSubnetId Ref(:AssociationSubnetId)
    }

    EC2_ClientVpnAuthorizationRule(:RouteToInternetAuthorizationRule) {
      Description 'Route to the internet'
      AuthorizeAllGroups true
      ClientVpnEndpointId Ref(:ClientVpnEndpoint)
      TargetNetworkCidr '0.0.0.0/0'
    }
  end

end
