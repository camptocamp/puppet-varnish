require 'spec_helper'
describe 'varnish' do
  context 'when on RedHat' do
    let (:facts) { {
      :operatingsystem => 'RedHat',
    } }

    it { should compile.with_all_deps }
  end
end
