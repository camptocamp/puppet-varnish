#!/usr/bin/env rspec

require 'spec_helper'

provider = :redhat_sysconfig
provider_class = Puppet::Type.type(:varnish_param).provider(provider)

describe provider_class do
  before :each do
    Facter.fact(:osfamily).stubs(:value).returns 'RedHat'
    Facter.fact(:operatingsystemmajrelease).stubs(:value).returns '6'
  end

  context "with empty file" do
    let(:tmptarget) { aug_fixture("empty") }
    let(:target) { tmptarget.path }

    it "should create simple new entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "listen_address",
        :value    => "localhost",
        :target   => target,
        :provider => provider
      ))

      augparse(target, "Shellvars.lns", '
        { "VARNISH_LISTEN_ADDRESS" = "localhost" }
      ')
    end
  end

  context "with full file" do
    let(:tmptarget) { aug_fixture("full") }
    let(:target) { tmptarget.path }

    it "should create a new entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "user",
        :value    => "varnish",
        :target   => target,
        :provider => provider
      ))

      aug_open(target, "Shellvars.lns") do |aug|
        aug.get('VARNISH_USER').should == 'varnish'
      end
    end

    it "should update existing entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "listen_port",
        :value    => "16081",
        :target   => target,
        :provider => provider
      ))


      aug_open(target, "Shellvars.lns") do |aug|
        aug.get('VARNISH_LISTEN_PORT').should == '16081'
      end
    end

    it "should remove existing entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "listen_port",
        :ensure   => "absent",
        :target   => target,
        :provider => provider
      ))

      aug_open(target, "Shellvars.lns") do |aug|
        aug.match('VARNISH_LISTEN_PORT').size.should == 0
      end
    end
  end

  context "with broken file" do
    let(:tmptarget) { aug_fixture("broken") }
    let(:target) { tmptarget.path }

    it "should fail to load" do
      txn = apply(Puppet::Type.type(:varnish_param).new(
        :name     => "listen_address",
        :value    => "localhost",
        :target   => target,
        :provider => provider
      ))

      txn.any_failed?.should_not == nil
      @logs.first.level.should == :err
      @logs.first.message.include?(target).should == true
    end
  end
end

