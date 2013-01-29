#adds unrecognized query string parameters to session, in order to be
#handled by a custom authenticator 
class ErrorHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    return handle_exception if status == 500

    [status, headers, body]
  rescue Exception => e
    handle_exception(env, e)
  end

  def handle_exception(env, e)
    # negotiate the content
    request = Rack::Request.new(env)

    uri = URI request.url
    query = uri.query

    #if this is the second time through with an error, return an actual 500
    if query && query.match(/redirected/)
      return [500, {}, ["There was an error.  Please try again."]]
    end

    #add in a flag showing that we were already redirected
    uri.query = [query, {redirected: '1'}.to_query].select {|item| !item.blank?}.join('&')

    response_headers = {
      'Location' => uri.to_s
    }

    #redirect to the same url if this is the first error
    return [303, response_headers, ["Redirecting to #{uri.to_s}"]]
  end
end
