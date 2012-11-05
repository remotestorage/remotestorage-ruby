
require 'spec_helper'

describe NodesController do

  describe :get do
    before do
      @user = mock('user')
      @nodes = mock('nodes')
      @node = mock('node')
      @authorizations = mock('authorizations')
      @authorization = mock('authorization')

      User.stub(:find_by_login).and_return(@user)
      @user.stub(:nodes).and_return(@nodes)
      @user.stub(:authorizations).and_return(@authorizations)
      @nodes.stub(:by_path).and_return(@node)
      @authorizations.stub(:find_by_token).and_return(@authorization)
      @authorization.stub(:allows?).and_return(true)
      @node.stub(:updated_at).and_return(Time.parse('2012-01-07 10:20:30 UTC'))
      @node.stub(:content_type).and_return('application/json')
      @node.stub(:binary).and_return(false)
      @node.stub(:data).and_return('{"foo":"bar"}')

      @params = { :user => 'blue', :path => 'foo' }

      request.env['DATA_PATH'] = 'foo'
      request.env['HTTP_AUTHORIZATION'] = 'Bearer 1234567'
    end

    it "fetches the user" do
      User.should_receive(:find_by_login).with('blue')
      launch
      assigns[:user].should eq @user
    end

    it "fetches an authorization using the supplied token" do
      @user.should_receive(:authorizations)
      @authorizations.should_receive(:find_by_token).with('1234567')
      launch
    end

    it "succeeds when the found authorization matches" do
      launch
      response.status.should eq 200
    end

    it "sends the right data" do
      launch
      response.body.should eq '{"foo":"bar"}'
    end

    it "fails when the found authorization doesn't match" do
      @authorization.stub(:allows?).and_return(false)
      launch
      response.status.should eq 401
    end

    describe "for directory nodes" do
      before do
        @params[:path] = request.env['DATA_PATH'] = '/'
      end

      it "returns 200 when no node is found" do
        @nodes.stub(:by_path).and_return(nil)
        launch
        response.status.should eq 200
      end

      it "returns an empty JSON object, when no node is found" do
        @nodes.stub(:by_path).and_return(nil)
        launch
        response.body.should eq '{}'
      end

    end

    it "returns 404 when there is no node (for data nodes)" do
      @nodes.stub(:by_path).and_return(nil)
      launch
      response.status.should eq 404
    end

    it "fetches the node with the given path" do
      @user.should_receive(:nodes)
      @nodes.should_receive(:by_path).with('foo')
      launch
    end

    it "renders the Last-Modified header correctly" do
      launch
      response.headers['Last-Modified'].should eq "Sat, 07 Jan 2012 10:20:30 GMT"
    end

    it "renders the Content-Type correctly for UTF-8 data" do
      launch
      response.headers['Content-Type'].should eq "application/json; charset=UTF-8"
    end

    it "renders the Content-Type correctly for binary data" do
      @node.stub(:content_type).and_return("application/octet-stream")
      @node.stub(:binary).and_return(true)
      launch
      response.headers['Content-Type'].should eq "application/octet-stream; charset=binary"
    end

    describe "for public items" do
      before do
        @params[:path] = request.env['DATA_PATH'] = 'public/foo'
      end

      describe "without authorization" do
        before do
          request.env.delete('HTTP_AUTHORIZATION')
          @authorizations.stub(:find_by_token).and_return(nil)
        end

        it "succeeds" do
          launch
          response.status.should eq 200
          response.body.should eq '{"foo":"bar"}'
        end

        it "fails for directories" do
          @params[:path] = request.env['DATA_PATH'] = 'public/bar/'
          ## FIXME!!!
          request.env['TRAILING_SLASH'] = true
          launch
          response.status.should eq 401
        end
      end

      describe "with authorization" do
        it "succeeds for data nodes" do
          launch
          response.status.should eq 200
        end

        it "succeeds for directory nodes" do
          launch
          response.status.should eq 200
        end
      end

    end
  end

  describe :put do

    before do
      @user = mock('user')
      @nodes = mock('nodes')
      @authorizations = mock('authorizations')
      @authorization = mock('authorization')

      User.stub(:find_by_login => @user)
      @user.stub(:nodes => @nodes)
      @user.stub(:authorizations => @authorizations)
      @authorizations.stub(:find_by_token => @authorization)
      @authorization.stub(:allows? => true)
      @nodes.stub(:put)

      @params = { :path => 'foo/bar', :user => 'blue' }
      request.env['DATA_PATH'] = @params[:path]
      request.env['CONTENT_TYPE'] = 'text/plain; charset=UTF-8'
      request.env['RAW_POST_DATA'] = "some-data"
      request.env['HTTP_AUTHORIZATION'] = 'my-token'
    end

    it "fetches the user" do
      User.should_receive(:find_by_login).with('blue')
      launch
    end

    it "fetches the authorization" do
      @authorizations.should_receive(:find_by_token).with('my-token')
      launch
    end

    it "calls Node.put" do
      @nodes.should_receive(:put).with("foo/bar", "some-data", "text/plain", false)
      launch
    end

    it "succeeds" do
      launch
      response.status.should eq 200
    end

    it "works for binary nodes" do
      request.env['CONTENT_TYPE'] = 'text/plain; charset=binary'
      @nodes.should_receive(:put).with('foo/bar', 'some-data', 'text/plain', true)
      launch
    end

    it "renders an empty body" do
      launch
      response.body.should eq ''
    end

    describe "when given token doesn't allow this" do
      before do
        @authorization.stub(:allows? => false)
      end

      it "doesn't call :put" do
        @nodes.should_not_receive(:put)
        launch
      end

      it "returns 401" do
        launch
        response.status.should eq 401
      end
    end

    describe "when token is invalid" do
      before do
        @authorizations.stub(:find_by_token => nil)
      end

      it "doesn't call :put" do
        @nodes.should_not_receive(:put)
        launch
      end

      it "returns 401" do
        launch
        response.status.should eq 401
      end
    end

  end

  describe :delete do


    before do
      @user = mock('user')
      @nodes = mock('nodes')
      @node = mock('node')
      @authorizations = mock('authorizations')
      @authorization = mock('authorization')

      User.stub(:find_by_login => @user)
      @user.stub(:nodes => @nodes)
      @user.stub(:authorizations => @authorizations)
      @authorizations.stub(:find_by_token => @authorization)
      @authorization.stub(:allows? => true)
      @nodes.stub(:by_path => @node)
      @node.stub(:directory? => false)
      @node.stub(:destroy)

      @params = { :path => 'foo/bar', :user => 'blue' }
      request.env['DATA_PATH'] = @params[:path]
      request.env['CONTENT_TYPE'] = 'text/plain; charset=UTF-8'
      request.env['RAW_POST_DATA'] = "some-data"
      request.env['HTTP_AUTHORIZATION'] = 'my-token'
    end

    it "looks up the user" do
      User.should_receive(:find_by_login).with('blue')
      launch
    end

    it "looks up the authorization" do
      @authorizations.should_receive(:find_by_token).with('my-token')
      launch
    end

    it "fetches the node" do
      @nodes.should_receive(:by_path).with('foo/bar')
      launch
    end

    it "destroys the node" do
      @node.should_receive(:destroy)
      launch
    end

    it "renders the empty string" do
      launch
      response.body.should eq ''
    end

    it "succeeds" do
      launch
      response.status.should eq 200
    end

    it "doesn't destroy the node if it is a directory" do
      @node.stub(:directory? => true)
      @node.should_not_receive(:destroy)
      launch
    end


    describe "when given token doesn't allow this" do
      before do
        @authorization.stub(:allows? => false)
      end

      it "doesn't fetch the node" do
        @nodes.should_not_receive(:by_path)
        launch
      end

      it "returns 401" do
        launch
        response.status.should eq 401
      end
    end

    describe "when token is invalid" do
      before do
        @authorizations.stub(:find_by_token => nil)
      end

      it "doesn't fetch the node" do
        @nodes.should_not_receive(:by_path)
        launch
      end

      it "returns 401" do
        launch
        response.status.should eq 401
      end
    end

  end

end
