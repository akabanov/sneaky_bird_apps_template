# Google cloud services integration


## Installing CLI

* [CLI installation](https://cloud.google.com/sdk/docs/install)
* [`gsutil` configuration (`USER_HOME/.boto`)](https://cloud.google.com/storage/docs/gsutil/commands/config);
  the command is deprecated, not sure about the config though.


## Cloud storage


### Create project storage

Make sure the billing is enabled for
[the project](https://console.cloud.google.com/welcome/new?project=flutter-skeleton-app-2ee87)
and create the project bucket:

```shell
gcloud config set project flutter-skeleton-app-2ee87
gcloud storage buckets create gs://flutter-skeleton-app-2ee87 --location US-WEST1
```
You can find the buckets [here](https://console.cloud.google.com/storage/browser?project=flutter-skeleton-app-2ee87).


### Pricing

https://cloud.google.com/storage/pricing

Always Free quotas apply to usage in US-WEST1, US-CENTRAL1, and US-EAST1

Resource Monthly Free Usage Limits1
Standard storage 5 GB-months
Class A Operations 5,000
Class B Operations 50,000
Data transfer 100 GB from North America to each Google Cloud Data transfer destination (Australia and China excluded)



