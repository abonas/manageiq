module EmsContainerHelper::TextualSummary
  #
  # Groups
  #

  def textual_group_properties
    items = %w(name type hostname port cpu_cores memory_resources)
    items.collect { |m| send("textual_#{m}") }.flatten.compact
  end

  def textual_group_relationships
    # Order of items should be from parent to child
    items = []
    items.concat(%w(container_projects container_routes)) if @ems.kind_of?(EmsOpenshift)
    items.concat(%w(container_services container_replicators container_groups container_nodes containers
                    container_image_registries container_images))
    items.collect { |m| send("textual_#{m}") }.flatten.compact
  end

  def textual_group_status
    items = %w(refresh_status)
    items.collect { |m| send("textual_#{m}") }.flatten.compact
  end

  def textual_group_smart_management
    items = %w{zone}
    items.collect { |m| self.send("textual_#{m}") }.flatten.compact
  end

  def textual_group_topology
    items = %w(topology)
    items.collect { |m| send("textual_#{m}") }.flatten.compact
  end
  #
  # Items
  #

  def textual_name
    {:label => "Name", :value => @ems.name}
  end

  def textual_type
    {:label => "Type", :value => @ems.emstype_description}
  end

  def textual_hostname
    {:label => "Hostname", :value => @ems.hostname}
  end

  def textual_memory_resources
    {:label => "Aggregate Node Memory",
     :value => number_to_human_size(@ems.aggregate_memory * 1.megabyte,
                                    :precision => 0)}
  end

  def textual_cpu_cores
    {:label => "Aggregate Node CPU Cores",
     :value => @ems.aggregate_logical_cpus}
  end

  def textual_port
    @ems.supports_port? ? {:label => "Port", :value => @ems.port} : nil
  end

  def textual_zone
    {:label => "Managed by Zone", :image => "zone", :value => @ems.zone.name}
  end

  def textual_refresh_status
    last_refresh_status = @ems.last_refresh_status.titleize
    if @ems.last_refresh_date
      last_refresh_date = time_ago_in_words(@ems.last_refresh_date.in_time_zone(Time.zone)).titleize
      last_refresh_status << " - #{last_refresh_date} Ago"
    end
    {
      :label => "Last Refresh",
      :value => [{:value => last_refresh_status},
                 {:value => @ems.last_refresh_error.try(:truncate, 120)}],
      :title => @ems.last_refresh_error
    }
  end

  def textual_topology
    label = 'Topology'
    h     = {:label => label, :image => "container_topology"}
    h[:link]  = url_for(:controller => 'container_topology', :action => 'show', :id => @ems.id)
    h[:title] = "Show topology"
    h
  end
end
