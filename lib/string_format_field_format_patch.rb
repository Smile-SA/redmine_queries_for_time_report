require_dependency 'redmine/field_format'

module Redmine
  module FieldFormat
    Rails.logger.info "o=>adding group_statement to StringFormat"

    # Plugin : new class for format
    class StringFormat
      def group_statement(custom_field)
        order_statement(custom_field)
      end
    end
  end
end
