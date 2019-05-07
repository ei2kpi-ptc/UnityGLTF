Write-Host $Env:BUILD_SOURCEBRANCH

$isTag = [regex]::IsMatch($Env:BUILD_SOURCEBRANCH, "^(refs\/tags\/)")
if($isTag)
{
    $Env:GIT_TAG = $Env:BUILD_SOURCEBRANCH.Split("/refs/tags")[-1]
	Write-Host "This is a Tagged release so setting GIT_TAG env Variable to: $Env:GIT_TAG"
}
else
{
	Write-Host "Not a tagged release so not setting Env:GIT_TAG variable"
}
