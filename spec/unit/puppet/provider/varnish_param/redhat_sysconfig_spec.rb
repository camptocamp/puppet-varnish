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

    it "should list instances" do
      provider_class.stubs(:target).returns(target)
      inst = provider_class.instances.map { |p|
        {
          :name => p.get(:name),
          :ensure => p.get(:ensure),
          :value => p.get(:value),
        }
      }

      inst.size.should == 11
      inst[0].should == {:name=>"vcl_conf", :ensure=>:present, :value=>"/etc/varnish/default.vcl"}
      inst[1].should == {:name=>"listen_port", :ensure=>:present, :value=>"6081"}
      inst[2].should == {:name=>"admin_listen_address", :ensure=>:present, :value=>"127.0.0.1"}
      inst[3].should == {:name=>"admin_listen_port", :ensure=>:present, :value=>"6082"}
      inst[4].should == {:name=>"secret_file", :ensure=>:present, :value=>"/etc/varnish/secret"}
      inst[5].should == {:name=>"min_threads", :ensure=>:present, :value=>"50"}
      inst[6].should == {:name=>"max_threads", :ensure=>:present, :value=>"1000"}
      inst[7].should == {:name=>"thread_timeout", :ensure=>:present, :value=>"120"}
      inst[8].should == {:name=>"storage_size", :ensure=>:present, :value=>"256M"}
      inst[9].should == {:name=>"storage", :ensure=>:present, :value=>"\"malloc,${VARNISH_STORAGE_SIZE}\""}
      inst[10].should == {:name=>"ttl", :ensure=>:present, :value=>"120"}
    end

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

