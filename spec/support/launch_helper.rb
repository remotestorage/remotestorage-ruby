
module LaunchHelper

  def launch_request(options={})
    method, action = method_and_action
    kick_off method, action, options
  end

  def launch_request_without_super(options={}, &block)
    method, action = method_and_action

    described_class.ancestors[1].send(:alias_method, :stubbed_out_super, action)
    described_class.ancestors[1].send(:define_method, action, block||lambda{})

    kick_off method, action, options

    described_class.ancestors[1].send(:alias_method, action, :stubbed_out_super)
  end

  # shortcuts
  alias launch launch_request
  alias launch_request_with_stubbed_super launch_request_without_super
  alias launch_without_super launch_request_without_super
  alias launch_with_stubbed_super launch_request_without_super

  private

  def kick_off(method, action, options)
    # prepare data for the launch
    parameters = (@params ||{}).merge(options[:params] ||{}) unless options[:params].nil? and @params.nil?
    session = (@session ||{}).merge(options[:session] ||{}) unless options[:session].nil? and @session.nil?
    flash = (@flash ||{}).merge(options[:flash] ||{}) unless options[:flash].nil? and @flash.nil?

    # launch the request with the given options, merged into the related instance variables
    if options[:xhr] || @xhr
      xml_http_request method,
        action,
        parameters,
        session,
        flash
    else
      __send__ method,
        action,
        parameters,
        session,
        flash
    end

    # sidebar assertions use mocks, however those can only be satisfied if the views are rendered.
    # hence we're calling sidebar_entries manually here, to force loading of the entries:
    subject.send(:sidebar_entries) if subject.respond_to?(:sidebar_entries)

    # this verifies all previously set method expectations
    # thusly, state verification takes place _after_ behaviour
    RSpec::Mocks.verify
  end

  def method_and_action
    focus = self.class.instance_variable_get('@metadata')

    # find the nearest action verb
    while focus = focus[:example_group] do
      action = focus[:description] and break if described_class.action_methods.include?(focus[:description])
    end

    raise "you need to specify an action of #{described_class}" unless action

    # find the method corresponding to the action
    method = @method || {
      'create' => :post,
      'update' => :put,
      'destroy' => :delete
    }[action] || :get

    return method, action
  end

end
