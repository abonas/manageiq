class ContainerTopologyController < ApplicationController
  #
  # before_filter :check_privileges
  before_filter :get_session_data
  after_filter :cleanup_action
  after_filter :set_session_data

  def show
    topology = build_topology
    @topologyitems = topology[:items].to_json
    @topologyrelations = topology[:relations].to_json
    @topologykinds = topology[:kinds].to_json
  end

  def index
    redirect_to :action => 'show'
  end

  def data
    render :json => {
        :data => build_topology
     }
  end
  private

  def get_session_data
    @layout = "container_topology"
  end

  def set_session_data
    session[:layout] = @layout
  end

  def build_topology
    if params[:id]
      provider = EmsContainer.find(params[:id].to_i)
      nodes = provider.container_nodes
      services = provider.container_services
    else
      nodes = ContainerNode.all
      services = ContainerService.all
    end
    topology = {}
    topo_items = {}
    links = []

    nodes.each { |n|
      topo_items[n.ems_ref] = {:metadata => {:id  => n.ems_ref, :name => n.name}, :kind => "Node"}
      if n.container_groups.size > 0
        n.container_groups.each { | cg |
          topo_items[cg.ems_ref] = {:metadata => {:id => cg.ems_ref, :name => cg.name }, :kind => "ContainerGroup"}
          links << {:source => n.ems_ref, :target => cg.ems_ref}
          cg.containers.each { | c |
            topo_items[c.ems_ref] = {:metadata => {:id => c.ems_ref, :name => c.name }, :kind => "Container"}
            links << {:source => cg.ems_ref, :target => c.ems_ref}
          }
        }

      end
      unless n.lives_on.nil?
        lives_on_machine = n.lives_on
        kind = lives_on_machine.type.start_with?('Vm') ? "VM" :"Host"
        topo_items[lives_on_machine.uid_ems] = {:metadata => {:id => lives_on_machine.uid_ems, :name => lives_on_machine.name }, :kind => kind}
        links << {:source => n.ems_ref, :target => lives_on_machine.uid_ems}
        if kind == 'VM' # add link to Host
          host = lives_on_machine.host
          topo_items[host.uid_ems] = {:metadata => {:id => host.uid_ems, :name => host.name }, :kind => 'Host'}
          links << {:source => lives_on_machine.uid_ems, :target => host.uid_ems}
        end
      end
    }

    services.each { |s|
      topo_items[s.ems_ref] = {:metadata => {:id => s.ems_ref, :name => s.name}, :kind => "Service"}
      if s.container_groups.size > 0
        s.container_groups.each { | cg | links << {:source => s.ems_ref, :target => cg.ems_ref} }
      end
    }

    topology[:items] = topo_items
    topology[:relations] = links
    topology[:kinds] = {
        ContainerGroup: '#vertex-ContainerGroup',
        Container: '#vertex-Container',
        Node: '#vertex-Node',
        Service: '#vertex-Service',
        Host: '#vertex-Host',
        VM: '#vertex-VM'
    }
    topology
  end

end
