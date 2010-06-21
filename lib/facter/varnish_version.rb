output = %x{varnishstat -V 2>&1}

if $?.exitstatus and output.match(/\(varnish-(\d+\.\d+\.\d+).*\)/)

  Facter.add("varnish_version") do
    setcode do
      $1
    end
  end
end
