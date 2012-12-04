#adds unrecognized query string parameters to session, in order to be
#handled by a custom authenticator 
class QuerySessionizer
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'].match(/login/) && env['REQUEST_METHOD'] == 'GET'
      Rails.logger.debug "in #call of QuerySessionizer at #{Time.now}"
      session = env['rack.session']

      query_string = env['QUERY_STRING']
      query_hash = Rack::Utils.parse_nested_query(query_string)
      extra_parameters = query_hash.delete_if {|key, value| ['service'].include?(key)}

      session['cas.additional_query_parameters'] = (session['cas.additional_query_parameters'] || {}).merge extra_parameters

      Rails.logger.debug "leaving #call of QuerySessionizer at #{Time.now}"

      true
    end

    @app.call(env)
  end
end
