require 'features/go_toolchain_spec'

describe 'go installation', dev: true do
  describe command('gimme -l') do
    its(:stdout) { should_not be_empty }
  end
end
