require File.join( File.dirname(__FILE__), "..", "..",  "spec_helper" )
require File.join( File.dirname(__FILE__), 'shared_examples')

describe Batsir::Notifiers::Notifier do

  it_should_behave_like "a notifier", Batsir::Notifiers::Notifier

  it 'raises an error when the #execute method is not implemented' do
    lambda{ subject.notify({})}.should raise_error NotImplementedError
  end
end
