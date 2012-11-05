
require 'spec_helper'

describe Node do

  before do
    @user = User.create(:login => 'blue', :password => 'foobar', :password_confirmation => 'foobar')
    @nodes = @user.nodes
  end

  describe '.by_path' do

    before do
      @file = @nodes.create!(:path => 'foo/bar', :directory => false, :data => 'bla', :content_type => 'text/plain')
      @dir = @nodes.create!(:path => 'baz', :directory => true, :content_type => 'application/json', :data => '{}')
    end

    it "finds directories" do
      @nodes.by_path('baz/').should eq @dir
    end

    it "finds files" do
      @nodes.by_path('foo/bar').should eq @file
    end

    it "doesn't find files for directories" do
      @nodes.by_path('foo/bar/').should eq nil
    end

    it "doesn't find directories for files" do
      @nodes.by_path('baz').should eq nil
    end

  end

  describe '.put' do

    it "stores UTF-8 nodes correctly" do
      node = @nodes.put("foo/bar", "bla".encode('UTF-8'), 'text/plain', false)
      node.id.should_not be_nil
      node.content_type.should eq 'text/plain'
      node.binary.should eq false
      node.path.should eq 'foo/bar'
      node.data.should eq 'bla'
      node.data.encoding.to_s.should eq 'UTF-8'
    end

    it "stores binary data correctly" do
      node = @nodes.put('foo/baz', "blubb".encode(BINARY_CHARSET), 'application/octet-stream', true)
      node.id.should_not be_nil
      node.content_type.should eq 'application/octet-stream'
      node.binary.should eq true
      node.path.should eq 'foo/baz'
      node.data.should eq 'blubb'
      node.data.encoding.to_s.should eq BINARY_CHARSET
    end

  end

  describe '#save' do
    before do
      @node = @nodes.build(:path => 'foo/bar/baz', :content_type => 'text/plain', :data => 'blablubb', :directory => false)
      @node.save!
    end

    it "updates parent directories" do
      @nodes.by_path('foo/bar/').should_not be_nil
      JSON.parse(@nodes.by_path('foo/bar/').data)['baz'].should be_an(Integer)

      @nodes.by_path('foo/').should_not be_nil
      JSON.parse(@nodes.by_path('foo/').data)['bar/'].should be_an(Integer)
    end
  end

end
