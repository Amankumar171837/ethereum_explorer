# frozen_string_literal: true

module API::V2
  module Resource
    module Validations
      def validate_phone!(phone_number)
        phone_number = Phone.international(phone_number)

        error!({ errors: ['resource.users.invalid_num'] }, 400) \
            unless Phone.valid?(phone_number)

        phone_number
      end
    end
  end
end
