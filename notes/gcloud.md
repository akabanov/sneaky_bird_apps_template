# Google cloud services integration

[Project console](https://console.cloud.google.com/welcome/new?project=flutter-skeleton-app-2ee87)

## GCloud CLI

* [CLI installation](https://cloud.google.com/sdk/docs/install)
* [`gsutil` configuration (`USER_HOME/.boto`)](https://cloud.google.com/storage/docs/gsutil/commands/config);
  the command is deprecated, not sure about its config though.
* [Create project using CLI - reference](https://cloud.google.com/sdk/gcloud/reference/projects/create)
* [`gcloud` CLI Tool reference](https://cloud.google.com/sdk/gcloud/reference)

## Select project

Login to account and select the project:

```shell
gcloud auth login
gcloud config set project flutter-skeleton-app-2ee87
```

## Enable billing

Billing is required for certain services like accessing storage via CLI.

Check if you have a suitable billing account,
[create if you don't](https://console.cloud.google.com/billing):

```shell
gcloud billing accounts list
```

Link the account to project (**untested**):

```shell
gcloud billing projects link flutter-skeleton-app-2ee87 \
    --billing-account=$BILLING_ACCOUNT_ID
```

## Manage expenses (!!!untested!!!)

Set up billing alerts:

```shell
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="Storage Budget" \
    --budget-amount=10USD \
    --threshold-rules=percent=50,percent=90 \
    --threshold-rules-trigger-on-spend=true
```

Go to: Cloud Console (web interface) > APIs & Services > Quotas

Find the Cloud Storage API quotas. Common limits you can set:

* Requests per second
* Requests per day
* Bytes downloaded per project per day
* Objects written per project per day

## Enable required services

The following services are required in order to use Firebase Test Lab. \
See https://firebase.google.com/docs/test-lab/android/continuous

```shell
gcloud services enable testing.googleapis.com
gcloud services enable toolresults.googleapis.com
```

## Cloud storage

[Storage CLI reference](https://cloud.google.com/sdk/gcloud/reference/storage)

Note: storage access keys can be managed
[here](https://console.cloud.google.com/storage/settings;tab=interoperability?project=flutter-skeleton-app-2ee87)

### Create project storage

Create the project bucket:

```shell
gcloud storage buckets create gs://flutter-skeleton-app-2ee87-test --location US-WEST1 --public-access-prevention --uniform-bucket-level-access
```

You can find the buckets
[here](https://console.cloud.google.com/storage/browser?project=flutter-skeleton-app-2ee87), or this way:

```shell
gcloud storage buckets list
```

### Grant access to Firebase Test Lab

**CHECK THIS THE NEXT TIME; I'M NOT REALLY SURE IF THIS WAS NEEDED OR DONE:**

Try running remote tests first, and only if they fail with something like
"`Reason: INVALID_INPUT_APK Message: User input file could not be downloaded.`"

```shell
gcloud storage buckets add-iam-policy-binding gs://flutter-skeleton-app-2ee87 \
    --member="serviceAccount:firebase-test-lab@gcp-sa-firebasetest.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"
```

### Pricing and staying free of charge

Here's the Google Cloud Storage [pricing policy](https://cloud.google.com/storage/pricing).

Stay within the Always Free usage limits:

* Use only 5 GB or less of Standard storage per month
* Keep Class A operations (like uploads and updates) under 5,000 per month (~160 per day)
* Keep Class B operations (like downloads and reads) under 50,000 per month (~1,600 per day)
* Keep data transfer under 100 GB from North America to Google Cloud destinations (excluding Australia and China)

Only use these three regions for Always Free benefits:

* US-WEST1
* US-CENTRAL1
* US-EAST1

Avoid:

* `Nearline`, `Coldline`, or `Archive` storage which have minimum storage durations and retrieval fees
* Dual-region or multi-region storage which have higher operation costs

To actively prevent going over these limits and getting charged:

* Set up API request caps to limit usage
* Monitor your usage through the billing details in your project

Additional tips:

* Delete data you no longer need
* Be mindful of operations that count as Class A vs Class B
* Keep data transfer within the same region when possible (it's free)

