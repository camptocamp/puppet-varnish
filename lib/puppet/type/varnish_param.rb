Puppet::Type.newtype(:varnish_param) do
  @doc = "Manages varnish parameters"

  ensurable do
    defaultvalues

    def insync?(is)
      # Only manage value if it is given
      return true if should == :present and @resource[:value].nil?
      super
    end
  end

  newparam(:name, :namevar => true) do
    desc "The default namevar"
  end

  newproperty(:value) do
    munge do |val|
      val.to_s
    end
  end

  newparam(:varnish_binary) do
    desc "Path to the varnish binary."

    defaultto { '/usr/sbin/varnishd' }
  end

  newparam(:target) do
    desc "The file in which to store the variable."
  end

  autorequire(:file) do
    self[:target]
  end
end

