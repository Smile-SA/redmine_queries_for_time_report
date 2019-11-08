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
          ##################
          # 1/ Class methods
          my_page_queries_class_methods = [
            :additional_blocks, # 1/ REWRITTEN,  RM V4.0.3 OK
          ]

          # Methods dynamically rewritten in the Helper module
          base.module_eval do
            # 1/ Smile specific : REWRITTEN
            #
            # Returns the additional blocks that are defined by plugin partials
            def self.additional_blocks
              @@additional_blocks ||= Dir.glob("#{Redmine::Plugin.directory}/*/app/views/my/blocks/_*.{rhtml,erb}").inject({}) do |h,file|
                name = File.basename(file).split('.').first.gsub(/^_/, '')

                ################
                # Smile specific : partials overriden in plugin ignored
                unless (
                  # Query selection partials ignored : plugins overrides partial
                  name.end_with?('_query_selection') ||
                  # Core blocks partials ignored : plugins overrides partial
                  (name == 'issues') ||
                  CORE_BLOCKS.keys.include?(name)
                )
                  h[name] = {:label => name.to_sym, :partial => "my/blocks/#{name}"}
                else
                  Rails.logger.debug "==>prof additional_blocks #{name} partial overriden by plugin"
                end

                h
              end
            end
          end

          trace_prefix    = "#{' ' * (base.name.length + 27)}  --->  "
          last_postfix    = '< (SM::RedmineOverride::MyPage::Query4TimeReport::CMeths)'

          smile_class_methods = base.methods.select{|m|
              my_page_queries_class_methods.include?(m) &&
                base.method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/smile_redmine_my_page', :redmine_queries_for_time_report)
            }

          missing_class_methods = my_page_queries_class_methods.select{|m|
            !smile_class_methods.include?(m)
          }

          if missing_class_methods.any?
            trace_first_prefix = "RM::MyPage MISS                methods  "
          else
            trace_first_prefix = "RM::MyPage                     methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_class_methods.any? ?
              missing_class_methods :
              smile_class_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_queries_for_time_report
          )

          if missing_class_methods.any?
            raise trace_first_prefix + missing_class_methods.join(', ') + '  ' + last_postfix
          end

          #############################
          # 2/ Augment CORE_BLOCKS hash
          my_page_queries_new_blocks = [
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
            my_page_queries_new_blocks,
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
