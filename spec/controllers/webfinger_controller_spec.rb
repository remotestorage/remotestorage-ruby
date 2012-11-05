
require 'spec_helper'

describe WebfingerController do

  describe :host_meta do

    describe do
      before do
        launch
        @parsed_response = JSON.parse(response.body) rescue nil
      end

      it "is a JSON document" do
        response.headers['Content-Type'].should =~ /^application\/json/
        @parsed_response.should_not be_nil
      end

      it "contains an lrdd link" do
        @parsed_response['links'].should_not be_nil
        @parsed_response['links'].any? { |link|
          link['rel'] == 'lrdd'
        }.should be_true
      end

      it "specifies /.well-known/host-meta?resource={uri} as the LRDD template" do
        @parsed_response['links'].select { |link|
          link['rel'] == 'lrdd'
        }.first['template'].should eq 'http://test.host/.well-known/host-meta?resource={uri}'
      end
    end

    describe 'with a resource given' do
      before do
        @user = User.create!(
          :login => 'blue',
          :password => 'blue!',
          :password_confirmation => 'blue!'
        )

        @params = {
          :resource => 'acct:blue@test.host'
        }
      end

      it "succeeds with correct user@host" do
        launch
        response.status.should eq 200
      end

      it "responds 404 when user is incorrect" do
        @params[:resource] = 'acct:red@test.host'
        launch
        response.status.should eq 404
      end

      it "responds 404 when host is incorrect" do
        @params[:resource] = 'acct:blue@other.host'
        launch
        response.status.should eq 404
      end


      it "fetches the user" do
        launch
        assigns[:user].should eq @user
      end

      it "is a JSON document" do
        launch
        response.headers['Content-Type'].should =~ /^application\/json/
      end

      describe 'the remoteStorage link' do

        before do
          launch
          @resp = JSON.parse(response.body)
          @link = @resp['links'].select {|link|
            link['rel'] == 'remoteStorage'
          }.first
        end

        it "is present" do
          @link.should_not be_nil
        end

        it "contains the correct href" do
          @link['href'].should eq 'http://test.host/storage/blue'
        end

        it "advertises the rww-00#simple type" do
          @link['type'].should eq 'https://www.w3.org/community/rww/wiki/read-write-web-00#simple'
        end

        it "contains correct auth-method and auth-endpoint properties" do
          @link['properties']['auth-method'].should eq 'https://tools.ietf.org/html/draft-ietf-oauth-v2-26#section-4.2'
          @link['properties']['auth-endpoint'].should eq 'http://test.host/authorizations/new?login=blue'
        end

      end

    end

  end

end
