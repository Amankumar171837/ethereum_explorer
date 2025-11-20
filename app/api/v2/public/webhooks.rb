# frozen_string_literal: true

module API::V2
  module Public
    class Webhooks < Grape::API
      desc 'webhook for bulkgate'
      get '/bulkgate' do
        return unless params[:smsID]

        log = ServiceLog.find_by(sms_id: params[:smsID], result: 'accepted')
        error!({ errors: ['webhook.bulkgate.invalid.sms_id'] }, 404) unless log

        log.update!(result: ServiceLog::STATUS_LIST[params[:status].to_i])

        status 201
      end

      desc 'webhook for smsala'
      post '/smsala' do
        return unless params['message_id']

        log = ServiceLog.find_by(sms_id: params['message_id'])
        error!({ errors: ['webhook.smsala.message_id_not_found'] }, 404) unless log

        log.metadata.merge!({ 'SMSID': params['SMSID'] })
        log.update!(result: params['DLRStatus'])

        status 201
      end

      desc 'webhook for ding'
      post '/ding' do
        return unless params['payload']['verification_id']

        log = ServiceLog.where(sms_id: params['payload']['verification_id']).last
        return status 204 unless log

        log.metadata.merge!({ "#{params['id']}": params })

        status = if params['type'] == 'verify.attempt'
                   params['payload']['delivery_status']
                 elsif params['type'] == 'verify.delivery_status'
                   params['payload']['status']
                 end

        log.update!(result: status) if status.present?

        status 200
      end

      desc 'webhook for mobivate'
      post '/mobivate' do
        return unless params[:deliveryMessageId]

        log = ServiceLog.find_by(sms_id: params[:deliveryMessageId])
        error!({ errors: ['webhook.mobivate.invalid.message_id'] }, 404) unless log

        log.metadata.merge!({ "#{SecureRandom.alphanumeric(3)}": params })
        log.update!(result: params['status'].downcase)

        status 201
      end
    end
  end
end
