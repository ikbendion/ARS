# Azure RoleSync
Maintain azure custom roles via CI/CD in code.
## Setup
- Fork this repository
- Create a custom role with the following permissions
```json
"Microsoft.Authorization/*/read",
"Microsoft.Authorization/*/write",
"Microsoft.Authorization/roleDefinitions/*"
```
- Create an app registration with a clientSecret
- Create the following github actions secrets
```python
ClientId = Your application id
ClientSecret = Your client Secret
TenantId = Your tenant id
```
- Create role assigments on subscriptions that should be managed to the previously created application.
- Enable GitHub actions runs
## Usage
## Create a role
Use the following template to create a new role.
```json

{
    "Name": "Custom Role Provisioner",
    "IsCustom": true,
    "Description": "Can provision custom roles.",
    "Actions": [
        "Microsoft.Authorization/*/read",
        "Microsoft.Authorization/*/write",
        "Microsoft.Authorization/roleDefinitions/*"
    ],
    "NotActions": [
  
    ],
    "AssignableScopes": [
        "/subscriptions/{YourSubscriptionId}",
        "/subscriptions/{YourSubscriptionId}"
    ]
  }

```
place this template in as a .json file in the ```roles``` directory.
## Update a role
Edit the configuration and commit to repository, role permissions can take up to 1h to process on the azure side.
## Issues and suggestions
Please open an issue describing your input
## License
MIT
