module ContainerProviderMixin
  extend ActiveSupport::Concern

  included do
    has_many :container_nodes, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_groups, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_services, :foreign_key => :ems_id, :dependent => :destroy
  end

  module ClassMethods
    def raw_api_endpoint(hostname, port)
      URI::HTTPS.build(:host => hostname, :port => port.to_i)
    end
  end

  # UI methods for determining availability of fields
  def supports_port?
    true
  end

  def api_endpoint
    self.class.raw_api_endpoint(hostname, port)
  end

  def connect(options = {})
    self.class.raw_connect(hostname, port, options[:service])
  end

  def authentication_check
    # TODO: support real authentication using certificates
    [true, ""]
  end

  def verify_credentials(_auth_type = nil, _options = {})
    # TODO: support real authentication using certificates
    true
  end

  def authentication_status_ok?(_type = nil)
    # TODO: support real authentication using certificates
    true
  end

  # required by aggregate_hardware
  def all_computer_system_ids
    MiqPreloader.preload(container_nodes, :computer_system)
    container_nodes.collect { |n| n.computer_system.id }
  end

  def aggregate_logical_cpus(targets = nil)
    aggregate_hardware(:computer_systems, :logical_cpus, targets)
  end

  def aggregate_memory(targets = nil)
    aggregate_hardware(:computer_systems, :memory_cpu, targets)
  end
end
