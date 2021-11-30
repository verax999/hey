function dump {
    [CmdletBinding()]
    [OutputType([psobject])]
    param([string]$UserName,
    [string]$SearchTerm,
    [string]$UrlRegex = '(htt(p|ps))://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?',
    [string]$UserExpression = '$(Split-Path -Path $(Resolve-Path -Path "$_\..\..\..\..\..\..\..") -Leaf)')
    
    begin {}
        process {
        	Resolve-Path -Path "$env:SystemDrive\Users\*\AppData\Local\Google\Chrome\User Data\Default\History" | Where-Object { $($UserExpression | Invoke-Expression) -match $UserName } | ForEach-Object {

		        $SourceFile = $_

		        $UserProfile = $($UserExpression | Invoke-Expression)

		        Get-Content -Path $SourceFile |

		        Select-String -Pattern $UrlRegex -AllMatches |

		        ForEach-Object { ($_.Matches).Value } |

		        Sort-Object -Unique |

            	ForEach-Object {
            	
            	$EachUrl = $_

		        $DomainName = $EachUrl -replace 'http:\/\/','' -replace 'https:\/\/','' -replace '\/.*',''

		        New-Object -TypeName psobject -Property @{  UserName = $UserProfile
															Url = $_
                                                            ComputerName = $env:COMPUTERNAME
                                                            Browser = 'Chrome'
                                                            DomainName = $DomainName }
                }

            } | Where-Object { $_.Url -match $SearchTerm }
        }
    end {}
}

dump > $pwd\a.txt
