#!/usr/bin/env rspec

require 'spec_helper'

provider = :debian_default
provider_class = Puppet::Type.type(:varnish_param).provider(provider)

describe provider_class do
  before :each do
    Facter.fact(:operatingsystem).stubs(:value).returns 'Debian'
    Facter.fact(:operatingsystemmajrelease).stubs(:value).returns '7'
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

      augparse(target, "Shellvars_list.lns", '
        { "DAEMON_OPTS"
          { "quote" = "\"" }
          { "value" = "-a" }
          { "value" = "localhost:" } }
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

      expect(inst.size).to eq(6)
      expect(inst[0]).to eq({:name=>"listen_port", :ensure=>:present, :value=>"6081"})
      expect(inst[1]).to eq({:name=>"admin_listen_address", :ensure=>:present, :value=>"localhost"})
      expect(inst[2]).to eq({:name=>"admin_listen_port", :ensure=>:present, :value=>"6082"})
      expect(inst[3]).to eq({:name=>"vcl_conf", :ensure=>:present, :value=>"/etc/varnish/default.vcl"})
      expect(inst[4]).to eq({:name=>"secret_file", :ensure=>:present, :value=>"/etc/varnish/secret"})
      expect(inst[5]).to eq({:name=>"storage", :ensure=>:present, :value=>"malloc,256m"})
    end

    it "should create a new entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "user",
        :value    => "varnish",
        :target   => target,
        :provider => provider
      ))

      augparse_filter(target, "Shellvars_list.lns", 'DAEMON_OPTS', '
        { "DAEMON_OPTS"
          { "quote" = "\"" }
          { "value" = "-a" }
          { "value" = ":6081" }
          { "value" = "-T" }
          { "value" = "localhost:6082" }
          { "value" = "-f" }
          { "value" = "/etc/varnish/default.vcl" }
          { "value" = "-S" }
          { "value" = "/etc/varnish/secret" }
          { "value" = "-s" }
          { "value" = "malloc,256m" }
          { "value" = "-u" }
          { "value" = "varnish" }
        }
      ')
    end

    it "should update existing entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "listen_address",
        :value    => "localhost",
        :target   => target,
        :provider => provider
      ))

      augparse_filter(target, "Shellvars_list.lns", 'DAEMON_OPTS', '
        { "DAEMON_OPTS"
          { "quote" = "\"" }
          { "value" = "-a" }
          { "value" = "localhost:6081" }
          { "value" = "-T" }
          { "value" = "localhost:6082" }
          { "value" = "-f" }
          { "value" = "/etc/varnish/default.vcl" }
          { "value" = "-S" }
          { "value" = "/etc/varnish/secret" }
          { "value" = "-s" }
          { "value" = "malloc,256m" }
        }
      ')
    end

    it "should remove existing entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "listen_port",
        :ensure   => "absent",
        :target   => target,
        :provider => provider
      ))

      augparse_filter(target, "Shellvars_list.lns", 'DAEMON_OPTS', '
        { "DAEMON_OPTS"
          { "quote" = "\"" }
          { "value" = "-T" }
          { "value" = "localhost:6082" }
          { "value" = "-f" }
          { "value" = "/etc/varnish/default.vcl" }
          { "value" = "-S" }
          { "value" = "/etc/varnish/secret" }
          { "value" = "-s" }
          { "value" = "malloc,256m" }
        }
      ')
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

      expect(txn.any_failed?).not_to eq(nil)
      expect(@logs.first.level).to eq(:err)
      expect(@logs.first.message.include?(target)).to eq(true)
    end
  end
end

