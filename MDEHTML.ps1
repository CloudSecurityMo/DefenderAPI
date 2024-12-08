# Set your Tenant ID, App ID, and Client Secret
$tenantId = ''
$appId = ''
$appSecret = ''

# Check if recommendations were retrieved
if (-not $recommendations -or $recommendations.Count -eq 0) {
    Write-Error "No recommendations were retrieved. Please check your permissions and try again."
    exit
}

# Start building the HTML content with a table
$htmlContent = @"
<h1>Microsoft Defender Recommendations Report</h1>
<p>Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
<table>
    <thead>
        <tr>
            <th>Title</th>
            <th>Severity</th>
            <th>Status</th>
            <th>Product Name</th>
            <th>Remediation Type</th>
            <th>Weaknesses</th>
            <th>Category</th>
            <th>SubCategory</th>
            <th>Config Score Impact</th>
            <th>Exposure Impact</th>
            <th>Exposed Machines Count</th>
        </tr>
    </thead>
    <tbody>
"@

foreach ($recommendation in $recommendations) {
    $htmlContent += @"
        <tr>
            <td>$($recommendation.recommendationName)</td>
            <td>$($recommendation.severity)</td>
            <td>$($recommendation.status)</td>
            <td>$($recommendation.productName)</td>
            <td>$($recommendation.remediationType)</td>
            <td>$($recommendation.weaknesses -join ', ')</td>
            <td>$($recommendation.recommendationCategory)</td>
            <td>$($recommendation.subCategory)</td>
            <td>$($recommendation.configScoreImpact)</td>
            <td>$($recommendation.exposureImpact)</td>
            <td>$($recommendation.exposedMachinesCount)</td>
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
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 1600px; margin: auto; padding: 20px; }
        h1 { color: #f7630c; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; box-shadow: 0 0 20px rgba(0, 0, 0, 0.15); }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f7630c; color: white; text-transform: uppercase; }
        tr:nth-child(even) { background-color: #f8f8f8; }
        tr:hover { background-color: #fff1e6; }
        .severity-high { color: #d13438; font-weight: bold; }
        .severity-medium { color: #ff8c00; }
        .severity-low { color: #107c10; }
    </style>
</head>
<body>
$htmlContent
<script>
    document.querySelectorAll('td:nth-child(2)').forEach(cell => {
        if (cell.textContent.toLowerCase() === 'high') {
            cell.classList.add('severity-high');
        } else if (cell.textContent.toLowerCase() === 'medium') {
            cell.classList.add('severity-medium');
        } else if (cell.textContent.toLowerCase() === 'low') {
            cell.classList.add('severity-low');
        }
    });
</script>
</body>
</html>
"@

# Export the HTML document
$outputPath = "./Defender_Recommendations_Report.html"
$htmlDocument | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "HTML report generated at $outputPath"

# Open the HTML report in the default browser
Invoke-Item $outputPath
