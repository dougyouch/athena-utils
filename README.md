# AWS Athena Utils

A simple query wrapper around Aws::Athena::Client.

Purpose of this utility is to provide simple functionality to query Athena and wait for results.

## Usage

Install the gem:

```
gem install 'athena-utils'
```

Create an Athena client and wait for results.

```
require 'athena-utils'

athena_database = 'test_db'
athena_workspace = 'primary'
athena_client = AthenaUtils::AthenaClient.new(athena_database, athena_workspace)

results = athena_client.query("SELECT * FROM users WHERE created_at >= Date('2022-01-01')")
results.first
# => {"id"=>8, "name"=>"Foo", "email"=>"foo@example.com", "created_at"=>"2022-02-01"}
```


