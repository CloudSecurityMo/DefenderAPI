# Set your Tenant ID, App ID, and Client Secret
$tenantId = ''
$appId = ''
$appSecret = ''

# Get the access token
$resourceAppIdUri = 'https://api.securitycenter.microsoft.com'
$oAuthUri = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$authBody = @{
    resource = $resourceAppIdUri
    client_id = $appId
    client_secret = $appSecret
    grant_type = 'client_credentials'
}

$authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
$token = $authResponse.access_token

# Set the API endpoint for recommendations
$url = "https://api.securitycenter.microsoft.com/api/recommendations"

# Set the request headers
$headers = @{
    'Content-Type' = 'application/json'
    Accept = 'application/json'
    Authorization = "Bearer $token"
}

# Send the request and get the response
$response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop

# Extract the recommendations from the response
$recommendations = $response.value

# Export the recommendations to a CSV file
$outputPath = "Defender_Recommendations.csv"
$recommendations | Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "Recommendations exported to $outputPath"
