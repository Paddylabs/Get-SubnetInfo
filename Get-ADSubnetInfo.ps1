<#
  .SYNOPSIS
  Gets a list of AD Subnet Objects.

  .DESCRIPTION
  Gets a list of Subnet Objects, their descriptions and which Ad Site they are in.

  .PARAMETER
  None

  .EXAMPLE
  None

  .INPUTS
  None

  .OUTPUTS
  None

  .NOTES
  Author:        Patrick Horne
  Creation Date: 15/08/23
  Requires:      Active Directory Module

  Change Log:
  V1.0:         Initial Development
#>

# Get a list of all dcs in the forest
$DcList = (Get-ADForest).Domains | ForEach-Object { Get-ADDomainController -Discover -DomainName $_ } | ForEach-Object { Get-ADDomainController -Server $_.Name -filter * } | Select-Object Site, Name, Domain

# Get all replication subnets from Sites & Services
$Subnets = Get-ADReplicationSubnet -filter * -Properties * | Select-Object Name, Site, Location, Description

# Create an empty array to build the subnet list
$ResultsArray = @()

# Loop through all subnets
ForEach ($Subnet in $Subnets) {

    If ($null -ne $Subnet.Site) { $SiteName = $Subnet.Site.Split(',')[0].Trim('CN=') }

    $DcInSite = $False
    If ($DcList.Site -Contains $SiteName) { $DcInSite = $True }

    $RA = [PSCustomObject]@{
        Subnet   = $Subnet.Name
        SiteName = $SiteName
        DcInSite = $DcInSite
        SiteLoc  = $Subnet.Location
        SiteDesc = $Subnet.Description
    }
    $ResultsArray += $RA

}

# Export the array as a CSV file
$ResultsArray | Sort-Object Subnet | Export-Csv .\AD-Subnets.csv -NoTypeInformation
