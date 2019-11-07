# Smile - add methods to the Query model
#
# 1/ module Enhancements
# * #784714 V4.0.0 : My page Time Entry queries

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module QueryOverride
      #********************
      # 1/ Query4TimeReport
      module Query4TimeReport
        # extend ActiveSupport::Concern

        def self.prepended(base)
          #####################
          # 1/ Instance methods
          time_report_queries_instance_methods = [
            :name_and_project, # 1/ new method          RM 4.0.0 OK
          ]

          trace_prefix = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix = '< (SM::MO::QueryOverride::Query4TimeReport)'


          smile_instance_methods = base.public_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }
          smile_instance_methods += base.protected_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          missing_instance_methods = time_report_queries_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS            instance_methods  "
          else
            trace_first_prefix = "#{base.name}                 instance_methods  "
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

        # 1/ new method          RM 4.0.3 OK
        # Smile specicfic #784714 V4.0.0 : My page Time Entry queries
        def name_and_project
          return name unless project

          "#{::ERB::Util.h name}&nbsp;&nbsp;|&nbsp;&nbsp;#{::ERB::Util.h project.name}".html_safe
        end
      end # module Query4TimeReport
    end # module QueryOverride
  end # module Models
end # module Smile
