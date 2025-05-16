function Get-ADComputerBitLockerRecoveryPassword {
    [CmdletBinding(DefaultParameterSetName='LastSet')]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory= $true, ValueFromPipeline = $true)]
        [Object]$Name,

        [Parameter(Mandatory = $true ,ValueFromPipeline = $true, ParameterSetName='AllSet')]
        [Switch]$All,

        [Parameter(Mandatory = $false)]
        [String]$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().Name
    )

    begin {
        $splat = @{
            'Server' = $Domain
        }
    }

    process {
        $objects = @()
        
        try {
            $Name = Get-ADComputer -Identity $Name @splat -ErrorAction Stop
        }
        catch {
            Write-Debug ("Cannot find computer with name '{0}'" -f $Name)
        }                

        foreach ($_computer in $Name) {
            $entries = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $_computer.DistinguishedName -Properties 'msFVE-RecoveryPassword','whenCreated' @splat

            if ($PSCmdlet.ParameterSetName -eq 'LastSet') {
                $entries = $entries | Select-Object -Last 1
            }

	        foreach ($_entry in $entries) {
	            if ($null -ne $_entry) {
                    $hash = @{}

		            $passwordId = $_entry.name

                    $hash.Add('Name', $_computer.Name)
                    $hash.Add('DNSHostName', $_computer.DNSHostName)
                    $hash.Add('Domain', $_computer.DNSHostName.Replace(('{0}.' -f $_computer.Name.ToLower()),''))
		            $hash.Add('RecoveryPassword', $_entry.'msFVE-RecoveryPassword')
                    $hash.Add('Id', ($passwordId -split '{')[-1].replace('}',''))
                    $hash.Add('WhenCreated', $_entry.whenCreated)
                        
                    $objects += New-Object -TypeName PSCustomObject -Property $hash
	            }
            }
        }
    }

    end {
        $objects
    }
}