# Smile - add methods to the Redmine::MyPage module
#
# 1/ module Query4TimeReport
# - #784714: V4.0.0 : My page Time Entry queries

module Smile
  module RedmineOverride
    module MyPage
      #********************
      # 1/ Query4TimeReport
      module Query4TimeReport
        def self.prepended(base)
          relay_role_instance_methods = [
          ]

          Redmine
          # Smile specific : why private ? because Fetcher is a class ?
          smile_instance_methods = base.private_instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_first_prefix = "RM::Fetcher instance_methods  "
          trace_prefix       = "#{' ' * (base.name.length - 1)}               --->  "
          last_postfix       = '< (SM::RedmineOverride::MyPage::Query4TimeReport)'

          SmileTools::trace_by_line(
            smile_instance_methods,
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_queries_for_time_report
          )
        end # def self.prepended
      end # module Query4TimeReport
    end # module MyPage
  end # module RedmineOverride
end # module Smile
