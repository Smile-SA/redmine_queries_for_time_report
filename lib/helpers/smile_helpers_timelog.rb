# Smile - timelog_helper enhancement
#
# - 1/ module ::Query4TimeReport
#      #342633 Redmine time report : only spent time option
#      #342717 Redmine time report : Estimated time option
#      #342764 Redmine time report : option to show previous time entries total
#      #408972 Optimisation : Rapport temps passé, cache criteria values

module Helpers
  module SmileHelpersTimelog
    module TimelogOverride
      #********************
      # 1/ Query4TimeReport
      module Query4TimeReport
        def self.prepended(base)
          queries_4_time_report_instance_methods = [
            :prepare_report_object, # 1/ New method, RM V4.0.0 OK
            :time_entry_scope,      # 2/ New method, RM V4.0.0 OK
          ]

          # Smile comment : module_eval mandatory with helpers, but no more access to rewritten methods
          # Smile comment : => use of alias method to access to ancestor version
          base.module_eval do
            # 1/ New method, RM 4.0.0 OK
            # Smile specific #784714: V4.0.0 : My page Time Entry queries
            def prepare_report_object
              # Smile comment : time_entry_scope NATIVE source code
              @scope = time_entry_scope

              # Smile specific : params[:criteria] -> @query.criteria, columns is the periods interval
              # Smile specific : params[:columns] -> @query.period, columns is the periods interval
              # Smile specific : scope (= time_entry_scope) -> @scope, used in My Page queries
              @report = Redmine::Helpers::TimeReport.new(@project, @issue, @query.criteria, @query.period, @scope)
              # Smile comment : NATIVE source code
              # @report = Redmine::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], scope)
            end

            # 2/ New method, RM 4.0.0 OK
            # Smile specific #784714: V4.0.0 : My page Time Entry queries
            # Returns the TimeEntry scope for index and report actions
            def time_entry_scope(options={})
              @query.results_scope(options)
            end
          end # base.module_eval do

          trace_prefix       = "#{' ' * (base.name.length + 19)}  --->  "
          last_postfix       = '< (SM::HO::TimelogOverride::Query4TimeReport)'

          smile_instance_methods = base.instance_methods.select{|m|
              queries_4_time_report_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_timelog', :redmine_queries_for_time_report)
            }

          missing_instance_methods = queries_4_time_report_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS    instance_methods  "
          else
            trace_first_prefix = "#{base.name}         instance_methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_instance_methods.any? ?
              missing_instance_methods :
              smile_instance_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
              :redmine_queries_for_time_report
          )

          if missing_instance_methods.any?
            raise trace_first_prefix + missing_instance_methods.join(', ') + '  ' + last_postfix
          end
        end # def self.extended
      end # module Query4TimeReport
    end # module TimelogOverride
  end # module SmileHelpersTimelog
end # module Helpers
