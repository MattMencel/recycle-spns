# Recycle SPNs

Recycle Azure SPNs and store them in KeyVaults so they can be used by other applications.

The script could be run in a scheduled build pipeline (quarterly, annually, etc...) based on whatever the security requirements are for recycling credentials.

## Prerequisites

* Azure CLI
* Powershell 6+
* Permission to create/reset SPNs and add secrets to the KeyVaults.

## Usage

Edit the `spns.json` file and create your list of subscriptions, SPN Names, and KeyVaults to store the secrets in.

Run the script.

The `spns.json` files is formatted like...

``` json
{
  "SPNs": [{
      "subscription_id": "SUBSCRIPTION_GUID1",
      "name": "TRF-DEV",
      "keyvault": "DEVKeyVault"
    },
    {
      "subscription_id": "SUBSCRIPTION_GUID2",
      "name": "TRF-TEST",
      "keyvault": "TESTKeyVault"
    }
  ]
}
```