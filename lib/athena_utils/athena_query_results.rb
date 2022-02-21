require 'aws-sdk-s3'
require 'csv-utils'

module AthenaUtils
  class AthenaQueryResults
    include Enumerable

    attr_reader :query_status

    def initialize(query_status)
      @query_status = query_status
    end

    def s3_url
      query_status.query_execution.result_configuration.output_location
    end

    def s3_object
      uri = URI(s3_url)

      aws_s3_client.get_object(
        {
          bucket: uri.host,
          key: uri.path[1..-1]
        }
      )
    end

    def save(file)
      uri = URI(s3_url)

      aws_s3_client.get_object(
        {
          bucket: uri.host,
          key: uri.path[1..-1],
          response_target: file
        }
      )
    end

    def aws_s3_client
      @aws_s3_client ||= create_aws_s3_client
    end

    def create_aws_s3_client
      Aws::S3::Client.new
    end

    def csv_iterator
      @csv_iterator ||= CSVUtils::CSVIterator.new(CSV.new(s3_object.body))
    end

    def each(&block)
      csv_iterator.each(&block)
    end
  end
end
