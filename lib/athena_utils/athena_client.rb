require 'aws-sdk-athena'

module AthenaUtils
  class AthenaClient
    DEFAULT_WAIT_TIME = 3 # seconds

    # database is the name of the Athena DB
    # output_location is the full S3 path to store the results of Athena queries
    attr_reader :database,
                :output_location

    # wait_time is time to wait before checking query results again
    attr_accessor :wait_time

    attr_writer :aws_athena_client,
                :aws_s3_client

    def initialize(database, output_location, wait_time = DEFAULT_WAIT_TIME)
      @database = database
      @output_location = output_location
      @wait_time = wait_time
    end

    def aws_athena_client
      @aws_athena_client ||= create_aws_athena_client
    end

    def create_aws_athena_client
      Aws::Athena::Client.new
    end

    def aws_s3_client
      @aws_s3_client ||= create_aws_s3_client
    end

    def create_aws_s3_client
      Aws::S3::Client.new
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
            results[query_execution_id] = AthenaQueryResults.new(query_status, aws_s3_client)
          when 'RUNNING',
               'QUEUED'
          # no-op
            next
          else
            raise(AthenaQueryError.new("Query failed #{query_status}"))
          end
        end

        sleep(wait_time) if results.size != query_execution_ids.size
      end

      results
    end
  end
end
