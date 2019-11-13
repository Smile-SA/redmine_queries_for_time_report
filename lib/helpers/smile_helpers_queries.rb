# Smile - queries_helper enhancement
# - #134828 New issues list columns (Array, IssueRelations, Watchers)
# - #121222: Rapport, info demande séparer tracker, numéro, sujet
# - #994 Budget and Remaining management
# - #222040 Liste des entrées de temps : dé-sérialisation colonne Demande et filtres
# - #238910 Liste des demandes : conversion jours comme dans le rapport
# - #256456 Sauvegarder la case à cocher "Include sub-tasks time"
# - #270175 JournalQuery : Types Brut, Hebdo, Mensuel
# - #330363 Link to issue from subject column wrong
# - #270172: JournalQuery : Filtres sur les champs
#   2015

# module Smile::Helpers::QueriesOverride
# - 1/ module ::Query4TimeReport

module Smile
  module Helpers
    module QueriesOverride
      #********************
      # 1/ Query4TimeReport
      module Query4TimeReport
        def self.prepended(base)
          query_columns_and_bar_instance_methods = [
            # module_eval
            :query_available_criteria_options,       #  1/  New               RM 4.0.0 OK  REPORT QUERY
            :query_selected_criteria_options,        #  2/  New               RM 4.0.0 OK  REPORT QUERY
            :render_query_criteria_selection,        #  3/  New               RM 4.0.0 OK  REPORT QUERY
            :render_period_selection,                #  4/  New               RM 4.0.0 OK  REPORT QUERY
            :period_label,                           #  5/  New               RM 4.0.0 OK  REPORT QUERY
            :redirect_to_time_report_query,          #  6/  New               RM 4.0.0 OK  REPORT QUERY
          ]


          # Methods dynamically added to QueriesHelper, source replaced by module_eval
          # Because we can't use normal methods override
          # => no access to super
          # 2012-01-18 no way to include a module in a module (like InstanceMethods)
          # QueryController
          #  -> has a dynamic module (accessible QueryController.with master_helper_module)
          #     -> includes all Controller helpers :
          #        including QueriesHelper
          #          -> includes modules included in the helpers
          #          -> Pb. 1 : includes the sub modules in the dynamic module => duplication !
          #             - methods already present in QueriesHelper -- OK
          #             - Pb. 2 : new methods in the modules included -- NON-OK
          base.module_eval do # <<READER, __FILE__, (__LINE__ + 1) #does not work
            # 1/ New method, RM 4.0.3 OK  TIME REPORT QUERY
            # Smile specific #797962 Time Entry Report Queries
            def query_available_criteria_options(query)
              available_criteria_options = query.available_criteria_options

              if query.criteria && query.criteria.is_a?(Array)
                available_criteria_options = available_criteria_options.select {|c| !query.criteria.include?(c.second)}
              end

              available_criteria_options
            end

            # 2/ New method, RM 4.0.3 OK  TIME REPORT QUERY
            # Smile specific #797962 Time Entry Report Queries
            def query_selected_criteria_options(query)
              return [] unless query.criteria && query.criteria.is_a?(Array)

              available_criteria_options = query.available_criteria_options

              # Smile comment : do NOT sort !
              selected_criteria_options = []
              query.criteria.each do |c|
                criterium_option = available_criteria_options.find {|co| co.second == c}
                selected_criteria_options << criterium_option if criterium_option
              end

              selected_criteria_options
            end

            # 3/ New method, RM 4.0.3 OK  TIME REPORT QUERY
            def render_query_criteria_selection(query, options={})
              tag_name = (options[:name] || 'criteria') + '[]'
              render :partial => 'queries/criteria', :locals => {:query => query, :tag_name => tag_name}
            end

            # 4/ New method, RM 4.0.3 OK  TIME REPORT QUERY
            def render_period_selection(query)
              render :partial => 'queries/time_report_period', :locals => {:query => query}
            end

            # 5/ New method, RM 4.0.3 OK  TIME REPORT QUERY
            def period_label(query)
              case query.period
                when 'year'
                  l(:label_year)
                when 'month'
                  l(:label_month)
                when 'week'
                  l(:label_week)
                when 'day'
                  l(:label_day_plural).titleize
              end
            end

            # 6/ New method, RM 4.0.3 OK  TIME REPORT QUERY
            def redirect_to_time_report_query(options)
              redirect_to _report_time_entries_path(@project, nil, options)
            end
          end # base.module_eval do

          trace_prefix       = "#{' ' * (base.name.length + 19)}  --->  "
          last_postfix       = '< (SM::HO::QueriesOverride::Query4TimeReport)'


          smile_instance_methods = (base.instance_methods + base.protected_instance_methods).select{|m|
              query_columns_and_bar_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_queries', :redmine_queries_for_time_report)
            }

          missing_instance_methods = query_columns_and_bar_instance_methods.select{|m|
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
        end # def self.prepended
      end # module Query4TimeReport
    end # module QueriesOverride
  end # module Helpers
end # module Smile
