## PowerShell Obfuscation Function ##

function Create-Obfuscation{  
   
    ## Create Parameters ##

    param (
    [Parameter(Mandatory, 
    Position=0,
    ValuefromPipeline)]
    [string] $command,
    [Parameter()]
    [switch] $Base64
    )

    ## Start the function with a Begin Block to setup parameters for the script ##

    Begin {

        ## SplitCommand is used to break the cmdlet into parts for more randomness ##

        $splitcommand = $command -split " " 
        $variablename = @()
        $variablecombine = @()
        $outfile = (Join-Path -Path $(Get-Location) -ChildPath 'payload.ps1')
    }

    ## Process Block to run the actual obfuscation methods ##

    Process{

        ## Go through each of the command sections and obfuscates each one in turn ##

        ForEach($splitcommand in $splitcommand){

            ## Create a variable with a random name ##

            $randomvariable = (('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.ToCharArray() | Get-Random -Count (1..25 | Get-Random) | ForEach-Object { $_ }) -join '')
            New-Variable -Name ($randomvariable)

            ## Reverse the command section ##

            $reversevalue = (([regex]::Matches($splitcommand,'.','RightToLeft') | ForEach {$_.value}) -join '')

            ## Convert the reverse section into ASCII ##

            $asciivalue = '$(' + (([int[]][char[]]$reversevalue | ForEach-Object { "[char]$($_)" }) -join '+') + ')'

            ## Add the name of the random variable to a place holder to use later ##

            $variablename +=("$"+ $randomvariable)

            ## Create a vairable that includes the variable name and the ASCII value##

            $payloadoutput += ("$"+ $randomvariable + '=' + $asciivalue + " ;")
            }

        ##Reorder variables so they are in the correct order when run ##

        $count = ($variablename).count

        Foreach($variable in $variablename){ 
            $count = $count - 1 
            $variablecombine += $variablename[($count)] 
        }
        $variable = $variablecombine -join ','

        ## Create a new random variable to use in the final output ##

        $randomvariable = (('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.ToCharArray() | Get-Random -Count (1..25 | Get-Random) | ForEach-Object { $_ }) -join '')
        New-Variable -Name ($randomvariable)

        ## Create the final obfuscated command output ##
        
        $finaloutput =$payloadoutput + "$" + ((Get-Variable -Name ($randomvariable)).Name) + "=" + $variable + " -join ' '; (([regex]::Matches("+ "$" + ((Get-Variable -Name ($randomvariable)).Name) + ",'.','RightToLeft') | ForEach {" + "$" + "_" + ".value}) -join '') " + "| .([char]105 + [char]101 + [char]120)"
    }

    ## Add Base64 encoding if switch is true ##

    End{
        if($Base64){
            $Base64output =[Convert]::ToBase64String([Text.Encoding]::Unicode.getbytes($finaloutput))
            
            ## Write out to outfile ##
            
            $Base64Output | Out-File $Outfile 
        }
        else{

            ## Write out to outfile ##

            $finaloutput | Out-File $Outfile 
        }
    }
}

Create-Obfuscation -Command "Write-Output 'Hello'" -Base64