Write-Host $Env:BUILD_SOURCEBRANCH

$isTag = [regex]::IsMatch($Env:BUILD_SOURCEBRANCH, "^(refs\/tags\/)")
if($isTag)
{
    $Env:GIT_TAG = $Env:BUILD_SOURCEBRANCH.Split("/refs/tags")[-1]
}
