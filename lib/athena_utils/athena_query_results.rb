require 'aws-sdk-s3'
require 'csv'

module AthenaUtils
  class AthenaQueryResults
    include Enumerable

    attr_reader :query_status,
                :aws_s3_client

    def initialize(query_status, aws_s3_client)
      @query_status = query_status
      @aws_s3_client = aws_s3_client
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

    def csv
      @csv ||= CSV.new(s3_object.body)
    end

    def headers
      csv.rewind
      csv.shift
    end

    def each
      csv.rewind
      headers = csv.shift
      while (row = csv.shift)
        yield Hash[headers.zip(row)]
      end
    end
  end
end
