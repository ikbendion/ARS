# Check if Azure CLI is installed
if (Get-Command az -ErrorAction SilentlyContinue) {
    # Clear all known sessions
    az account clear
} else {
    # Install Azure CLI
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile install-az-cli.ps1
    Start-Process -Wait -FilePath powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File install-az-cli.ps1"
    Remove-Item -Path install-az-cli.ps1
}

# Set the roles directory
$rolesDirectory = "roles"

# Print the banner
Write-Host "     _                          ____       _      ____                   
    / \    _____   _ _ __ ___  |  _ \ ___ | | ___/ ___| _   _ _ __   ___ 
   / _ \  |_  / | | | '__/ _ \ | |_) / _ \| |/ _ \___ \| | | | '_ \ / __|
  / ___ \  / /| |_| | | |  __/ |  _ < (_) | |  __/___) | |_| | | | | (__ 
 /_/   \_\/___|\__,_|_|  \___| |_| \_\___/|_|\___|____/ \__, |_| |_|\___|
                                                        |___/            " -ForegroundColor Cyan
Write-Host "Azure Custom Role Updater // @ikbendion 2024" -ForegroundColor Green

# Sign in to Azure using an app registration
$appId = $env:ClientId
$tenantId = $env:TenantId
$clientSecret = $env:ClientSecret
az login --service-principal -u $AppId -p $clientSecret --tenant $tenantId

# Get the list of subscriptions
$subscriptions = az account list --query "[].id" -o tsv

# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    Write-Host "Processing subscription: $($subscription)"

    # Set the current subscription
    az account set --subscription $subscription

    # Get the list of custom roles
    $customRoles = az role definition list --custom-role-only --query "[].roleName" -o tsv

    # Iterate through each role in the roles directory
    foreach ($roleFile in Get-ChildItem -Path $rolesDirectory -Filter "*.json") {
        $roleDefinition = Get-Content -Path $roleFile.FullName -Raw | ConvertFrom-Json

        # Get the role name from the JSON
        $roleName = $roleDefinition.Name

        # Check if the role exists in the current subscription
        if ($customRoles -contains $roleName) {
            Write-Host "Role '$roleName' exists in subscription: $subscription"

            # Get the current role definition from Azure
            $currentRoleDefinition = az role definition list --name $roleName --query "[0]" -o json | ConvertFrom-Json

            # Compare the permissions of the source and current role definitions
            if ($roleDefinition.properties.permissions -ne $currentRoleDefinition.permissions) {
                Write-Host "Updating permissions for role '$roleName' in subscription: $subscription"
                az role definition update --role-definition $roleFile.FullName
            } else {
                Write-Host "Permissions for role '$roleName' in subscription: $subscription are up to date"
            }
        } else {
            Write-Host "Role '$roleName' does not exist in subscription: $subscription"

            # Create the custom role
            az role definition create --role-definition $roleFile.FullName

            Write-Host "Custom role '$roleName' created in subscription: $subscription"
        }
    }
}