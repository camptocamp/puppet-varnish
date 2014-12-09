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

      expect(inst.size).to eq(11)
      expect(inst[0]).to eq({:name=>"vcl_conf", :ensure=>:present, :value=>"/etc/varnish/default.vcl"})
      expect(inst[1]).to eq({:name=>"listen_port", :ensure=>:present, :value=>"6081"})
      expect(inst[2]).to eq({:name=>"admin_listen_address", :ensure=>:present, :value=>"127.0.0.1"})
      expect(inst[3]).to eq({:name=>"admin_listen_port", :ensure=>:present, :value=>"6082"})
      expect(inst[4]).to eq({:name=>"secret_file", :ensure=>:present, :value=>"/etc/varnish/secret"})
      expect(inst[5]).to eq({:name=>"min_threads", :ensure=>:present, :value=>"50"})
      expect(inst[6]).to eq({:name=>"max_threads", :ensure=>:present, :value=>"1000"})
      expect(inst[7]).to eq({:name=>"thread_timeout", :ensure=>:present, :value=>"120"})
      expect(inst[8]).to eq({:name=>"storage_size", :ensure=>:present, :value=>"256M"})
      expect(inst[9]).to eq({:name=>"storage", :ensure=>:present, :value=>"\"malloc,${VARNISH_STORAGE_SIZE}\""})
      expect(inst[10]).to eq({:name=>"ttl", :ensure=>:present, :value=>"120"})
    end

    it "should create a new entry" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "user",
        :value    => "varnish",
        :target   => target,
        :provider => provider
      ))

      aug_open(target, "Shellvars.lns") do |aug|
        expect(aug.get('VARNISH_USER')).to eq('varnish')
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
        expect(aug.get('VARNISH_LISTEN_PORT')).to eq('16081')
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
        expect(aug.match('VARNISH_LISTEN_PORT').size).to eq(0)
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

      expect(txn.any_failed?).not_to eq(nil)
      expect(@logs.first.level).to eq(:err)
      expect(@logs.first.message.include?(target)).to eq(true)
    end
  end
end

