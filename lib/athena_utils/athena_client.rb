require 'aws-sdk-athena'

module AthenaUtils
  class AthenaClient
    # database is the name of the Athena DB
    # output_location is the full S3 path to store the results of Athena queries
    attr_reader :database,
                :output_location

    def initialize(database, output_location)
      @database = database
      @output_location = output_location
    end

    def aws_athena_client
      @aws_athena_client ||= create_aws_athena_client
    end

    def create_aws_athena_client
      Aws::Athena::Client.new
    end

    def query(query)
      query_execution_id = query_async(query)
      wait([query_execution_id])[query_execution_id]
    end

    def query_async(query)
      response = aws_athena_client.start_query_execution(
        query_string: query,
        query_execution_context: {
          database: database
        },
        result_configuration: {
          output_location: output_location
        }
      )

      response.query_execution_id
    end

    def wait(query_execution_ids)
      results = {}

      while results.size != query_execution_ids.size
        query_execution_ids.each do |query_execution_id|
          next if results.key?(query_execution_id)

          query_status = aws_athena_client.get_query_execution(
            query_execution_id: query_execution_id
          )

          case query_status[:query_execution][:status][:state]
          when 'SUCCEEDED'
            results[query_execution_id] = AthenaQueryResults.new(query_status)
          when 'RUNNING',
               'QUEUED'
          # no-op
          else
            raise(AthenaQueryError.new("Query failed #{query_status}"))
          end
        end

        sleep(3) if results.size != query_execution_ids.size
      end

      results
    end
  end
end
