require 'rails/generators'

module GuardJest
  class InstallGenerator < Rails::Generators::Base
    desc 'Install a sample Guardfile for running Jest specs via GuardJest'

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

    # Generator Code. Remember this is just suped-up Thor so methods are executed in order
    def install
      template 'Guardfile'
    end
  end
end
