# Exchange auth
RESTful API for Exchange auth OAuth server

## Version: 2.7.0

---
## identity
Operations about identities

### /identity/generate_token

#### POST
##### Description

Generate API token for secure transaction

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generate API token for secure transaction |

### /identity/users/referral/exists

#### GET
##### Description

Check user existence through referral code.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| referral_code | query | User's referral code | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Check user existence through referral code. |

### /identity/users/exists

#### GET
##### Description

Check user existence through email.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| email | query | User Email | Yes | string |
| platform | query | User Signup platform | No | string |
| device_id | query | User device id | Yes | string |
| device_type | query | User device type Android/IOS | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Check user existence through email. |

### /identity/users/password/reset

#### POST
##### Description

Set new account password through phone number

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | User Phone Number | No | string |
| email | formData | User email | No | string |
| password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |
| verification_otp | formData | Verification code from email | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Reset password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /identity/users/password/send-otp

#### POST
##### Description

Reset account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | User Phone Number | No | string |
| email | formData | User email | No | string |
| channel | formData | The verification method to use | No | string |
| captcha_response | formData | Response from captcha widget | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Code was sent successfully via sms/call. |
| 400 | Required params are missing |
| 422 | Validation errors |

### /identity/users/password/confirm_code

#### POST
##### Description

Sets new account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| reset_password_token | formData | Token from email | Yes | string |
| password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Resets password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /identity/users/password/generate_code

#### POST
##### Description

Send password reset instructions

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| identity | formData | User's email or username | Yes | string |
| captcha_response | formData | Response from captcha widget | No | string |
| platform | formData | User login platform | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generated password reset code |
| 400 | Required params are missing |
| 404 | User doesn't exist |
| 422 | Validation errors |

### /identity/users/email/confirm_code

#### POST
##### Description

Confirms an account

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| token | formData | Token from email | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Confirms an account | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /identity/users/email/generate_code

#### POST
##### Description

Send confirmations instructions

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| email | formData | Account email | Yes | string |
| captcha_response | formData | Response from captcha widget | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Generated verification code |
| 400 | Required params are missing |
| 422 | Validation errors |

### /identity/users/username/referral

#### GET
##### Description

Check referral code through username

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| username | query | User's Username | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Check referral code through username |

### /identity/users/username/available

#### GET
##### Description

Check if user is available with the username

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| username | query | User's Username | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Check if user is available with the username |

### /identity/users/register_geetest

#### GET
##### Description

Register Geetest captcha

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Register Geetest captcha |

### /identity/users/new

#### POST
##### Description

