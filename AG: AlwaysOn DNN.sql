New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint Dns 

New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint ActiveDirectoryAndDns 

New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint dns -ManagementPointNetworkType Distributed 


New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint dns -ManagementPointNetworkType Automatic 




New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint ActiveDirectory 


New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint None 



You cannot use the -IgnoreNetwork and -StaticAddress parameters for a failover cluster that was created without an administrative access point. To specify these parameters, the administrative access point for the 
cluster should be of type 'Dns'  or 'ActiveDirectoryAndDns'. 

New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint dns -ManagementPointNetworkType singleton 


New-cluster -Name WIN2K19CLUS -Node SQL12k19,SQL22k19 -staticAddress 10.19.0.7 -NoStorage -AdministrativeAccessPoint ActiveDirectoryAndDns -ManagementPointNetworkType singleton 


ARP provides IP communication within a Layer 2 broadcast domain by mapping an IP address to a MAC address.For example, Host B wants to send information to Host A but does not have the MAC address of Host A in its ARP cache. Host B shoots a broadcast message for all hosts within the broadcast domain to obtain the MAC address associated with the IP address of Host A. All hosts within the same broadcast domain receive the ARP request, and Host A responds with its MAC address.
Ideally a gratuitous ARP request is an ARP request packet where the source and destination IP are both set to the IP of the machine issuing the ARP packet and the destination MAC is set to the broadcast address ff:ff:ff:ff:ff:ff.

New-cluster -Name WIN2K16CLUS -Node NODEONE,NODETWO -staticAddress 10.25.0.7 -NoStorage -AdministrativeAccessPoint Dns  


Get-ClusterGroup "cluster group" |Get-ClusterResource
PS > Add-ClusterResource –Name NewIP –ResourceType “IP Address” –Group “Cluster Group”
