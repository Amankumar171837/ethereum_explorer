# Barong
RESTful AdminAPI for barong OAuth server

## Version: 2.7.0

### Security
**BearerToken**  

| basic | *Basic* |
| ----- | ------- |
| Description | Bearer Token authentication |
| Name | Authorization |
| In | header |

---
## api
Operations about apis

### /api/v2/barong/admin/users/{uid}

#### GET
##### Description

Returns user info

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | path | user uniq id | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns user info | [API_V2_Admin_Entities_UserWithProfile](#api_v2_admin_entities_userwithprofile) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users

#### PUT
##### Description

Update user attributes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | user uniq id | Yes | string |
| email | formData | User Email | No | string |
| state | formData | user state | No | string |
| otp | formData | user 2fa status | No | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User attributes were created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of users as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| extended | query | When true endpoint returns full information about users | No | boolean |
| uid | query |  | No | string |
| email | query |  | No | string |
| role | query |  | No | string |
| country | query |  | No | string |
| level | query |  | No | integer |
| state | query |  | No | string |
| phone_number | query |  | No | string |
| username | query |  | No | string |
| platform | query |  | No | string |
| referral_of | query |  | No | string |
| referral_limit | query |  | No | string |
| range | query |  | No | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of users as paginated collection | [API_V2_Admin_Entities_User](#api_v2_admin_entities_user) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users/role

#### POST
##### Description

Update user role

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | user uniq id | Yes | string |
| role | formData | user role | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User role was created |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/users/update

#### POST
##### Description

Update user attributes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | user uniq id | Yes | string |
| state | formData | user state | No | string |
| remark | formData | remark on state change | No | string |
| otp | formData | user 2fa status | No | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User attributes were updated |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/users/search

#### GET
##### Description

Returns array of users as paginated collection (Elasticsearch)

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | query |  | No | string |
| email | query |  | No | string |
| role | query |  | No | string |
| country | query |  | No | string |
| level | query |  | No | integer |
| state | query |  | No | string |
| phone_number | query |  | No | string |
| username | query |  | No | string |
| platform | query |  | No | string |
| referral_of | query |  | No | string |
| referral_limit | query |  | No | integer |
| range | query |  | No | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of users as paginated collection (Elasticsearch) | [API_V2_Admin_Entities_User](#api_v2_admin_entities_user) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users/labels

#### DELETE
##### Description

Deletes label for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | query | user uniq id | Yes | string |
| key | query | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| scope | query | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Label was deleted |
| 401 | Invalid bearer token |

#### PUT
##### Description

Update user label scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | user uniq id | Yes | string |
| key | formData | Label key. | Yes | string |
| scope | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| description | formData | label description. [A-Za-z0-9_-] should be used. max - 255 characters. | No | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Label was updated |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

#### POST
##### Description

Add label for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | user uniq id | Yes | string |
| key | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| value | formData | label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | Yes | string |
| description | formData | label description. [A-Za-z0-9_-] should be used. max - 255 characters. | No | string |
| scope | formData | Label scope: 'public' or 'private'. Default is public | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Label was created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of users as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| key | query | Label key | Yes | string |
| value | query | Label value | Yes | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of users as paginated collection | [API_V2_Admin_Entities_User](#api_v2_admin_entities_user) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/users/labels/update

#### POST
##### Description

Update user label value

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | user uniq id | Yes | string |
| key | formData | Label key. | Yes | string |
| scope | formData | label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | Yes | string |
| value | formData | Label value. | Yes | string |
| description | formData | label description. [A-Za-z0-9_-] should be used. max - 255 characters. | No | string |
| replace | formData | When true label will be created if not exist | No | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Label was updated |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

### /api/v2/barong/admin/users/labels/list

#### GET
##### Description

Returns existing labels keys and values

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns existing labels keys and values |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/api_keys

#### GET
##### Description

List all api keys for selected account.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | query | user uniq id | Yes | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List all api keys for selected account. | [API_V2_Entities_APIKey](#api_v2_entities_apikey) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/permissions

#### PUT
##### Description

Update Permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | formData | Permission id | Yes | integer |
| role | formData | permission field - role | No | string |
| verb | formData | permission field - request verb | No | string |
| path | formData | permission field - request path | No | string |
| action | formData |  | No | string |
| topic | formData |  | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Permission was updated |
| 401 | Invalid bearer token |

#### DELETE
##### Description

Deletes permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | permission id | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Permission was deleted |
| 401 | Invalid bearer token |

#### POST
##### Description

Create permission

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| role | formData |  | Yes | string |
| verb | formData |  | Yes | string |
| path | formData |  | Yes | string |
| action | formData |  | Yes | string |
| topic | formData |  | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Permission was created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of permissions as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of permissions as paginated collection | [API_V2_Entities_Permission](#api_v2_entities_permission) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/activities/data

#### GET
##### Description

Returns array of Activities as paginated collection from Influxdb

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| topic | query |  | No | string |
| action | query |  | No | string |
| uid | query |  | No | string |
| email | query |  | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |
| target_uid | query |  | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of Activities as paginated collection from Influxdb |

### /api/v2/barong/admin/activities/admin

#### GET
##### Description

Returns array of activities as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| topic | query |  | No | string |
| action | query |  | No | string |
| uid | query |  | No | string |
| email | query |  | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |
| target_uid | query |  | No | string |
| range | query |  | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of activities as paginated collection | [API_V2_Admin_Entities_AdminActivity](#api_v2_admin_entities_adminactivity) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/activities

#### GET
##### Description

Returns array of activities as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| topic | query |  | No | string |
| action | query |  | No | string |
| uid | query |  | No | string |
| email | query |  | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of activities as paginated collection | [API_V2_Admin_Entities_ActivityWithUser](#api_v2_admin_entities_activitywithuser) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/metrics/statistic

#### GET
##### Description

Returns main statistic in the given time period

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns main statistic in the given time period |
| 401 | Invalid bearer token |

##### Security

| Security Schema | Scopes |
| --------------- | ------ |
| BearerToken |  |

### /api/v2/barong/admin/metrics/service-logs

#### GET
##### Description

Returns service logs in the given time period

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| period | query | Time period for calculating total service log count | No | string |
| country_code | query | Country code | No | string |
| from | query | Start date | No | dateTime |
| to | query | End date | No | dateTime |
| timezone | query | Timezone name | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns service logs in the given time period |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/metrics

#### GET
##### Description

Returns main statistic in the given time period

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| period | query | Time period for calculating total activity count | No | string |
| country_code | query | Country code | No | string |
| from | query | Start date | No | dateTime |
| to | query | End date | No | dateTime |
| timezone | query | Timezone name | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns main statistic in the given time period |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/restrictions

#### DELETE
##### Description

Delete restriction

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Restriction id | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Restriction was deleted |
| 401 | Invalid bearer token |

#### PUT
##### Description

Update restriction

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | formData | Restriction id | Yes | integer |
| scope | formData |  | No | string |
| category | formData |  | No | string |
| value | formData |  | No | string |
| state | formData |  | No | string |
| code | formData |  | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Restriction was updated |
| 401 | Invalid bearer token |

#### POST
##### Description

Create restriction

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| scope | formData |  | Yes | string |
| value | formData |  | Yes | string |
| category | formData |  | Yes | string |
| state | formData |  | No | string |
| code | formData |  | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Restriction was created |
| 401 | Invalid bearer token |

#### GET
##### Description

Returns array of restrictions as a paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| scope | query |  | No | string |
| category | query |  | No | string |
| range | query |  | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of restrictions as a paginated collection | [API_V2_Entities_Restriction](#api_v2_entities_restriction) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/restrictions/whitelink

#### POST
##### Description

Create whitelink

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| expire_time | formData | link will be active for (Time.now + expire_time in following range) | No | integer |
| range | formData | In combination with expire_time gives full controll over token expiration | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Created whitelink |
| 401 | Invalid bearer token |

### /api/v2/barong/admin/profiles

#### POST
##### Description

Create a profile for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData |  | Yes | string |
| first_name | formData |  | No | string |
| middle_name | formData |  | No | string |
| last_name | formData |  | No | string |
| dob | formData |  | No | date |
| address | formData |  | No | string |
| postcode | formData |  | No | string |
| city | formData |  | No | string |
| country | formData |  | No | string |
| metadata | formData | Any additional key: value pairs in json string format | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a profile for user | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### PUT
##### Description

Verify user's profile

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData |  | Yes | string |
| state | formData |  | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Verify user's profile | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### GET
##### Description

Return all profiles

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Return all profiles | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/levels

#### GET
##### Description

Returns array of permissions as paginated collection

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns array of permissions as paginated collection | [API_V2_Entities_Level](#api_v2_entities_level) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/abilities

#### GET
##### Description

Get all roles and admin_permissions of barong cancan.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get all roles and admin_permissions of barong cancan. |

### /api/v2/barong/admin/phone

#### POST
##### Description

Edit use Phone number by admin

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | Phone number with country code | Yes | string |
| uid | formData | User uid | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Edit use Phone number by admin | [API_V2_Entities_Phone](#api_v2_entities_phone) |
| 401 | Invalid bearer token |  |

### /api/v2/barong/admin/platform_settings/services

#### GET
##### Description

Get Services of Platform Setting

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get Services of Platform Setting |

### /api/v2/barong/admin/platform_settings

#### PUT
##### Description

Update Platform Settings

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | formData | Platform Setting Id | Yes | integer |
| state | formData | Setting State enabled or disabled | No | string |
| metadata | formData | Setting Description or Credentials | No | json |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update Platform Settings | [API_V2_Admin_Entities_PlatformSettings](#api_v2_admin_entities_platformsettings) |
| 400 | admin.platform_settings.required_parameters.empty |  |
| 401 | admin.platform_settings.invalid_token |  |
| 422 | admin.platform_settings.validation.error |  |

#### POST
##### Description

Create Platform Settings

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| service_name | formData | Service Name of platform. | Yes | string |
| service_type | formData | Setting type sms or email | Yes | string |
| service_key | formData | Service key of setting | Yes | string |
| state | formData | Setting State enabled or disabled | No | string |
| metadata | formData | Setting Description or Credentials | No | json |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create Platform Settings | [API_V2_Admin_Entities_PlatformSettings](#api_v2_admin_entities_platformsettings) |
| 400 | admin.platform_settings.required_parameters.empty |  |
| 401 | admin.platform_settings.invalid_token |  |
| 422 | admin.platform_settings.validation.error |  |

#### GET
##### Description

Get Platform Settings

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Platform Setting Id | No | integer |
| service_type | query | Setting type sms or email | No | string |
| service_name | query | Service used in the platform. | No | string |
| state | query | Setting State enabled or disabled | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get Platform Settings | [API_V2_Admin_Entities_PlatformSettings](#api_v2_admin_entities_platformsettings) |
| 401 | admin.platform_settings.invalid.token |  |

### /api/v2/barong/admin/service_logs/data

#### GET
##### Description

Returns array of service logs as paginated collection through influxdb

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | query | User UID. | No | string |
| email | query | User Email. | No | string |
| service_name | query | Service name used by user. | No | string |
| service_type | query | Service type used by user | No | string |
| result | query | Status of API response: succeed, failed, denied | No | string |
| user_country | query | User country | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of service logs as paginated collection through influxdb |

### /api/v2/barong/admin/service_logs

#### GET
##### Description

Returns array of service logs as paginated collection 

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | query | User UID. | No | string |
| email | query | User Email. | No | string |
| service_name | query | Service name used by user. | No | string |
| service_type | query | Service type used by user | No | string |
| phone_number | query | user phone number | No | string |
| result | query | Status of API response: succeed, failed, denied | No | string |
| country_code | query | User country code | No | string |
| user_country | query | User country | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns array of service logs as paginated collection  |

### /api/v2/barong/admin/country_services/continent

#### GET
##### Description

Get all the continents and it's countries

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| service_type | query | Service type email/sms | No | string |
| country_name | query | Country Name for Service | No | string |
| state | query | Service state is enabled/disabled | No | string |
| platform_setting_id | query | Platform Setting Selected for the Country | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get all the continents and it's countries |

### /api/v2/barong/admin/country_services

#### PUT
##### Description

Update Country Service

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | formData | Id of Country Service | Yes | integer |
| platform_setting_id | formData | Platform Setting Selected for the Country | Yes | integer |
| state | formData | Service state is enabled/disabled | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update Country Service | [API_V2_Admin_Entities_CountryServices](#api_v2_admin_entities_countryservices) |
| 400 | admin.country_services.required_parameters.empty |  |
| 401 | admin.country_services.invalid_token |  |
| 422 | admin.country_services.validation.error |  |

#### POST
##### Description

Create Country Service

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| service_type | formData | Service type sms/email | Yes | string |
| country_code | formData | Country Code of Service | Yes | string |
| platform_setting_id | formData | Platform Setting Selected for the Country | Yes | integer |
| state | formData | Service state is enabled/disabled | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create Country Service | [API_V2_Admin_Entities_CountryServices](#api_v2_admin_entities_countryservices) |
| 400 | admin.country_services.required_parameters.empty |  |
| 401 | admin.country_services.invalid_token |  |
| 422 | admin.country_services.validation.error |  |

#### GET
##### Description

Get Country Services

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Id of Country Service | No | integer |
| continent | query | Continent for Service | No | string |
| country_name | query | Country Name for Service | No | string |
| service_type | query | Service type email/sms | No | string |
| country_code | query | Country Code for Service | No | string |
| platform_setting_id | query | Platform Setting Selected for the Country | No | integer |
| state | query | Service state is enabled/disabled | No | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get Country Services | [API_V2_Admin_Entities_CountryServices](#api_v2_admin_entities_countryservices) |
| 401 | admin.country_services.invalid.token |  |

### /api/v2/barong/admin/sms_sender

#### DELETE
##### Description

Delete SMS Sender Config details

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Sms sender config Id | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Delete SMS Sender Config details |
| 400 | admin.sms_sender_config.required_parameters.empty |
| 401 | admin.sms_sender_config.invalid_token |
| 422 | admin.sms_sender_config.validation.error |

#### PUT
##### Description

Update SMS Sender Config details

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | formData | Sms sender config Id | Yes | integer |
| status | formData | Setting status enabled or disabled | No | string |
| metadata | formData | Setting Description or Credentials | No | json |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update SMS Sender Config details | [API_V2_Admin_Entities_SmsSenderConfig](#api_v2_admin_entities_smssenderconfig) |
| 400 | admin.sms_sender_config.required_parameters.empty |  |
| 401 | admin.sms_sender_config.invalid_token |  |
| 422 | admin.sms_sender_config.validation.error |  |

#### POST
##### Description

Create SMS Sender config

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| country_code | formData | Service Name of platform. | Yes | string |
| sender | formData | Setting type sms or email | Yes | string |
| platform_setting_id | formData | Platform setting id | Yes | string |
| status | formData | Setting status active or inactive | No | string |
| metadata | formData | Setting Description or Credentials | No | json |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create SMS Sender config | [API_V2_Admin_Entities_SmsSenderConfig](#api_v2_admin_entities_smssenderconfig) |
| 400 | admin.sms_sender_config.required_parameters.empty |  |
| 401 | admin.sms_sender_config.invalid_token |  |
| 422 | admin.sms_sender_config.validation.error |  |

#### GET
##### Description

Get sms sender config

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | SMS Sender config Id | No | integer |
| country_code | query | SMS Sender config country code | No | string |
| country | query | SMS Sender config used in the platform. | No | string |
| platform_setting_id | query | SMS Sender config used in the platform. | No | string |
| status | query | SMS Sender config is active or inactive | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get sms sender config | [API_V2_Admin_Entities_SmsSenderConfig](#api_v2_admin_entities_smssenderconfig) |
| 401 | admin.sms_sender_config.invalid.token |  |

### /api/v2/barong/admin/email-notifications

#### POST
##### Description

Update Email notification for a user.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | formData | Email Notification unique identifier. | Yes | string |
| enabled | formData | User email notification (true/false) | Yes | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Update Email notification for a user. |

#### GET
##### Description

Get all Email Notifications

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Email Notification unique identifier | No | integer |
| uid | query | UID of a user | No | string |
| email | query | Email of a user | No | string |
| email_type_id | query | Email type unique identifier | No | integer |
| enabled | query | User email notification (true/false) | No | boolean |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all Email Notifications | [API_V2_Admin_Entities_EmailNotifications](#api_v2_admin_entities_emailnotifications) |
| 401 | admin.email_notifications.invalid.token |  |

### /api/v2/barong/admin/email-types

#### PUT
##### Description

Update Email type

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | formData | Id of Email type | Yes | integer |
| description | formData | Description for email type | No | string |
| status | formData | State for email type (enabled/disabled) | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update Email type | [API_V2_Admin_Entities_EmailTypes](#api_v2_admin_entities_emailtypes) |
| 400 | admin.email_type.required_parameters.empty |  |
| 401 | admin.email_type.invalid_token |  |
| 422 | admin.email_type.validation.error |  |

#### POST
##### Description

Create Email type

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| name | formData | Name for email type. | Yes | string |
| description | formData | Description for email type | No | string |
| status | formData | State for email type (enabled/disabled) | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create Email type | [API_V2_Admin_Entities_EmailTypes](#api_v2_admin_entities_emailtypes) |
| 400 | admin.email_type.required_parameters.empty |  |
| 401 | admin.email_type.invalid_token |  |
| 422 | admin.email_type.validation.error |  |

#### GET
##### Description

Get all Email Types

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Email type unique identifier | No | integer |
| name | query | Email type name | No | string |
| status | query | Email type status (enabled/disabled) | No | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all Email Types | [API_V2_Admin_Entities_EmailTypes](#api_v2_admin_entities_emailtypes) |
| 401 | admin.email_type.invalid.token |  |

### /api/v2/barong/admin/devices

#### GET
##### Description

Get all Devices

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Device unique identifier | No | integer |
| uid | query | UID of a user | No | string |
| device_id | query | Device id | No | string |
| device_type | query | Device type | No | string |
| active | query | Device state | No | boolean |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all Devices | [API_V2_Admin_Entities_Device](#api_v2_admin_entities_device) |
| 401 | admin.device.invalid.token |  |

### /api/v2/barong/admin/notifications/recipients

#### GET
##### Description

Get all Notification recipients.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Notification unique identifier. | No | integer |
| uid | query | User's uid. | No | string |
| notification_id | query | Notification id. | No | string |
| status | query | Notification delivery status. | No | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all Notification recipients. | [API_V2_Admin_Entities_NotificationRecipient](#api_v2_admin_entities_notificationrecipient) |
| 401 | admin.notifications_recipients.invalid.token |  |

### /api/v2/barong/admin/notifications

#### GET
##### Description

Get all Notifications.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | query | Notification unique identifier | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all Notifications. | [API_V2_Admin_Entities_Notification](#api_v2_admin_entities_notification) |
| 401 | admin.notifications.invalid.token |  |

### /api/v2/barong/admin/notification/push

#### POST
##### Description

Push custom notification

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | user's uid | No | string |
| title | formData | Notification title | Yes | string |
| message | formData | Notification message. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Push custom notification |

---
### Models

#### API_V2_Admin_Entities_UserWithProfile

Returns user info

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| first_name | string | User first name | No |
| last_name | string | User last name | No |
| full_name | string | User full name | No |
| username | string | User's username | No |
| uid | string | User UID | No |
| role | string | User role | No |
| level | integer | User level | No |
| profile_url | object | Profile picture Url | No |
| profile_type | string | Profile picture type | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string | User state: active, pending, inactive | No |
| country | string | User country | No |
| last_country | string | Last IP Geolocation. | No |
| last_ip | string | Last IP Address. | No |
| phone_number | string | User Phone number | No |
| data | string | Additional phone and profile info | No |
| platform | string | Platform from which user signed up. | No |
| referral_code | string | User unique referral code. | No |
| login_via_password | string | User can login via password or not. | No |
| profiles | [API_V2_Admin_Entities_Profile](#api_v2_admin_entities_profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |
| referral_of | string | Referrer user UID | No |
| referrals | string | Referred user's referral count | No |
| social_media_status | string | User's social media status | No |

#### API_V2_Entities_Profile

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| first_name | string | First Name | No |
| middle_name | string | Submasked middle name | No |
| last_name | string | Submasked last name | No |
| dob | date | Submasked birth date | No |
| address | string | Address | No |
| postcode | string | Address Postcode | No |
| city | string | City name | No |
| country | string | Country name | No |
| state | string | Profile state: drafted, submitted, verified, rejected | No |
| metadata | object | Profile additional fields | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_Profile

Return all profiles

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| first_name | string | First Name | No |
| middle_name | string | Submasked middle name | No |
| last_name | string | Last name | No |
| dob | date | Birth date | No |
| address | string | Address | No |
| postcode | string | Address Postcode | No |
| city | string | City name | No |
| country | string | Country name | No |
| state | string | Profile state: drafted, submitted, verified, rejected | No |
| metadata | object | Profile additional fields | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_User

Returns array of users as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| first_name | string | User first name | No |
| last_name | string | User last name | No |
| full_name | string | User full name | No |
| username | string | User's username | No |
| uid | string | User UID | No |
| role | string | User role | No |
| level | integer | User level | No |
| profile_url | object | Profile picture Url | No |
| profile_type | string | Profile picture type | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string | User state: active, pending, inactive | No |
| country | string | User country | No |
| last_country | string | Last IP Geolocation. | No |
| last_ip | string | Last IP Address. | No |
| phone_number | string | User Phone number | No |
| agreement | string | User USA Disclaimer. | No |
| platform | string | Platform from which user signed up. | No |
| data | string | Additional phone and profile info | No |
| referral_code | string | User unique referral code. | No |
| login_via_password | string | User can login via password or not. | No |
| referrals | string | Referred user's referral count | No |
| password_reset_at | string | User last password reset timestamp. | No |
| created_at | string |  | No |
| updated_at | string |  | No |
| referral_of | string | Referrer user UID | No |
| social_media_status | string | User's social media status | No |

#### API_V2_Entities_APIKey

List all api keys for selected account.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| kid | string | JWT public key | No |
| algorithm | string | Cryptographic hash function type | No |
| scope | string | Serialized array of scopes | No |
| state | string | active/non-active state of key | No |
| secret | string | Api key secret | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Permission

Returns array of permissions as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Permission id | No |
| action | string | Permission action: accept (allow access (drop access), audit (record activity) | No |
| role | string | Permission user role | No |
| verb | string | Permission verb: put, post, delete, get | No |
| path | string | API path | No |
| topic | string | Permission topic: general, session etc | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_AdminActivity

Returns array of activities as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_ip | string | User IP | No |
| country | string | User country | No |
| country_code | string | User country code | No |
| user_agent | string | User Browser Agent | No |
| topic | string | Defined topic (session, adjustments) or general by default | No |
| action | string | API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method | No |
| result | string | Status of API response: succeed, failed, denied | No |
| data | string | Parameters which was sent to specific API endpoint | No |
| admin | [API_V2_Admin_Entities_User](#api_v2_admin_entities_user) |  | No |
| target | [API_V2_Admin_Entities_User](#api_v2_admin_entities_user) |  | No |
| created_at | string |  | No |

#### API_V2_Admin_Entities_ActivityWithUser

Returns array of activities as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_ip | string | User IP | No |
| country | string | User country | No |
| country_code | string | User country code | No |
| user_agent | string | User Browser Agent | No |
| topic | string | Defined topic (session, adjustments) or general by default | No |
| action | string | API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method | No |
| result | string | Status of API response: succeed, failed, denied | No |
| data | string | Parameters which was sent to specific API endpoint | No |
| user | [API_V2_Admin_Entities_User](#api_v2_admin_entities_user) |  | No |
| created_at | string |  | No |

#### API_V2_Entities_Restriction

Returns array of restrictions as a paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Restriction id | No |
| category | string | Restriction categories: blacklist, maintenance, whitelist, blocklogin | No |
| scope | string | Restriction scopes: continent, country, ip, ip_subnet, all | No |
| value | string | Restriction value: IP address, country abbreviation, all | No |
| code | integer | Restriction codes: {"continent"=>423, "country"=>423, "ip_subnet"=>403, "ip"=>401, "all"=>401} | No |
| state | string | Restriction states: disabled, enabled | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Level

Returns array of permissions as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Level identifier, level number | No |
| key | string | Label key. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |

#### API_V2_Entities_Phone

Edit use Phone number by admin

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string | Phone country | No |
| number | string | Submasked phone number | No |
| validated_at | s (g) | Phone validation date | No |

#### API_V2_Admin_Entities_PlatformSettings

Get Platform Settings

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Platform settings id | No |
| service_type | string | SMS service using in the platform. | No |
| service_name | string | Email service using in the platform. | No |
| service_key | string | SMS service using in the platform. | No |
| metadata | string | Other Related data or creds | No |
| state | string | Setting state is enabled/disabled | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_CountryServices

Get Country Services

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Country Service id | No |
| continent | string | Continent of Service | No |
| country_name | string | Country Name of Service | No |
| state | string | Service state is enabled/disabled | No |
| country_code | string | Country Code of Service | No |
| service_type | string | SMS service using in the Country. | No |
| platform_setting | [API_V2_Admin_Entities_PlatformSettings](#api_v2_admin_entities_platformsettings) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_SmsSenderConfig

Get sms sender config

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | SMS Sender config id | No |
| country_name | string | SMS Sender config country name. | No |
| country_code | string | SMS Sender config country code. | No |
| sender | string | SMS Sender config sender name. | No |
| status | string | SMS Sender config status is active/inactive | No |
| metadata | string | SMS Sender config metadata | No |
| platform_setting | [API_V2_Admin_Entities_PlatformSettings](#api_v2_admin_entities_platformsettings) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_EmailNotifications

Get all Email Notifications

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Email notification unique identifier | No |
| email | string | Email for which notification is enabled/disable. | No |
| uid | string | User UID. | No |
| name | string | Email type name. | No |
| description | string | Email type description | No |
| enabled | string | Email Notification status (true/false) | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_EmailTypes

Get all Email Types

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Email type unique identifier | No |
| name | string | Email type name. | No |
| description | string | Email type description | No |
| status | string | Email type status (true/false) | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_Device

Get all Devices

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Device unique identifier | No |
| uid | string | user's uid | No |
| email | string | user's email | No |
| phone_number | string | user's phone number | No |
| device_id | string | Device id | No |
| device_type | string | Device type | No |
| active | boolean | Device status | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_NotificationRecipient

Get all Notification recipients.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Notification unique identifier. | No |
| uid | string | User's uid. | No |
| phone_number | string | User's phone number. | No |
| device_id | string | Notification device id. | No |
| device_type | string | Notification device type. | No |
| notification | string | Notification details. | No |
| metadata | json | Notification recipient metadata | No |
| status | string | Notification delivery status. | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_Notification

Get all Notifications.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Notification unique identifier. | No |
| title | string | Notification title. | No |
| body | string | Notification body. | No |
| metadata | json | Notification metadata. | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Admin_Entities_ActivityWithInflux

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| user_email | string | Parameters which was sent to specific API endpoint | No |
| target_email | string | Parameters which was sent to specific API endpoint | No |
| target_uid | string | Parameters which was sent to specific API endpoint | No |
| user_ip | string | User IP | No |
| user_agent | string | User Browser Agent | No |
| topic | string | Defined topic (session, adjustments) or general by default | No |
| action | string | API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method | No |
| result | string | Status of API response: succeed, failed, denied | No |
| data | string | Parameters which was sent to specific API endpoint | No |
| created_at | string | created date of Activity  | No |

#### API_V2_Admin_Entities_Phone

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string | Phone country | No |
| number | string | Phone number | No |
| validated_at | s (g) | Phone validation date | No |

#### API_V2_Admin_Entities_ServiceLogs

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email. | No |
| uid | string | User UID. | No |
| service_name | string | Service name used by user. | No |
| service_type | string | Service type used by user | No |
| topic | string | Defined topic or general by default | No |
| result | string | Status of API response: succeed, failed, denied | No |
| phone_number | string | user phone number | No |
| metadata | json | Parameters which was sent to specific API endpoint | No |
| user_ip | string | User IP. | No |
| user_country | string | User country | No |
| country_code | string | User country code | No |
| created_at | string |  | No |
