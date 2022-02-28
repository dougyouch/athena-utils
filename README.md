# AWS Athena Utils

Purpose of this utility is to execute Athena queries and wait for results.

## Usage

Install the gem:

```
gem install 'athena-utils'
```

Create an Athena client and wait for results.

```
require 'athena-utils'

athena_database = 'test_db'
athena_work_group = 'primary'
athena_client = AthenaUtils::AthenaClient.new(athena_database, athena_work_group)

results = athena_client.query("SELECT * FROM users WHERE created_at >= Date('2022-01-01')")
results.first
# => {"id"=>"8", "name"=>"Foo", "email"=>"foo@example.com", "created_at"=>"2022-02-01"}
```

Execute multiple queries and wait for results.

```
require 'athena-utils'

athena_database = 'test_db'
athena_work_group = 'primary'
athena_client = AthenaUtils::AthenaClient.new(athena_database, athena_work_group)

# contains table_name => query_execution_id
query_executions = {}
query_executions['users'] = athena_client.query_async("SELECT * FROM users WHERE created_at >= Date('2022-01-01')")
query_executions['groups'] = athena_client.query_async("SELECT * FROM groups WHERE created_at >= Date('2022-01-01')")
query_executions['activities'] = athena_client.query_async("SELECT * FROM activities WHERE created_at >= Date('2022-01-01')")

# given an array of query_execution_id(s)
# waits for each query to successfully complete
# and returns the results of each in a hash
# key is the query_execution_id and the value is the results
results = athena_client.wait(query_executions.values)

users_results = results[query_executions['users']]
groups_results = results[query_executions['groups']]
activities_results = results[query_executions['activities']]

users_results.first
# => {"id"=>"8", "name"=>"Foo", "email"=>"foo@example.com", "created_at"=>"2022-02-01"}
```

## AthenaUtils::AthenaQueryResults

Streams the results of the query.  Avoids loading the results into memory.

The class implements the Enumerable module.  For easy of use the _each_ method returns each row in a hash where the header names are the keys.

How to access the rows as an array

```
# given the above query logic
headers = users_results.csv.shift

while(row = users_results.csv.shift)
  id = row[0]
  name = row[1]
  emai = row[2]
  created_at = row[3]

  # do something
end
```

## Command-Line Utility

Execute 1 of queries without running to the AWS console.

```
> athena -h
Usage: athena [options]
    -d, --database DATABASE          Athena DB
    -w, --work-group WORK_GROUP      Athena Work Group, default: primary
    -e, --execute QUERY              Execute SQL Query
    -s, --save FILE                  Save query results to file
    -c, --console                    Execute query and makes results available in irb
```

Example:

```
athena -d test_db -e "SELECT * FROM users WHERE created_at >= Date('2022-01-01')"
```

Outputs

```
"id","name","email","created_at"
"5","Foo","foo@example.com","2022-02-01"
```

Working in the console

The console encapsulates the Athena client in a global athena method.  The results of the Athena query are availble in a global results method.
