# Google Cloud costs

## Storage quotas control

Go to: Cloud Console (web interface) > APIs & Services > Quotas

Find the Cloud Storage API quotas. Common limits you can set:

* Requests per second
* Requests per day
* Bytes downloaded per project per day
* Objects written per project per day

## Storage pricing and staying free of charge

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

