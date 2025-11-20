# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over permissions table
      class Phone < Grape::API
        resource :phone do
          helpers do
            def validate_phone!(phone_number)
              phone_number = ::Phone.international(phone_number)

              error!({ errors: ['resource.phone.invalid_num'] }, 400) \
            unless ::Phone.valid?(phone_number)

              error!({ errors: ['resource.phone.number_exist'] }, 400) \
            if ::Phone.verified.find_by_number(phone_number)
            end
          end

          desc 'Edit use Phone number by admin',
               failure: [
                 { code: 401, message: 'Invalid bearer token' }
               ],
               success: API::V2::Entities::Phone
          params do
            requires :phone_number,
                     type: String,
                     allow_blank: false,
                     desc: 'Phone number with country code'
            requires :uid,
                     type: String,
                     allow_blank: false,
                     desc: 'User uid'
          end
          post do
            declared_params = declared(params)
            validate_phone!(declared_params[:phone_number])
            user = User.find_by_uid(params[:uid])
            phone_number = ::Phone.international(declared_params[:phone_number])
            error!({ errors: ['resource.phone.exists'] }, 400) if user.phones.find_by_number(phone_number)

            phone = user.phones.create(number: phone_number)
            code_error!(phone.errors.details, 422) if phone.errors.any?

            EventAPI.notify('model.phone.updated',
                            record: {
                              user: user.as_json_for_event_api,
                              domain: Barong::App.config.domain
                            })
            status 200
          end
        end
      end
    end
  end
end
