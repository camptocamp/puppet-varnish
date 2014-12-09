#!/usr/bin/env rspec

require 'spec_helper'

provider = :redhat_systemd
provider_class = Puppet::Type.type(:varnish_param).provider(provider)

describe provider_class do
  before :each do
    Facter.fact(:osfamily).stubs(:value).returns 'RedHat'
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
        :name     => "max_threads",
        :value    => "100",
        :target   => target,
        :provider => provider
      ))

      aug_open(target, "Shellvars.lns") do |aug|
        expect(aug.get('VARNISH_MAX_THREADS')).to eq('100')
      end
    end

    it "should create a new entry after an existing comment" do
      apply!(Puppet::Type.type(:varnish_param).new(
        :name     => "listen_address",
        :value    => "localhost",
        :target   => target,
        :provider => provider
      ))

      aug_open(target, "Shellvars.lns") do |aug|
        expect(aug.get('VARNISH_LISTEN_ADDRESS[following-sibling::VARNISH_LISTEN_PORT][1]')).to eq('localhost')
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

