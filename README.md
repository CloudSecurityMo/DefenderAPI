This script automates the process of retrieving security recommendations from Microsoft Defender for Endpoint and presents this data in both HTML and CSV CSV format. This can be particularly useful for security administrators who need to review and act on these recommendations regularly.

To use this script:
1. Replace YOUR_TENANT_ID, YOUR_APP_ID, and YOUR_CLIENT_SECRET with your actual values1

2. Ensure you have the necessary permissions. The application should have the "SecurityRecommendation.Read.All" permission.

3. Run the script in PowerShell. It will generate a CSV/HTML file with all recommendations in the same directory as the script.

4. Note: This script assumes you've already registered an application in Microsoft Entra ID and granted it the appropriate permissions to access the Microsoft Defender for Endpoint API.
