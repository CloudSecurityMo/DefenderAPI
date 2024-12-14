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

# Export to CSV
$csvOutputPath = "C:\Users\mohamed.elmi\Downloads\Defender_Recommendations_Simplified.csv"
$modifiedRecommendations | Export-Csv -Path $csvOutputPath -NoTypeInformation

# Export to HTML
$htmlOutputPath = "C:\Users\mohamed.elmi\Downloads\Defender_Recommendations_Simplified.html"
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Microsoft Defender Recommendations Report</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 1600px; margin: auto; padding: 20px; }
        h1 { color: #f7630c; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; box-shadow: 0 0 20px rgba(0, 0, 0, 0.15); }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f7630c; color: white; text-transform: uppercase; }
        tr:nth-child(even) { background-color: #f8f8f8; }
        tr:hover { background-color: #fff1e6; }
    </style>
</head>
<body>
    <h1>Microsoft Defender Recommendations Report</h1>
    $($modifiedRecommendations | ConvertTo-Html -Fragment)
</body>
</html>
"@

$htmlContent | Out-File -FilePath $htmlOutputPath -Encoding UTF8

Write-Host "Simplified recommendations exported to CSV: $csvOutputPath"
Write-Host "Simplified recommendations exported to HTML: $htmlOutputPath"
