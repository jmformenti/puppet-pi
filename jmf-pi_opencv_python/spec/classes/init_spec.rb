require 'spec_helper'
describe 'pi_opencv_python' do

  context 'with defaults for all parameters' do
    it { should contain_class('pi_opencv_python') }
  end
end