Creates new user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | User Phone Number | No | string |
| email | formData | User Email | No | string |
| first_name | formData | User's first name | No | string |
| last_name | formData | User's last name | No | string |
| username | formData | User's username | No | string |
| dob | formData | User's username | No | string |
| referral_code | formData | User's referral code | No | string |
| captcha_response | formData | Response from captcha widget | No | string |
| channel | formData | The verification method to use | No | string |
| platform | formData | User Signup platform | No | string |
| device_id | formData | User device id | No | string |
| device_type | formData | User device type Android/IOS | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new user | [API_V2_Entities_UserWithPhone](#api_v2_entities_userwithphone) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /identity/sessions/refresh

#### DELETE
##### Description

Destroy current session with jwt refresh token

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| device_id | query | User device id | No | string |
| device_type | query | User device type Android/IOS | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Session was destroyed |
| 400 | Required params are empty |
| 404 | Record is not found |

#### POST
##### Description

Refresh user's jwt session token

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| refresh_token | formData | JWT Refresh token | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User's JWT token refreshed successfully. |
| 400 | Required params are empty |
| 404 | Record is not found |

### /identity/sessions/verify

#### POST
##### Description

Verify user otp and generate jwt session

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | Phone number with country code | No | string |
| email | formData | Registered email address | No | string |
| username | formData | User's username | No | string |
| verification_code | formData | Verification code from sms | Yes | string |
| platform | formData | User login platform | Yes | string |
| login_device[device_id] | formData | User device id | Yes | string |
| login_device[device_type] | formData | User device type Android/IOS | Yes | string |
| login_device[device_token] | formData | User fcm device token Android/IOS | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User authorization |
| 400 | Required params are empty |
| 404 | Record is not found |

### /identity/sessions/verify_user

#### POST
##### Description

Resent OTP for the registered phone number

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| platform | formData | User login platform | No | string |
| phone_number | formData | User phone number | No | string |
| email | formData | User phone number | No | string |
| username | formData | User's username | No | string |
| channel | formData | The verification method to use | No | string |
| reactive_account | formData | Send this true if user's social login is disabled | No | boolean |
| captcha_response | formData | Response from captcha widget | No | string |
| device_id | formData | User device id | No | string |
| device_type | formData | User device type Android/IOS | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User authenticated |
| 400 | Required params are empty |
| 404 | Record is not found |

### /identity/sessions

#### DELETE
##### Description

Destroy current session

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Session was destroyed |
| 400 | Required params are empty |
| 404 | Record is not found |

#### POST
##### Description

Start a new session

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| identity | formData | User's email or username | Yes | string |
| password | formData | User's password | No | string |
| captcha_response | formData | Response from captcha widget | No | string |
| otp_code | formData | Code from Google Authenticator | No | string |
| reactive_account | formData | Send this true if user's social login is disabled | No | boolean |
| login_device[device_id] | formData | User device id | Yes | string |
| login_device[device_type] | formData | User device type Android/IOS | Yes | string |
| login_device[device_token] | formData | User fcm device token Android/IOS | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Start a new session |
| 400 | Required params are empty |
| 404 | Record is not found |

### /identity/sessions/new

#### POST
##### Description

Start a new session

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| identity | formData | User's email or username or phone number | Yes | string |
| password | formData | User's password | No | string |
| captcha_response | formData | Response from captcha widget | No | string |
| otp_code | formData | Code from Google Authenticator | No | string |
| channel | formData | The verification method to use | No | string |
| platform | formData | User login platform | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Start a new session |
| 400 | Required params are empty |
| 404 | Record is not found |

### /identity/ping

#### GET
##### Description

Test connectivity

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Test connectivity |

### /identity/phone_number/validate

#### POST
##### Description

Phone number validation

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | User phone number | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Phone number validation |

### /identity/password/validate

#### POST
##### Description

Password strength testing

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Password strength testing |

---
## public
Operations about publics

### /public/users/metrics

#### GET
##### Description

Get all the continents and it's countries

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| continent | query | continent. | No | string |
| country_code | query | Country code. | No | string |
| city | query | city . | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get all the continents and it's countries |

### /public/mobivate

#### POST
##### Description

webhook for mobivate

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | webhook for mobivate |

### /public/ding

#### POST
##### Description

webhook for ding

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | webhook for ding |

### /public/smsala

#### POST
##### Description

webhook for smsala

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | webhook for smsala |

### /public/bulkgate

#### GET
##### Description

webhook for bulkgate

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | webhook for bulkgate |

### /public/users/referrals

#### GET
##### Description

get user's referrals with username

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| username | query | User's username | Yes | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | get user's referrals with username | [API_V2_Entities_UserPublic](#api_v2_entities_userpublic) |

### /public/app/versions

#### GET
##### Description

Get application version.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get application version. |

### /public/graph/data

#### GET
##### Description

Graph

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| period | query | Time period for calculating total sold coin | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Graph |

### /public/time

#### GET
##### Description

Get server current unix timestamp.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get server current unix timestamp. |

### /public/ping

#### GET
##### Description

Test connectivity

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Test connectivity |

### /public/password/validate

#### POST
##### Description

Password strength testing

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Password strength testing |

---
## resource
Operations about resources

### /resource/swagger_doc/{name}

#### GET
##### Description

Swagger compatible API description for specific API

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| name | path | Resource name of mounted API | Yes | string |
| locale | query | Locale of API documentation | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Swagger compatible API description for specific API |

### /resource/swagger_doc

#### GET
##### Description

Swagger compatible API description

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Swagger compatible API description |

### /resource/device/connect

#### POST
##### Description

Generate tokens for the device.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| uid | formData | Current user uid. | Yes | string |
| device_id | formData | X10 Device id | Yes | string |
| device_type | formData | Device type | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | User authorization |
| 400 | Required params are empty |
| 404 | Record is not found |

### /resource/email/notifications

#### POST
##### Description

Update Email notification for a user.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| email_type | formData | Email type name. | Yes | string |
| enabled | formData | Email Notification flag. | Yes | boolean |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Update Email notification for a user. |

#### GET
##### Description

Get all Email Types

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get all Email Types |

### /resource/user/delete-account

#### DELETE
##### Description

Delete user account.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| verification_code | query | Verification code from email | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Delete user account. |

### /resource/user/send-otp

#### POST
##### Description

Send OTP for the registered email

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Send OTP for the registered email |

### /resource/user/phone_number/verify

#### POST
##### Description

verify phone number with OTP

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | User Email | Yes | string |
| verification_code | formData | User Email OTP | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | verify phone number with OTP | [API_V2_Entities_UserWithPhone](#api_v2_entities_userwithphone) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /resource/user/phone_number

#### POST
##### Description

update phone number

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | User Phone Number | Yes | string |
| channel | formData | The verification method to use | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | update phone number | [API_V2_Entities_UserWithPhone](#api_v2_entities_userwithphone) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /resource/user/email/verify

#### POST
##### Description

verify email address with OTP

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| email | formData | User Email | Yes | string |
| verification_code | formData | User Email OTP | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | verify email address with OTP | [API_V2_Entities_UserWithPhone](#api_v2_entities_userwithphone) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /resource/user/email

#### POST
##### Description

update email address

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| email | formData | User Email | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | update email address | [API_V2_Entities_UserWithPhone](#api_v2_entities_userwithphone) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /resource/otp/verify

#### POST
##### Description

Verify 2FA code

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | 2FA was verified |
| 400 | 2FA has not been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /resource/otp/disable

#### POST
##### Description

Disable 2FA

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | 2FA was disabled |
| 400 | 2FA has not been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /resource/otp/enable

#### POST
##### Description

Enable 2FA

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| code | formData | Code from Google Authenticator | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | 2FA was enabled |
| 400 | 2FA has been enabled for this account or code is missing |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /resource/otp/generate_qrcode

#### POST
##### Description

Generate qr code for 2FA

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | QR code was generated |
| 400 | 2FA has been enabled for this account |
| 401 | Invalid bearer token |

### /resource/phones/verify

#### POST
##### Description

Verify a phone

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | Phone number with country code | Yes | string |
| verification_code | formData | Verification code from sms | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Verify a phone | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |

### /resource/phones/send_code

#### POST
##### Description

Resend activation code

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | Phone number with country code | Yes | string |
| channel | formData | The verification method to use | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Activation code was resend |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

### /resource/phones

#### POST
##### Description

Add new phone

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| phone_number | formData | Phone number with country code | Yes | string |
| channel | formData | The verification method to use | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | New phone was added |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |
| 422 | Validation errors |

#### GET
##### Description

Returns list of user's phones

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns list of user's phones | [API_V2_Entities_Phone](#api_v2_entities_phone) |
| 401 | Invalid bearer token |  |

### /resource/profiles

#### PUT
##### Description

Update a profile for current_user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| first_name | formData | First Name | No | string |
| middle_name | formData | Middle Name | No | string |
| last_name | formData | Last Name | No | string |
| dob | formData | Date of Birth | No | date |
| address | formData | Address | No | string |
| postcode | formData | Postcode | No | string |
| city | formData | City | No | string |
| country | formData | Country | No | string |
| metadata | formData | Any additional key: value pairs in json string format | No | string |
| confirm | formData | Profile confirmation | No | boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a profile for current_user | [API_V2_Entities_Profile](#api_v2_entities_profile) |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### POST
##### Description

Create a profile for current_user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| first_name | formData | First Name | No | string |
| middle_name | formData | Middle Name | No | string |
| last_name | formData | Last Name | No | string |
| dob | formData | Date of Birth | No | date |
| address | formData | Address | No | string |
| postcode | formData | Postcode | No | string |
| city | formData | City | No | string |
| country | formData | Country | No | string |
| metadata | formData | Any additional key: value pairs in json string format | No | string |
| confirm | formData | Profile confirmation | No | boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a profile for current_user | [API_V2_Entities_Profile](#api_v2_entities_profile) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 409 | Profile already exists |  |
| 422 | Validation errors |  |

### /resource/profiles/me

#### GET
##### Description

Return profiles of current resource owner

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Return profiles of current resource owner | [API_V2_Entities_Profile](#api_v2_entities_profile) |
| 401 | Invalid bearer token |  |
| 404 | User has no profile |  |

### /resource/labels/{key}

#### DELETE
##### Description

Delete a label  with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| key | path | Label key. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Succefully deleted |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Record is not found |

#### PATCH
##### Description

Update a label with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| key | path | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update a label with 'public' scope. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |
| 422 | Validation errors |  |

#### GET
##### Description

Return a label by key.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| key | path | Label key. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Return a label by key. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 404 | Record is not found |  |

### /resource/labels

#### POST
##### Description

Create a label with 'public' scope.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| key | formData | Label key. | Yes | string |
| value | formData | Label value. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a label with 'public' scope. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 400 | Required params are empty |  |
| 401 | Invalid bearer token |  |
| 422 | Validation errors |  |

#### GET
##### Description

List all labels for current user.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| ordering | query | If set, returned labels sorted in specific order, default to "asc". | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List all labels for current user. | [API_V2_Entities_Label](#api_v2_entities_label) |
| 401 | Invalid bearer token |  |

### /resource/users/devices

#### POST
##### Description

Update user device

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| device_id | formData | User device id | Yes | string |
| device_type | formData | User device type Android/IOS | Yes | string |
| device_token | formData | User fcm device token Android/IOS | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Update user device |

### /resource/users/update_status

#### POST
##### Description

Update member status.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| status | formData | member status | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Update member status. |

### /resource/users/update_media

#### PUT
##### Description

Update profile picture for current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| media_id | formData | Unique ID of media. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Profile picture is uploaded |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /resource/users/remove_media

#### DELETE
##### Description

Remove profile picture for current user

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Profile picture is removed |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /resource/users/media

#### POST
##### Description

Upload a new profile picture for current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| upload | formData | Array of Rack::Multipart::UploadedFile | Yes | string |
| x | formData | x-axis of the image | No | string |
| y | formData | y-axis of the image | No | string |
| h | formData | Height of the image | No | string |
| w | formData | Width of the image | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Profile picture is uploaded |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

### /resource/users/update

#### POST
##### Description

update user's details

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| first_name | formData | User's first name | No | string |
| last_name | formData | User's last name | No | string |
| username | formData | User's username | No | string |
| dob | formData | User's date of Birth | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | update user's details | [API_V2_Entities_UserWithPhone](#api_v2_entities_userwithphone) |
| 400 | Required params are missing |  |
| 422 | Validation errors |  |

### /resource/users/user_activity

#### GET
##### Description

Api for first login Activity

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| search | query | activity of user | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Confirms an account |
| 400 | Required params are missing |
| 422 | Validation errors |

### /resource/users/set-password

#### POST
##### Description

Sets new account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | set password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /resource/users/password

#### PUT
##### Description

Sets new account password

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| old_password | formData | Previous account password | Yes | string |
| new_password | formData | User password | Yes | string |
| confirm_password | formData | User password | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Changes password |
| 400 | Required params are empty |
| 404 | Record is not found |
| 422 | Validation errors |

### /resource/users/activity/{topic}

#### GET
##### Description

Returns user activity

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| topic | path | Topic of user activity. Allowed: [all, password, session, otp] | Yes | string |
| time_from | query | An integer represents the seconds elapsed since Unix epoch.If set, only activities created after the time will be returned. | No | dateTime |
| time_to | query | An integer represents the seconds elapsed since Unix epoch.If set, only activities created before the time will be returned. | No | dateTime |
| result | query | Result of user activity. Allowed: [succeed, failed, denied] | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of users per page (defaults to 100, maximum is 100). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns user activity | [API_V2_Entities_Activity](#api_v2_entities_activity) |

### /resource/users/me

#### DELETE
##### Description

Blocks current user

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| password | query | Account password | Yes | string |
| otp_code | query | Code from Google Authenticator | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Current user was blocked |

#### GET
##### Description

Returns current user

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns current user | [API_V2_Entities_UserWithFullInfo](#api_v2_entities_userwithfullinfo) |

### /resource/users/info

#### GET
##### Description

Returns current user

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns current user | [API_V2_Entities_UserWithPhone](#api_v2_entities_userwithphone) |

---
### Models

#### API_V2_Entities_UserWithFullInfo

Returns current user

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
| last_country | string | Last IP Geolocation. | No |
| last_ip | string | Last IP Address. | No |
| phone_number | string | User Phone number | No |
| data | string | Additional phone and profile info | No |
| csrf_token | string | Сsrf protection token | No |
| authentication | string | Сsrf protection token | No |
| referral_code | string | User unique referral code. | No |
| login_via_password | string | User can login via password or not. | No |
| labels | [API_V2_Entities_Label](#api_v2_entities_label) |  | No |
| phones | [API_V2_Entities_Phone](#api_v2_entities_phone) |  | No |
| profiles | [API_V2_Entities_Profile](#api_v2_entities_profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Label

List all labels for current user.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_Phone

Returns list of user's phones

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| country | string | Phone country | No |
| number | string | Submasked phone number | No |
| validated_at | s (g) | Phone validation date | No |

#### API_V2_Entities_Profile

Return profiles of current resource owner

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

#### API_V2_Entities_UserWithPhone

Returns current user

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| email | string | User's Email | No |
| first_name | string | User's First Name | No |
| last_name | string | User's Last Name | No |
| full_name | string | User full name | No |
| username | string | User's username | No |
| phone_number | string | User's phone number | No |
| csrf_token | string | Сsrf protection token | No |
| uid | string | User's UID | No |
| role | string | User's role | No |
| level | integer | User's level | No |
| profile_url | object | Profile picture Url | No |
| profile_type | string | Profile picture type | No |
| otp | boolean | is 2FA enabled for account | No |
| state | string | User's state: active, pending, inactive | No |
| country | string | User country | No |
| last_country | string | Last IP Geolocation. | No |
| last_ip | string | Last IP Address. | No |
| referral_code | string | User unique referral code. | No |
| login_via_password | string | User can login via password or not. | No |
| labels | [API_V2_Entities_Label](#api_v2_entities_label) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_UserPublic

get user's referrals with username

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| full_name | string | User full name | No |
| username | string | User's username | No |
| profile_url | object | Profile picture Url | No |
| profile_type | string | Profile picture type | No |
| initial | string | Username initial | No |

#### API_V2_Entities_Activity

Returns user activity

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Activity ID | No |
| user_ip | string | User IP | No |
| user_agent | string | User Browser Agent | No |
| topic | string | Defined topic (session, adjustments) or general by default | No |
| action | string | API action: POST => 'create', PUT => 'update', GET => 'read', DELETE => 'delete', PATCH => 'update' or system if there is no match of HTTP method | No |
| result | string | Status of API response: succeed, failed, denied | No |
| data | string | Parameters which was sent to specific API endpoint | No |
| created_at | string |  | No |

#### API_V2_Entities_Level

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Level identifier, level number | No |
| key | string | Label key. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |

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

#### API_V2_Entities_User

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

#### API_V2_Entities_UserWithProfile

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
| profiles | [API_V2_Entities_Profile](#api_v2_entities_profile) |  | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_ServiceAccounts

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

#### API_V2_Entities_AdminLabelView

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| key | string | Label key. [a-z0-9_-]+ should be used. Min - 3, max - 255 characters. | No |
| value | string | Label value. [A-Za-z0-9_-] should be used. Min - 3, max - 255 characters. | No |
| scope | string | Label scope: 'public' or 'private' | No |
| description | string | Label desc: json string with any additional information | No |
| created_at | string |  | No |
| updated_at | string |  | No |

#### API_V2_Entities_ReferralCode

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| referral_code | string | referral code of user | No |
| username | string | User's username | No |
