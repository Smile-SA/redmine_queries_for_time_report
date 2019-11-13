# Smile - add methods to the Redmine::Helpers::TimeReport class
#
# 1/ module NewCriteria
# * #77476 Demandes : colonne Tâche racine
# * + version type custom fields added
#
# * #797962 Time Entry Report Queries

module Smile
  module RedmineOverride
    module HelpersOverride
      module TimeReportOverride
        #***************
        # 1/ NewCriteria
        module NewCriteria
          def self.prepended(base)
            #####################
            # 1/ Instance methods
            new_criteria_instance_methods = [
              :load_available_criteria, # 2/ OVERRIDEN
            ]

            if ! defined?(Localizable)
              SmileTools.trace_override "#{base.name}       NOT overriden  plugin localizable NOT installed < (SM::RedmineOverride::HelpersOverride::TimeReportOverride::NewCriteria)"
              return
            end

            smile_instance_methods = base.instance_methods.select{|m|
                base.instance_method(m).owner == self
              }

            trace_first_prefix = "RM::HP::TimeReport    instance_methods  "
            trace_prefix       = "#{' ' * (base.name.length - 5)}           --->  "
            last_postfix       = '< (SM::RedmineOverride::HelpersOverride::TimeReportOverride::NewCriteria)'

            SmileTools::trace_by_line(
              smile_instance_methods,
              trace_first_prefix,
              trace_prefix,
              last_postfix
            )

            ##################
            # 2/ Class methods
            new_criteria_class_methods = [
              :get_available_criteria,     # 1/ new method
            ]

            base.singleton_class.prepend ClassMethods

            last_postfix    = '< (SM::RedmineOverride::HelpersOverride::TimeReportOverride::BAR::CMeths)'

            smile_class_methods = base.methods.select{|m|
                base.method(m).owner == ClassMethods
              }

            missing_class_methods = new_criteria_class_methods.select{|m|
              !smile_class_methods.include?(m)
            }

            if missing_class_methods.any?
              trace_first_prefix = "RM::HP::TimeReport MISS        methods  "
            else
              trace_first_prefix = "RM::HP::TimeReport             methods  "
            end

            SmileTools::trace_by_line(
              (
                missing_class_methods.any? ?
                missing_class_methods :
                smile_class_methods
              ),
              trace_first_prefix,
              trace_prefix,
              last_postfix
            )

            if missing_class_methods.any?
              raise trace_first_prefix + missing_class_methods.join(', ') + '  ' + last_postfix
            end
          end # def self.prepended

          # 2/ EXTENDED, RM V4.0.0 OK
          # Smile specific #797962 Time Entry Report Queries
          # Smile specific #77476 Demandes : colonne Tâche racine
          # Smile specific : criteria MOVED to get_available_criteria
          # Smile specific : will be used in Time Report Queries
          def load_available_criteria
            @available_criteria = self.class.get_available_criteria(@project)
          end

          module ClassMethods
            # 1/ new method, RM 4.0.0 OK
            # Smile specific #797962 Time Entry Report Queries
            def get_available_criteria(project)
              available_criteria = { 'project' => {:sql => "#{TimeEntry.table_name}.project_id",
                                                   :klass => Project,
                                                   :label => :label_project},
                                      'status' => {:sql => "#{Issue.table_name}.status_id",
                                                   :klass => IssueStatus,
                                                   :label => :field_status},
                                      'version' => {:sql => "#{Issue.table_name}.fixed_version_id",
                                                   :klass => ::Version,
                                                   :label => :label_version},
                                      'category' => {:sql => "#{Issue.table_name}.category_id",
                                                     :klass => IssueCategory,
                                                     :label => :field_category},
                                      'user' => {:sql => "#{TimeEntry.table_name}.user_id",
                                                  :klass => User,
                                                  :label => :label_user},
                                      # Smile specific #831011: Time Report Query : Author criteria
                                      'author' => {:sql => "#{TimeEntry.table_name}.author_id",
                                                  :klass => User,
                                                  :label => :field_author},
                                      'tracker' => {:sql => "#{Issue.table_name}.tracker_id",
                                                   :klass => Tracker,
                                                   :label => :label_tracker},
                                      'activity' => {:sql => "#{TimeEntry.table_name}.activity_id",
                                                    :klass => TimeEntryActivity,
                                                    :label => :label_activity},
                                      'issue' => {:sql => "#{TimeEntry.table_name}.issue_id",
                                                  :klass => Issue,
                                                  :label => :label_issue},
                                      # Smile specific  #831012: Time Report Query : Spent on Criteria
                                      'spent_on' => {:sql => "#{TimeEntry.table_name}.spent_on",
                                                    :label => :field_spent_on}
                                    }

              ################
              # Smile specific #77476 Demandes : colonne Tâche racine
              # TODO root, parent move to redmine_smile_enhancements plugin
              available_criteria['root'] = {:sql => "#{Issue.table_name}.root_id",
                                             :klass => Issue,
                                             :label => :field_issue_root_id}

              available_criteria['parent'] = {:sql => "#{Issue.table_name}.parent_id",
                                               :klass => Issue,
                                               :label => :field_issue_parent_id}
              # END -- Smile specific #77476 Demandes : colonne Tâche racine
              #######################

              ################
              # Smile specific #473776 Spent Time Report : Filter on Assignee's group
              available_criteria['assigned_to'] = {:sql => "#{Issue.table_name}.assigned_to_id",
                                             :klass => User,
                                             :label => :field_assigned_to}

              ################
              # Smile specific #269602 Rapport de temps : critère BU
              # TODO bu move to redmine_smile_enhancements plugin
              # Criteria sorted by alphabetical order in the Smile plugin
              # => No need to put it near the project criterium
              unless project
                available_criteria['bu'] = { :sql => 'bu_project_id.customized_id',
                                              :klass => Project,
                                              :label => :label_bu}
              end
              # END -- Smile specific #269602 Rapport de temps : critère BU
              #######################

              # Add time entry custom fields
              custom_fields = TimeEntryCustomField.visible
              # Add project custom fields
              custom_fields += ProjectCustomField.visible
              # Add issue custom fields
              custom_fields += project.nil? ? IssueCustomField.visible.for_all : project.all_issue_custom_fields.visible
              # Add time entry activity custom fields
              custom_fields += TimeEntryActivityCustomField.visible

              # Add list and boolean custom fields as available criteria
              # Smile comment : NATIVE code
=begin
              custom_fields.select {|cf| %w(list bool).include?(cf.field_format) && !cf.multiple?}.each do |cf|
                available_criteria["cf_#{cf.id}"] = {:sql => cf.group_statement,
                                                     :joins => cf.join_for_order_statement,
                                                     :format => cf.field_format,
                                                     :custom_field => cf,
                                                     :label => cf.name}
              end
=end

              ################
              # Smile specific : version type custom fields added
              #
              # Add list and boolean custom fields as available criteria
              # Smile specific : add version custom fields + multiple custom fields
              custom_fields.select {|cf| %w(list bool version).include?(cf.field_format)}.each do |cf|
                available_criteria["cf_#{cf.id}"] = {:sql => cf.group_statement,
                                                     :joins => cf.join_for_order_statement,
                                                     :format => cf.field_format,
                                                     :custom_field => cf,
                                                     :label => cf.name}
              end


              available_criteria
            end
          end
        end # module NewCriteria
      end # module TimeReportOverride
    end # module HelpersOverride
  end # module RedmineOverride
end # module Smile
