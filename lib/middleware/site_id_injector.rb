#handles site_id parameter to cas, which is not supported natively
class SiteIdInjector
  def initialize(app)
    @app = app
  end

  def call(env)
    #on any login request, put the site id into the session if provided
    if env['PATH_INFO'].match(/login/)
      session = env['rack.session']

      query_string = env['QUERY_STRING']
      site_id = query_string[/sid=(\d+)/, 1]
      if site_id
        session['cas.sid'] = site_id
      end

      #on a POST request, insert the site id into the parameters
      if env['REQUEST_METHOD'] == 'POST' && session['cas.sid']
        env["rack.request.form_hash"]['sid'] = session['cas.sid'] if env["rack.request.form_hash"]
        env["rack.request.form_vars"] += "&sid=#{session['cas.sid']}" unless !env["rack.request.form_vars"] || env["rack.request.form_vars"].match(/sid=/)
      end
    end

    @app.call(env)
  end
end
