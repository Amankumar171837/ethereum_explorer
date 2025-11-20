# frozen_string_literal: true

module API::V2::Admin
  module Entities
    class ActivityWithInflux < API::V2::Entities::Base
      expose :user_email,
             documentation:{
               type: 'String',
               desc: 'Parameters which was sent to specific API endpoint'
             }

      expose :target_email,
             documentation:{
               type: 'String',
               desc: 'Parameters which was sent to specific API endpoint'
      }

      expose :target_uid,
             documentation:{
               type: 'String',
               desc: 'Parameters which was sent to specific API endpoint'
      }

      expose :user_ip,
             documentation: {
               type: 'String',
               desc: 'User IP'
             }

      expose :user_agent,
             documentation: {
               type: 'String',
               desc: 'User Browser Agent'
             }

      expose :topic,
             documentation: {
               type: 'String',
               desc: 'Defined topic (session, adjustments) or general by default'
             }

      expose :action,
             documentation: {
               type: 'String',
               desc: "API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method"
             }

      expose :result,
             documentation: {
               type: 'String',
               desc: 'Status of API response: succeed, failed, denied'
             }

      expose :data,
             documentation: {
               type: 'String',
               desc: 'Parameters which was sent to specific API endpoint'
             }

      expose(
        :created_at,
        documentation: {
          type: String,
          desc: 'created date of Activity '
        }
      ){ |s| Time.at(s[:created_at]) }
    end
  end
end
