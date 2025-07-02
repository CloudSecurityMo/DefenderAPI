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

# Create a new array to store the modified recommendations
$modifiedRecommendations = @()

foreach ($recommendation in $recommendations) {
    # Get exposed devices for each recommendation
    $exposedDevicesUrl = "https://api.securitycenter.microsoft.com/api/recommendations/$($recommendation.id)/machineReferences"
    $exposedDevices = Invoke-RestMethod -Method Get -Uri $exposedDevicesUrl -Headers $headers -ErrorAction Stop

    # Check the number of exposed devices
    if ($exposedDevices.value.Count -ge 1000) {
        $exposedDevicesList = "More than 1000 devices"
    } else {
        # Create a comma-separated list of exposed device names
        $exposedDevicesList = ($exposedDevices.value | ForEach-Object { $_.computerDnsName }) -join ', '
    }

    # Create a custom object with only the specified properties
    $customRecommendation = [PSCustomObject]@{
        ProductName = $recommendation.productName
        RecommendationName = $recommendation.recommendationName
        Weaknesses = ($recommendation.weaknesses -join ', ')
        RecommendationCategory = $recommendation.recommendationCategory
        Subcategory = $recommendation.subCategory
        RemediationType = $recommendation.remediationType
        ExposedMachinesCount = $recommendation.exposedMachinesCount
        ExposedDevices = $exposedDevicesList
    }

    $modifiedRecommendations += $customRecommendation
}

# Export the modified recommendations to a CSV file
$outputPath = "Enter Path here"
$modifiedRecommendations | Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "Simplified recommendations exported to $outputPath"
