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

try {
    $authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
    $token = $authResponse.access_token
}
catch {
    Write-Error "Failed to obtain access token: $_"
    exit
}

# Set the API endpoint for recommendations
$url = "https://api.securitycenter.microsoft.com/api/recommendations"

# Set the request headers
$headers = @{
    'Content-Type' = 'application/json'
    Accept = 'application/json'
    Authorization = "Bearer $token"
}

# Send the request and get the response
try {
    $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop
    $recommendations = $response.value
}
catch {
    Write-Error "Failed to retrieve recommendations: $_"
    exit
}

# Check if recommendations were retrieved
if (-not $recommendations -or $recommendations.Count -eq 0) {
    Write-Error "No recommendations were retrieved. Please check your permissions and try again."
    exit
}

# Start building the HTML content with a table
$htmlContent = @"
<h1 style="text-align:center; color:#f7630c;">Microsoft Defender Recommendations</h1>
<p style="text-align:center;">Generated on: $(Get-Date -Format 'MMMM d, yyyy HH:mm:ss')</p>
<p style="text-align:center;">Total Recommendations: $($recommendations.Count)</p>
<table style="width:100%; border-collapse:collapse; margin-top:20px;">
    <thead>
        <tr style="background-color:#f7630c; color:white;">
            <th style="padding:12px; border-bottom:1px solid #ddd;">Title</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Status</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Product Name</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Remediation Type</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Weaknesses</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Category</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Config Score Impact</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Exposure Impact</th>
            <th style="padding:12px; border-bottom:1px solid #ddd;">Exposed Machines Count</th>
        </tr>
    </thead>
    <tbody>
"@

foreach ($recommendation in $recommendations) {
    $categoryDisplay = "$($recommendation.recommendationCategory) [$($recommendation.subCategory)]"
    $htmlContent += @"
        <tr>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.recommendationName)</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.status)</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.productName)</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.remediationType)</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.weaknesses -join ', ')</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$categoryDisplay</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.configScoreImpact)</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.exposureImpact)</td>
            <td style="border-bottom: 1px solid #ddd; padding: 8px;">$($recommendation.exposedMachinesCount)</td>
        </tr>
"@
}

$htmlContent += @"
    </tbody>
</table>
"@

# Create the full HTML document
$htmlDocument = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Microsoft Defender Recommendations Report</title>
</head>
<body style="font-family:'Arial', sans-serif;">
$htmlContent
</body>
</html>
"@

# Export the HTML document
$outputPath = "./Defender_Recommendations_Report.html"
$htmlDocument | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "HTML report generated at $outputPath"

# Open the HTML report in the default browser
Invoke-Item $outputPath
