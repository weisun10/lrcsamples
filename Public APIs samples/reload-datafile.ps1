$tenantId = "652261341"
$projectId = 117
$dataFileId = 11
$dataFile = "data file 2.zip"
$SRL = "https://loadrunner-cloud.saas.microfocus.com"
$loginUrl = "$SRL/v1/auth?TENANTID=$tenantId"
$reloadScriptUrl="$SRL/v1/projects/$projectId/data-files/$dataFileId/file?TENANTID=$tenantId"

# credentials for login
$credentials = '{ 
           "user": "<YOUR USERNAME>",
           "password": "<YOUR PASSWORD>"
         }'

Write-host "tenant Id: $tenantId"
Write-host "project Id: $projectId"

# if proxy is required to access Internat
$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

# create session and send login request
$session = new-object microsoft.powershell.commands.webrequestsession
$proxyUri = $proxy.GetProxy($loginUrl)

Write-host "login"
$response = Invoke-RestMethod -Headers $hdrs -Uri $loginUrl -Method Post -Body $credentials -WebSession $session -Proxy $proxyUri -ProxyUseDefaultCredentials -ContentType 'application/json' 
#Write-host $response
if ($response.token.Length -le 0)
{
    Write-Host "Failed to Login !!"
    throw    
}

$token = $response.token

# add token into session cookie
$cookie = new-object system.net.cookie
$cookie.name = "LWSSO_COOKIE_KEY"
$cookie.value = $token
$cookie.domain = "loadrunner-cloud.saas.microfocus.com"
$session.Cookies.Add($cookie)

Add-Type -AssemblyName System.Net.Http
$httpClientHandler = New-Object System.Net.Http.HttpClientHandler
$httpClientHandler.UseCookies = false

$httpClient = New-Object System.Net.Http.HttpClient $httpClientHandler
$contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
$contentDispositionHeaderValue.Name = "file"
$contentDispositionHeaderValue.FileName = $dataFile

$fileStream = New-Object System.IO.FileStream @($dataFile, [System.IO.FileMode]::Open)
$streamContent = New-Object System.Net.Http.StreamContent $fileStream
$streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
$streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue "application/octetstream"
$content = New-Object System.Net.Http.MultipartFormDataContent
$content.Add($streamContent)

$httpClient.DefaultRequestHeaders.Add("Cookie", "LWSSO_COOKIE_KEY=$token");

try
{
  Write-Host "going to reload data #$dataFileId with file: '$dataFile'"
  Write-Host $reloadScriptUrl
  $response = $httpClient.PutAsync($reloadScriptUrl, $content).Result
  Write-Host $response.Content.ReadAsStringAsync().Result
  #Write-Host "$response"
}
catch [Exception]
{
  Write-Host "got exception"
}
