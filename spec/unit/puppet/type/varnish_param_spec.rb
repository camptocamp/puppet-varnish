#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:varnish_param) do
  before do
    @type = Puppet::Type.type(:varnish_param)
    @valid_params = {
      :name   => 'FOO',
      :ensure => 'present'
    }
  end

  it "should exist" do
    expect(@type).not_to be_nil
  end

  describe "the name parameter" do
    it "should exist" do
      expect(@type.attrclass(:name)).not_to be_nil
    end
  end

  describe "the target parameter" do
    it "should exist" do
      expect(@type.attrclass(:target)).not_to be_nil
    end

    it "should support paths" do
      @type.new(:name => 'FOO', :target => '/foo/bar') do |resource|
        expect(resource[:target]).to eq('/foo/bar')
      end
    end
  end

  describe "the ensure parameter" do
    it "should exist" do
      expect(@type.attrclass(:ensure)).not_to be_nil
    end

    it "should default to present" do
      @type.new(:name => 'FOO') do |resource|
        expect(resource[:target]).to eq('present')
      end
    end
  end
end
