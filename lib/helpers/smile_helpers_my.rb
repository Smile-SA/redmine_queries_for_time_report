require_dependency "my_helper"

module Smile
  module Helpers
    module MyOverride
      module Query4TimeReport
        def self.prepended(base)
          time_report_queries_instance_methods = [
            :render_timelogquery_block,    # 1/ New RM 4.0.0 OK
            :render_timereportquery_block, # 2/ New RM 4.0.0 OK
          ]

          # Smile specific : EXTENDED
          # Smile comment : module_eval mandatory with helpers, that are included in classes without the module prepended sub-modules
          # Smile comment : but no more access to rewritten methods => use of alias method to access to ancestor version
          base.module_eval do
            # Smile specific #784714: V4.0.0 : My page Time Entry queries
            include TimelogHelper

            # New method
            def render_timelogquery_block(block, settings)
              query = TimeEntryQuery.visible.find_by_id(settings[:query_id])

              if query
                query.column_names = settings[:columns] if settings[:columns].present?
                query.sort_criteria = settings[:sort] if settings[:sort].present?

                scope = query.results_scope
                scope = scope.
                  preload(:issue => [:project, :tracker, :status, :assigned_to, :priority]).
                  preload(:project, :user)

                entries = scope.limit(10).to_a

                render :partial => 'my/blocks/partials/timelogs', :locals => {:query => query, :scope => scope, :entries => entries, :block => block, :settings => settings}
              else
                queries = TimeEntryQuery.visible.sorted
                render :partial => 'my/blocks/partials/timelog_query_selection', :locals => {:queries => queries, :block => block, :settings => settings}
              end
            end

            # New method
            def render_timereportquery_block(block, settings)
              @query = TimeReportQuery.visible.find_by_id(settings[:query_id])

              if @query
                if params[:debug]
                  @query.set_debug(params[:debug])
                end

                # Smile comment : no limit to scope
                prepare_report_object

                ################
                # Smile specific #994 Budget and Remaining enhancement
                # TODO override with alias_method in redmine_smile plugin
                # prepare_budget_and_remaining_enabled

                render :partial => 'my/blocks/partials/timereport', :locals => {:query => @query, :scope => @scope, :block => block, :settings => settings}
              else
                queries = TimeReportQuery.visible.sorted
                render :partial => 'my/blocks/partials/timereport_query_selection', :locals => {:queries => queries, :block => block, :settings => settings}
              end
            end
          end

          trace_prefix       = "#{' ' * (base.name.length + 19)}  --->  "
          last_postfix       = '< (SM::HO::MyOverride::Query4TimeReport)'

          smile_instance_methods = base.instance_methods.select{|m|
              time_report_queries_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin(
                    'lib/helpers/smile_helpers_my',
                    :redmine_queries_for_time_report
                  )
            }

          missing_instance_methods = time_report_queries_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS         instance_methods  "
          else
            trace_first_prefix = "#{base.name}              instance_methods  "
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
        end
      end
    end
  end
end
