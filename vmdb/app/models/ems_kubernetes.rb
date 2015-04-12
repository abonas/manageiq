class EmsKubernetes < EmsContainer
  include ContainerProviderMixin

  default_value_for :port, 6443

  def self.ems_type
    @ems_type ||= "kubernetes".freeze
  end

  def self.description
    @description ||= "Kubernetes".freeze
  end

  def self.raw_connect(hostname, port, _options = {})
    require 'kubeclient'
    api_endpoint = raw_api_endpoint(hostname, port)
    kube = Kubeclient::Client.new(api_endpoint)
    # TODO: support real authentication using certificates
    kube.ssl_options(:verify_ssl => OpenSSL::SSL::VERIFY_NONE)
    kube
  end

  def self.event_monitor_class
    MiqEventCatcherKubernetes
  end
end
