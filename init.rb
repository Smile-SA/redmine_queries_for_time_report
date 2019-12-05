# encoding: UTF-8

require 'redmine'

###################
# 1/ Initialisation
Rails.logger.info 'o=>'
Rails.logger.info 'o=>Starting Redmine Queries for Time Report plugin for Redmine'
Rails.logger.info "o=>Application user : #{ENV['USER']}"


plugin_name = :redmine_queries_for_time_report
plugin_root = File.dirname(__FILE__)

# lib/not_reloaded
require plugin_root + '/lib/not_reloaded/smile_tools'

Redmine::Plugin.register plugin_name do
  ########################
  # 2/ Plugin informations
  name 'Redmine - Time Report Queries'
  author 'Jérôme BATAILLE'
  author_url "mailto:Jerome BATAILLE <redmine-support@smile.fr>?subject=#{plugin_name}"
  description 'Adds Queries to Time Report like Time Entry Queries'
  url "https://github.com/Smile-SA/#{plugin_name}"
  version '1.0.1'
  requires_redmine :version_or_higher => '4.0.0'


  #######################
  # 2.1/ Plugin home page
  settings :default => HashWithIndifferentAccess.new(
    ),
    :partial => "settings/#{plugin_name}"

  project_module :issue_tracking do
  end
end # Redmine::Plugin.register ...


#################################
# 3/ Plugin internal informations
# To keep after plugin register
this_plugin = Redmine::Plugin::find(plugin_name.to_s)
plugin_version = '?.?'
# Root relative to application root
plugin_rel_root = '.'
plugin_id = 0
if this_plugin
  plugin_version  = this_plugin.version
  plugin_id       = this_plugin.__id__
  plugin_rel_root = 'plugins/' + this_plugin.id.to_s
end


###############
# 4/ Dispatcher
#Executed each time the classes are reloaded
if !defined?(rails_dispatcher)
  rails_dispatcher = Rails.configuration
end


def prepend_in(dest, mixin_module)
  return if dest.include? mixin_module

  # Rails.logger.info "o=>#{dest}.prepend #{mixin_module}"
  dest.send(:prepend, mixin_module)
end

###############
# 5/ to_prepare
# Executed after Rails initialization
rails_dispatcher.to_prepare do
  Rails.logger.info "o=>"
  Rails.logger.info "o=>\\__ #{plugin_name} V#{plugin_version}"

  SmileTools.reset_override_count(plugin_name)

  SmileTools.trace_override "                                plugin  #{plugin_name} V#{plugin_version}",
    true,
    plugin_name


  #########################################
  # 5.1/ List of files required dynamically
  # Manage dependencies
  # To put here if we want recent source files reloaded
  # Outside of to_prepare, file changed => reloaded,
  # but with primary loaded source code
  required = [
    # lib/
    '/lib/smile_redmine_my_page',
    '/lib/smile_redmine_helpers_time_report',

    # lib/controllers
    '/lib/controllers/smile_controllers_timelog',

    # lib/helpers
    '/lib/helpers/smile_helpers_timelog',
    '/lib/helpers/smile_helpers_my',
    '/lib/helpers/smile_helpers_queries',

    # lib/models
    '/lib/models/smile_models_query',
  ]

  if Rails.env == "development"
    ###########################
    # 5.2/ Dynamic requirements
    Rails.logger.debug "o=>require_dependency"
    required.each{ |d|
      # Reloaded each time modified
      Rails.logger.debug "o=>  #{plugin_rel_root + d}"
      require_dependency plugin_root + d
    }
    required = nil

    # Folders whose contents should be reloaded, NOT including sub-folders

#    ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(plugin_root)}/}

    autoload_plugin_paths = ['/lib/controllers', '/lib/helpers', '/lib/models']

    Rails.logger.debug 'o=>'
    Rails.logger.debug "o=>autoload_paths / watchable_dirs +="
    autoload_plugin_paths.each{|p|
      new_path = plugin_root + p
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      ActiveSupport::Dependencies.autoload_paths << new_path
      rails_dispatcher.watchable_dirs[new_path] = [:rb]
    }
  else
    ##########################
    # 5.3/ Static requirements
    Rails.logger.debug "o=>require"
    required.each{ |p|
      # Never reloaded
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      require plugin_root + p
    }
  end
  # END -- Manage dependencies


  ##############
  # 6/ Overrides
  require_dependency 'lib/redmine/my_page'
  prepend_in(Redmine::MyPage, Redmine::MyPage::Query4TimeReport)

  prepend_in(Redmine::Helpers::TimeReport,
      Smile::RedmineOverride::HelpersOverride::TimeReportOverride::NewCriteria
    )


  #***************************
  # **** 6.1/ Controllers ****
  #Rails.logger.info "o=>----- CONTROLLERS"
  prepend_in(TimelogController, Smile::Controllers::TimelogOverride::Query4TimeReport)


  #***********************
  # **** 6.2/ Helpers ****
  Rails.logger.info "o=>----- HELPERS"
  prepend_in(TimelogHelper, Smile::Helpers::TimelogOverride::Query4TimeReport)
  prepend_in(MyHelper, Smile::Helpers::MyOverride::Query4TimeReport)
  prepend_in(QueriesHelper, Smile::Helpers::QueriesOverride::Query4TimeReport)

  #**********************
  # **** 6.3/ Models ****
  Rails.logger.info "o=>----- MODELS"
  prepend_in(Query, Smile::Models::QueryOverride::Query4TimeReport)


  # keep traces if classes / modules are reloaded
  SmileTools.enable_traces(false, plugin_name)

  Rails.logger.info 'o=>/--'
end
