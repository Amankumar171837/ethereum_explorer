# Barong
Management API for barong OAuth server

## Version: 2.7.0

### Security
**SecurityScope**  

| basic | *Basic* |
| ----- | ------- |
| Description | JWT should have signature keychains |
| Name | Authorization |

---
## api
Operations about apis

### /api/v2/barong/management/labels/delete

#### POST
##### Description

Delete a label with 'private' scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| user_uid | formData | User uid | Yes | string |
| key | formData | Label key. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Delete a label with 'private' scope |

### /api/v2/barong/management/labels

#### PUT
##### Description

Update a label with 'private' scope

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| user_uid | formData | User uid | Yes | string |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |
| description | formData | Label desc. | No | string |
| replace | formData | When true label will be created if not exist | No | boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a label with 'private' scope | [API_V2_Entities_Label](#api_v2_entities_label) |

#### POST
##### Description

Create a label with 'private' scope and assigns to users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| user_uid | formData | User uid | Yes | string |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |
| description | formData | Label desc. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a label with 'private' scope and assigns to users | [API_V2_Entities_Label](#api_v2_entities_label) |

### /api/v2/barong/management/labels/list

#### POST
##### Description

Get user collection filtered on label attributes

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| user_uid | formData | User uid | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get user collection filtered on label attributes | [API_V2_Entities_AdminLabelView](#api_v2_entities_adminlabelview) |

### /api/v2/barong/management/labels/filter/users

#### POST
##### Description

Get all labels assigned to users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | No | string |
| scope | formData | Label scope. | No | string |
| extended | formData | When true endpoint returns full information about users | No | boolean |
| range | formData |  | No | string |
| page | formData | Page number (defaults to 1). | No | integer |
| limit | formData | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get all labels assigned to users | [API_V2_Entities_User](#api_v2_entities_user) |

### /api/v2/barong/management/users/device-tokens

#### POST
##### Description

Getting device tokens for array of users

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uids | formData | User's uids | Yes | [ string ] |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Getting device tokens for array of users |

### /api/v2/barong/management/users/import

#### POST
##### Description

Imports an existing user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| email | formData | User Email | Yes | string |
| password_digest | formData | User Password Hash | Yes | string |
| referral_uid | formData | Referral uid | No | string |
| phone | formData | Phone | No | string |
| first_name | formData | First Name | No | string |
| last_name | formData | Last Name | No | string |
| dob | formData | Birth date | No | date |
| address | formData | Address | No | string |
| postcode | formData | Postcode | No | string |
| city | formData | City | No | string |
| country | formData | Country | No | string |
| state | formData | State | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Imports an existing user | [API_V2_Management_Entities_UserWithProfile](#api_v2_management_entities_userwithprofile) |

### /api/v2/barong/management/users/update

#### POST
##### Description

Updates role and data fields of existing user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | User Uid | Yes | string |
| role | formData | User Role | No | string |
| data | formData | Any additional key:value pairs in json format | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Updates role and data fields of existing user | [API_V2_Management_Entities_UserWithProfile](#api_v2_management_entities_userwithprofile) |

### /api/v2/barong/management/users

#### POST
##### Description

Creates new user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| email | formData | User Email | Yes | string |
| password | formData | User Password | Yes | string |
| referral_uid | formData | Referral uid | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new user | [API_V2_Management_Entities_UserWithProfile](#api_v2_management_entities_userwithprofile) |

### /api/v2/barong/management/users/list

#### POST
##### Description

Returns array of users as collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| extended | formData | When true endpoint returns full information about users | No | boolean |
| range | formData |  | No | string |
| from | formData | An integer represents the seconds elapsed since Unix epoch.If set, only records FROM the time will be retrieved. | No | dateTime |
| to | formData | An integer represents the seconds elapsed since Unix epoch.If set, only records BEFORE the time will be retrieved. | No | dateTime |
| page | formData | Page number (defaults to 1). | No | integer |
| limit | formData | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns array of users as collection | [API_V2_Entities_User](#api_v2_entities_user) |

### /api/v2/barong/management/users/get

#### POST
##### Description

Get users and profile information

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | User uid | No | string |
| email | formData | User email | No | string |
| phone_num | formData | User phone number | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get users and profile information | [API_V2_Management_Entities_UserWithKYC](#api_v2_management_entities_userwithkyc) |

### /api/v2/barong/management/profiles

#### POST
##### Description

Imports a profile for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | User Uid | Yes | string |
| first_name | formData | First Name | No | string |
| last_name | formData | Last Name | No | string |
| dob | formData | Birth date | No | date |
| address | formData | Address | No | string |
| postcode | formData | Postcode | No | string |
| city | formData | City | No | string |
| country | formData | Country | No | string |
| state | formData | State | No | string |
| metadata | formData | Metadata | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Imports a profile for user | [API_V2_Management_Entities_UserWithProfile](#api_v2_management_entities_userwithprofile) |

### /api/v2/barong/management/phones/delete

#### POST
##### Description

Delete phone number for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | User uid | Yes | string |
| number | formData | User phone number | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Delete phone number for user | [API_V2_Management_Entities_Phone](#api_v2_management_entities_phone) |

### /api/v2/barong/management/phones

#### POST
##### Description

Create phone number for user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | User uid | Yes | string |
| number | formData | User phone number | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create phone number for user | [API_V2_Management_Entities_Phone](#api_v2_management_entities_phone) |

### /api/v2/barong/management/phones/get

#### POST
##### Description

Get user phone numbers

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | User uid | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get user phone numbers | [API_V2_Management_Entities_Phone](#api_v2_management_entities_phone) |

### /api/v2/barong/management/otp/sign

#### POST
##### Description

Sign request with barong signature

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| user_uid | formData | Account UID | Yes | string |
| otp_code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Sign request with barong signature |

### /api/v2/barong/management/service_accounts/delete

#### POST
##### Description

Delete specific service_account

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | service_account uid | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Delete specific service_account | [API_V2_Entities_ServiceAccounts](#api_v2_entities_serviceaccounts) |

### /api/v2/barong/management/service_accounts/create

#### POST
##### Description

Create service_account

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| owner_uid | formData | owner uid | Yes | string |
| service_account_role | formData | service_account role | Yes | string |
| service_account_uid | formData | service_account uid | No | string |
| service_account_email | formData | service_account email | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create service_account | [API_V2_Entities_ServiceAccounts](#api_v2_entities_serviceaccounts) |

### /api/v2/barong/management/service_accounts/list

#### POST
##### Description

Get service_accounts as a paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| page | formData | Page number (defaults to 1). | No | integer |
| limit | formData | Number of users per page (defaults to 100, maximum is 100). | No | integer |
| owner_uid | formData | owner uid | No | string |
| owner_email | formData | owner email | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get service_accounts as a paginated collection | [API_V2_Entities_ServiceAccounts](#api_v2_entities_serviceaccounts) |

### /api/v2/barong/management/service_accounts/get

#### POST
##### Description

Get specific service_account information

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | service_account uid | No | string |
| email | formData | service_account email | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get specific service_account information | [API_V2_Entities_ServiceAccounts](#api_v2_entities_serviceaccounts) |

### /api/v2/barong/management/timestamp

#### POST
##### Description

Returns server time in seconds since Unix epoch.

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Returns server time in seconds since Unix epoch. |

---
### Models

#### API_V2_Entities_Label

Create a label with 'private' scope and assigns to users

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_AdminLabelView

Get user collection filtered on label attributes

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| description | string | Label desc: json string with any additional information | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_User

Returns array of users as collection

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
| country_of_residence | string | country of residence | No |
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
| agreement_time | string |  | No |

#### API_V2_Management_Entities_UserWithProfile

Imports a profile for user

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
| country_of_residence | string | country of residence | No |
| last_country | string | Last IP Geolocation. | No |
| last_ip | string | Last IP Address. | No |
| agreement | string | User USA Disclaimer. | No |
| phone_number | string | User Phone number | No |
| data | string | Additional phone and profile info | No |
| platform | string | Platform from which user signed up. | No |
| referral_code | string | User unique referral code. | No |
| login_via_password | string | User can login via password or not. | No |
| profiles | [API_V2_Management_Entities_Profile](#api_v2_management_entities_profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |
| agreement_time | string |  | No |

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

#### API_V2_Management_Entities_Profile

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

#### API_V2_Management_Entities_UserWithKYC

Get users and profile information

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
| country_of_residence | string | country of residence | No |
| last_country | string | Last IP Geolocation. | No |
| last_ip | string | Last IP Address. | No |
| agreement | string | User USA Disclaimer. | No |
| phone_number | string | User Phone number | No |
| data | string | Additional phone and profile info | No |
| referral_code | string | User unique referral code. | No |
| login_via_password | string | User can login via password or not. | No |
| referrals | string | Referred user's referral count | No |
| profiles | [API_V2_Management_Entities_Profile](#api_v2_management_entities_profile) |  | No |
| labels | [API_V2_Entities_AdminLabelView](#api_v2_entities_adminlabelview) |  | No |
| phones | [API_V2_Management_Entities_Phone](#api_v2_management_entities_phone) |  | No |
| data_storages | [API_V2_Entities_DataStorage](#api_v2_entities_datastorage) |  | No |
| comments | [API_V2_Entities_Comment](#api_v2_entities_comment) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |
| agreement_time | string |  | No |

#### API_V2_Management_Entities_Phone

Get user phone numbers

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string | Phone country | No |
| number | string | Phone Number | No |
| validated_at | s (g) | Phone validation date | No |

#### API_V2_Entities_DataStorage

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| title | string | Any additional data title | No |
| data | string | Any additional data json key:value pairs | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Comment

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Comment id | No |
| author_uid | string | Comment author UID | No |
| title | string | Comment title | No |
| data | string | Comment plain text | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_ServiceAccounts

Get specific service_account information

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| first_name | string | User first name | No |
| last_name | string | User last name | No |
| full_name | string | User full name | No |
| username | string | User's username | No |
| uid | string | User UID | No |
| role | string | Service Account Role | No |
| level | integer | User Level | No |
| state | string | Service Account State: active, disabled | No |
| user | [API_V2_Entities_User](#api_v2_entities_user) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_APIKey

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| kid | string | JWT public key | No |
| algorithm | string | Cryptographic hash function type | No |
| scope | string | Serialized array of scopes | No |
| state | string | active/non-active state of key | No |
| secret | string | Api key secret | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_UserWithFullInfo

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User Email | No |
| first_name | string | User first name | No |
| last_name | string | User last name | No |
| full_name | string | User full name | No |
| username | string | User's username | No |
| uid | string | User UID | No |
| dob | string | User date of birth. | No |
| role | string | User role | No |
| level | integer | User level | No |
| otp | boolean | is 2FA enabled for account | No |
| profile_url | object | Profile picture Url | No |
| profile_type | string | Profile picture type | No |
| state | string | User state: active, pending, inactive | No |
| country | string | User country | No |
| country_of_residence | string | country of residence | No |
| last_country | string | Last IP Geolocation. | No |
| last_ip | string | Last IP Address. | No |
| phone_number | string | User Phone number | No |
| data | string | Additional phone and profile info | No |
| csrf_token | string | Сsrf protection token | No |
| authentication | string | Сsrf protection token | No |
| agreement | string | User USA Disclaimer. | No |
| referral_code | string | User unique referral code. | No |
| login_via_password | string | User can login via password or not. | No |
| labels | [API_V2_Entities_Label](#api_v2_entities_label) |  | No |
| phones | [API_V2_Entities_Phone](#api_v2_entities_phone) |  | No |
| profiles | [API_V2_Entities_Profile](#api_v2_entities_profile) |  | No |
| data_storages | [API_V2_Entities_DataStorage](#api_v2_entities_datastorage) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |
| agreement_time | string |  | No |

#### API_V2_Entities_Phone

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string | Phone country | No |
| number | string | Submasked phone number | No |
| validated_at | s (g) | Phone validation date | No |
