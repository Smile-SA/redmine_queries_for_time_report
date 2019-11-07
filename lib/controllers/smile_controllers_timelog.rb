# Smile - override methods to the Timelog controller
#
# 1/ module Query4TimeReport
# - #797962 Time Entry Report Queries
#   2019


#require 'active_support/concern' #Rails 3

module Smile
  module Controllers
    module TimelogOverride
      module Query4TimeReport
        def self.prepended(base)
          b_a_r_and_relay_role_and_enhancements_instance_methods = [
            :report,                               # 1/  REWRITTEN,  RM V4.0.0 OK

            # following private
            :retrieve_time_report_query,           # 10/ New method, RM V4.0.0 OK
          ]

          smile_instance_methods = base.public_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }
          smile_instance_methods += base.protected_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }
          smile_instance_methods += base.private_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_prefix       = "#{' ' * ('TimelogController'.length - 6)}                       --->  "
          last_postfix       = '< (SM::CO::TimelogOverride::Query4TimeReport)'

          missing_instance_methods = b_a_r_and_relay_role_and_enhancements_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MIS instance_methods  "
          else
            trace_first_prefix = "#{base.name}     instance_methods  "
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
            raise trace_first_prefix + last_postfix + ' : ' + missing_instance_methods.join(', ')
          end
        end # def self.included(base)

        # 1/ REWRITTEN, RM 4.0.3 OK
        # Smile specific #797962 Time Entry Report Queries
        def report
          # Smile comment : NATIVE source code
          # retrieve_time_entry_query
          retrieve_time_report_query

          # Smile comment : NATIVE source code, replaced by method to override it
          # @report = Redmine::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], scope)
          prepare_report_object

          respond_to do |format|
            format.html { render :layout => !request.xhr? }
            format.csv  { send_data(report_to_csv(@report), :type => 'text/csv; header=present', :filename => 'timelog.csv' ) }
          end
        end


      #############
      # private !!!
      private

        # 10/ New method, RM 4.0.3 OK
        # Smile specific #797962 Time Entry Report Queries
        def retrieve_time_report_query
          retrieve_query(TimeReportQuery, false, :defaults => @default_columns_names)
        end
      end # module Query4TimeReport
    end # module TimelogOverride
  end # module Controllers
end # module Smile
