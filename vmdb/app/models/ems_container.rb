class EmsContainer < ExtManagementSystem
  SUBCLASSES = %w(
    EmsKubernetes
  )

  def self.types
    subclasses.collect(&:ems_type)
  end

  def self.supported_subclasses
    subclasses
  end

  def self.supported_types
    types
  end

  # Preload any subclasses of this class, so that they will be part of the
  #   conditions that are generated on queries against this class.
  EmsContainer::SUBCLASSES.each { |c| require_dependency Rails.root.join("app", "models", "#{c.underscore}.rb").to_s }
end
