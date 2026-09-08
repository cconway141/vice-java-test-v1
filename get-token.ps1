param([Parameter(Mandatory = $true)][string]$Username)

$body = @{
  grant_type = "password"
  client_id  = "homebuilder-api"
  username   = $Username
  password   = "password"
}
$r = Invoke-RestMethod -Method Post -Uri "http://localhost:8081/realms/homebuilder/protocol/openid-connect/token" -Body $body
$r.access_token
