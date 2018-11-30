
$SPNs = Get-Content -Raw -Path spns.json | ConvertFrom-Json


ForEach ($spn in $SPNs.PsObject.Properties.value) {
  Write-Host "SUBSCRIPTION:  $($spn.subscription_id)"
  Write-Host "NAME: $($spn.name)"
  Write-Host "KEYVAULT: $($spn.keyvault)"

  Write-Host "=== SETTING SUBSCRIPTION TO" $spn.subscription_id "==="
  az account set -s $spn.subscription_id
  az account get-access-token -o json
  
  Write-Host "=== ATTEMPTING TO RESET" $spn.name "==="
  $reset_command = "az ad sp credential reset -n $($spn.name) -o json 2>&1"
  try {
    $response = Invoke-Expression -command $reset_command | ConvertFrom-Json
  }
  catch {
    # IF IT CAN'T PARSE JSON WE PROBABLY GOT AN ERROR
    $response = Invoke-Expression -command $reset_command
  }
  
  if ($response -match "can't find a service principal matching") {
    Write-Host "===" $response "==="
    Write-Host "=== CREATING MISSING SPN: $($spn.name) ==="
    $create_command = "az ad sp create-for-rbac --role=`"Contributor`" --scopes=`"/subscriptions/$($spn.subscription_id)`" --name $($spn.name) -o json"
    Write-Host $create_command
    try {
      $response = Invoke-Expression -command $create_command | ConvertFrom-Json
    }
    catch {
      $response = Invoke-Expression -command $create_command
      Write-Host $response
      exit
    }
    
  }
  elseif ($response -match "ERROR") {
    # EXIT IF WE GET AN UNEXPECTED NON-JSON RESPONSE
    Write-Host "UNEXPECTED ERROR?"
    Write-Host $response
    Exit
  }

  Write-Host "=== WRITING SECRETS TO KEYVAULT $($spn.keyvault) ==="
  write-host $response
  # Write-Host $response.appId
  $id = "$($spn.name)-ID"
  Write-Host "== $id =="
  az keyvault secret set --vault-name $spn.keyvault --name $id --value $response.appId
  $secret = "$($spn.name)-SECRET"
  Write-Host "== $secret =="
  az keyvault secret set --vault-name $spn.keyvault --name $secret --value $response.password
  $tenant = "TRF-TENANT-ID"
  Write-Host "== $tenant =="
  az keyvault secret set --vault-name $spn.keyvault --name $tenant --value $response.tenant
  $subscription = "$($spn.name)-SUBSCRIPTION-ID"
  Write-Host "== $subscription =="
  az keyvault secret set --vault-name $spn.keyvault --name $subscription --value $spn.subscription_id

}