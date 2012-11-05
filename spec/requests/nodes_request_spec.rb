
require 'spec_helper'

describe "Nodes requests" do

  describe "GET" do

    before do
      @user = User.create!(
        :login => 'blue',
        :password => 'foobar',
        :password_confirmation => 'foobar'
      )

      @authorization = @user.authorizations.create!(
        :origin => 'http://example.com',
        :scope => 'foo:rw'
      )

      @user.nodes.put('foo/bar', 'baz'.encode('UTF-8'), 'text/plain', false)
      @user.nodes.put('foo/bin', 'blablubb'.encode('US-ASCII'), 'application/octet-stream', true)
      @user.nodes.put('bla/blubb', 'baz', 'text/plain', false)
    end

    def send_request(path)
      get path, {}, { 'Authorization' => 'Bearer ' + @authorization.token }
    end

    it "works for UTF-8 files" do
      send_request('/storage/blue/foo/bar')
      response.status.should eq 200
      response['Content-Type'].should eq 'text/plain; charset=UTF-8'
      response.body.should eq 'baz'
    end

    it "works for binary files" do
      send_request('/storage/blue/foo/bin')
      response.status.should eq 200
      response['Content-Type'].should eq 'application/octet-stream; charset=binary'
      response.body.should eq 'blablubb'
    end

    it "works for non-existing files" do
      send_request('/storage/blue/foo/doesnt-exist')
      response.status.should eq 404
      response.body.should eq ''
    end

    it "works for non-existing directories" do
      send_request('/storage/blue/foo/baz/')
      response.status.should eq 200
      response['Content-Type'].should eq 'application/json; charset=UTF-8'
      response.body.should eq "{}"
    end

    it "works for existing directories" do
      send_request('/storage/blue/foo/')
      response.status.should eq 200
      response['Content-Type'].should eq 'application/json; charset=UTF-8'
      response.body.should_not be_nil
      listing = JSON.parse(response.body)
      listing['bar'].should be_an(Integer)
    end

    it "doesn't work for directories out of scope" do
      send_request('/storage/blue/bla/')
      response.status.should eq 401
    end

    it "doesn't work for files out of scope" do
      send_request('/storage/blue/bla/blubb')
      response.status.should eq 401
    end

  end

  describe "PUT" do


    before do
      @user = User.create!(
        :login => 'blue',
        :password => 'foobar',
        :password_confirmation => 'foobar'
      )

      @authorization = @user.authorizations.create!(
        :origin => 'http://example.com',
        :scope => 'foo:rw'
      )
    end

    def send_request(path, data, content_type)
      put path, data, { 'CONTENT_TYPE' => content_type, 'Authorization' => 'Bearer ' + @authorization.token }
    end

    it "works for UTF-8 data" do
      send_request('/storage/blue/foo/baz', 'foo', 'text/plain; charset=UTF-8')
      response.status.should eq 200
      node = @user.nodes.by_path('foo/baz')
      node.should_not be_nil
      node.directory.should be false
      node.binary.should be false
      node.data.should eq 'foo'
      node.content_type.should eq 'text/plain'
    end

    it "works for binary data" do
      send_request('/storage/blue/foo/bar', 'foo', 'application/octet-stream; charset=binary')
      response.status.should eq 200
      node = @user.nodes.by_path('foo/bar')
      node.should_not be_nil
      node.directory.should be false
      node.binary.should be true
      node.data.should eq 'foo'
      node.content_type.should eq 'application/octet-stream'
    end

    it "doesn't work out of scope" do
      send_request('/storage/blue/bla/blubb', 'foo', 'text/plain')
      response.status.should eq 401
    end

  end

end
