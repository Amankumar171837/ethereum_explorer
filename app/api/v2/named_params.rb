# frozen_string_literal: true

module API
  module V2
    module NamedParams
      extend ::Grape::API::Helpers

      params :pagination_filters do
        optional :page,
          type: { value: Integer, message: 'non_integer_page' },
          values: { value: -> (p){ p.try(:positive?) }, message: 'non_positive_page'},
          default: 1,
          desc: 'Page number (defaults to 1).'
        optional :limit,
          type: { value: Integer, message: 'non_integer_limit' },
          values: { value: 1..100, message: 'invalid_limit' },
          default: 100,
          desc: 'Number of users per page (defaults to 100, maximum is 100).'
      end

      params :timeperiod_filters do
        optional :from,
                 type: Time,
                 desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                   'If set, only records FROM the time will be retrieved.'
        optional :to,
                 type: Time,
                 desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                   'If set, only records BEFORE the time will be retrieved.'
      end

      params :ordering do
        optional :ordering,
                 values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'admin.ordering.invalid_ordering' },
                 default: 'asc',
                 desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
        optional :order_by,
                 default: 'time',
                 desc: 'Name of the field, which result will be ordered by.'
      end

      params :dimensions do
        optional :x,
                 desc: 'x-axis of the image'
        optional :y,
                 desc: 'y-axis of the image'
        optional :h,
                 desc: 'Height of the image'
        optional :w,
                 desc: 'Width of the image'
        all_or_none_of :x, :y, :h, :w, message: 'media.crop.missing_parameters'
      end
    end
  end
end
