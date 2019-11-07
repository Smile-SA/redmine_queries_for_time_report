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
          my_page_queries = [
            'timelog',
            '+timelogquery',
            '+timereportquery'
          ]

          core_blocks = Redmine::MyPage::CORE_BLOCKS

          # Changes label : label_spent_time -> label_time_by_activity
          core_blocks['timelog'][:label] = :label_time_by_activity

          unless core_blocks.key?('timelogquery')
            core_blocks['timelogquery'] = {
                :label => :label_time_entry_plural,
                :max_occurs => 3
              }
          end

          unless core_blocks.key?('timereportquery')
            core_blocks['timereportquery'] = {
                :label => :label_time_report_query_plural,
                :max_occurs => 3
              }
          end

          trace_first_prefix = "RM::MyPage           CORE_BLOCKS const  "
          trace_prefix       = "#{' ' * (base.name.length - 1)}               --->  "
          last_postfix       = '< (SM::RedmineOverride::MyPage::Query4TimeReport)'

          SmileTools::trace_by_line(
            my_page_queries,
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
