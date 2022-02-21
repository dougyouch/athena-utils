module AthenaUtils
  class AthenaQueryError < StandardError; end
  autoload :AthenaClient, 'athena_utils/athena_client'
  autoload :AthenaQueryResults, 'athena_utils/athena_query_results'
end
