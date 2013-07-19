require 'spec_helper'

describe Fixes::Path do

  it "is a valid rack middleware" do
    env = mock
    env.stub :[]
    app = mock
    app.should_receive(:call).with(env)
    instance = Fixes::Path.new(app)
    instance.call(env)
  end

  describe "#call" do

    before do
      @env = {}
      @app = mock
      @app.stub :call
      @instance = Fixes::Path.new @app
    end

    it "sets DATA_PATH if the PATH_INFO matches a storage path" do
      @env['PATH_INFO'] = '/storage/nil/'
      @instance.call(@env)
      @env['DATA_PATH'].should_not be_nil
    end

    it "doesn't set DATA_PATH if the PATH_INFO doesn't match a storage path" do
      @env['PATH_INFO'] = '/foo/bar'
      @instance.call(@env)
      @env['DATA_PATH'].should be_nil
    end

    it "protects DATA_PATH against directory traversal" do
      @env['PATH_INFO'] = '/storage/nil/foo/bar/../baz'
      @instance.call(@env)
      @env['DATA_PATH'].should eq 'foo/bar/baz'
    end

    it "doesn't destroy paths containing two dots that aren't traversing" do
      @env['PATH_INFO'] = '/storage/nil/foo/bar/baz/..bla/blubb../foo'
      @instance.call(@env)
      @env['DATA_PATH'].should eq 'foo/bar/baz/..bla/blubb../foo'
    end

    it "also protects DATA_PATH against multiple traversal tokens" do
      @env['PATH_INFO'] = '/storage/nil/baz/../../bla/blubb/../foo/bar'
      @instance.call(@env)
      @env['DATA_PATH'].should eq 'baz/bla/blubb/foo/bar'
    end

  end
end
