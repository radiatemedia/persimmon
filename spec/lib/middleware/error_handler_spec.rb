require 'spec_helper'
describe ErrorHandler do
  before(:each) do
    @app = Proc.new do |env|
      [500, {"Content-Type" => "text/html"}, "Hello Rack!"]
    end
    @error_handler = ErrorHandler.new @app
  end

  it "should catch exceptions" do
    @error_handler.should_receive(:handle_exception).once

    @app.stub!(:call).and_raise(Exception.new)

    @error_handler.call({})
  end

  it "should catch requests that return a 500 status" do
    @error_handler.should_receive(:handle_exception).once

    @error_handler.call({})
  end

  it "should specify a location with redirected=1 in it" do
    status, headers, response = @error_handler.call(
      'REQUEST_METHOD' => 'POST',
      'SCRIPT_NAME' => '',
      'PATH_INFO' => '/cas/login',
      'QUERY_STRING' => '',
      'SERVER_NAME' => 'localhost',
      'SERVER_PORT' => 80
    )

    headers['Location'].should match(/\?.*redirected=1/)
  end
end
