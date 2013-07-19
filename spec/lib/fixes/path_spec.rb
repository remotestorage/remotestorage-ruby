require 'spec_helper'

describe Fixes::Path do
  describe '#call' do
    it "should set env['DATA_PATH'] with '/storage/user/../' to /" do
      call('/storage/user/../')
    end
  end
end
