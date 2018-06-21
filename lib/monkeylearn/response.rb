module Monkeylearn
  class Response
    attr_reader :raw_response, :status, :body, :plan_queries_allowed, :plan_queries_remaining, :request_queries_used

    def initialize(raw_response, api_version: nil)
      @api_version = api_version || Monkeylearn::Defaults.api_version
      self.raw_response = raw_response
    end

    def raw_response=(raw_response)
      @raw_response = raw_response
      @status = raw_response.status
      @body = response_preparator(raw_response.body)
      @plan_queries_allowed = @raw_response.headers['X-Query-Limit-Limit'].to_i
      @plan_queries_remaining = @raw_response.headers['X-Query-Limit-Remaining'].to_i
      @request_queries_used = @raw_response.headers['X-Query-Limit-Request-Queries'].to_i
    end

    private

    def response_preparator(body)
      return nil if body == ''

      case @api_version
      when :v2
        # For the original v2 response, everything remained nested inside the
        # 'result' field. But, this was removed by the MutiResponse. As
        # everything used to be a MultiResponse back then, let's just remove it
        # here to better mimic that behavior. Also, this makes the code for the
        # MultiResponse simpler.
        JSON.parse(body)['result']
      when :v3
        JSON.parse(body, symbolize_keys: true)
      end
    end
  end

  class MultiResponse
    attr_reader :responses, :body, :plan_queries_allowed, :plan_queries_remaining, :request_queries_used

    def initialize(responses)
      self.responses = responses
    end

    def responses=(responses)
      @responses = responses
      @body = collect_body(responses)
      @plan_queries_allowed = @responses[-1].plan_queries_allowed
      @plan_queries_remaining = @responses[-1].plan_queries_remaining
      @request_queries_used = @responses.inject(0){|sum, r| sum + r.request_queries_used }
    end

    private

    def collect_body(responses)
      responses.collect do |r|
        r.body
      end.reduce(:+)
    end
  end
end
