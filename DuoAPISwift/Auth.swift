//
//  Auth.swift
//  DuoAPISwift
//
//  Created by James Barclay on 7/27/16.
//  Copyright © 2016 Duo Security. All rights reserved.
//
//  Duo Security Auth API reference client implementation.
//
//  http://www.duosecurity.com/docs/authapi

public class Auth: Client {
    /*
        Determine if the Duo service is up and responding.
     
        Returns information about the Duo service state: {
            'time': <int:UNIX timestamp>,
        }
     */
    public func ping(completion: AnyObject -> ()) {
        self.duoJSONAPICall("GET",
                            path: "/auth/v2/ping",
                            params: [:],
                            completion: { response in
                                completion(response)
            }
        )
    }
    
    /*
        Determine if the integration key, secret key, and signature
        generation are valid.
    
        Returns information about the Duo service state: {
            'time': <int:UNIX timestamp>,
        }
     */
    public func check(completion: AnyObject -> ()) {
        self.duoJSONAPICall("GET",
                            path: "/auth/v2/check",
                            params: [:],
                            completion: { response in
                                completion(response)
            }
        )
    }
    
    /*
        Retrieve the user-supplied logo.
     */
    public func logo(completion: AnyObject -> ()) {
        self.duoAPICall("GET",
                        path: "/auth/v2/logo",
                        params: [:],
                        completion: {
                            (let data, let httpResponse) in

                            if let contentType = httpResponse?.allHeaderFields["Content-Type"] as? String {
                                if contentType.hasPrefix("image/") {
                                    completion(data)
                                } else {
                                    completion(self.parseJSONResponse(data))
                                }
                            } else {
                                completion(self.parseJSONResponse(data))
                            }
            }
        )
    }
    
    /*
        Create a new user and associated numberless phone.
     
        Returns activation information: {
            'activation_barcode': <str:url>,
            'activation_code': <str:actcode>,
            'bypass_codes': <list[str:autogenerated]:optional>,
            'user_id': <str:autogenerated>,
            'username': <str:provided or autogenerated>,
            'valid_secs': <int:seconds>,
        }
     */
    public func enroll(username: String = "",
                       validSeconds: Int = 0,
                       bypassCodes: Int = 0,
                       completion: AnyObject -> ()) {
        var params: Dictionary<String, String> = [:]
        if username != "" {
            params["username"] = username
        }
        if validSeconds != 0 {
            params["valid_secs"] = String(validSeconds)
        }
        if bypassCodes != 0 {
            params["bypass_codes"] = String(bypassCodes)
        }
        self.duoJSONAPICall("POST",
                            path: "/auth/v2/enroll",
                            params: params,
                            completion: { response in
                                completion(response)
            }
        )
    }
    
    /*
        Check if a user has been enrolled yet.
     
        Returns a string constant indicating whether the user has been
        enrolled or the code remains unclaimed.
     */
    public func enrollStatus(userID: String = "",
                             activationCode: String = "",
                             completion: AnyObject -> ()) {
        let params = [
            "user_id": userID,
            "activation_code": activationCode
        ]
        self.duoJSONAPICall("POST",
                            path: "/auth/v2/enroll_status",
                            params: params,
                            completion: { response in
                                completion(response)
            }
        )
    }
    
    /*
        Determine if and with what factors a user may authenticate or enroll.
     
        See the adminapi docs for parameter and response information.
     */
    public func preAuth(username: String = "",
                     userID: String = "",
                     ipAddress: String = "",
                     trustedDeviceToken: String = "",
                     completion: AnyObject -> ()) {
        var params: Dictionary<String, String> = [:]
        if username != "" {
            params["username"] = username
        }
        if userID != "" {
            params["user_id"] = userID
        }
        if ipAddress != "" {
            params["ipaddr"] = ipAddress
        }
        if trustedDeviceToken != "" {
            params["trusted_device_token"] = trustedDeviceToken
        }
        self.duoJSONAPICall("POST",
                            path: "/auth/v2/preauth",
                            params: params,
                            completion: { response in
                                completion(response)
            }
        )
    }
    
    /*
        Perform second-factor authentication for a user.
     
        If async is True, returns: {
            'txid': <str: transaction ID for use with auth_status>,
        }
     
        Otherwise, returns: {
            'result': <str:allow|deny>,
            'status': <str:machine-parsable>,
            'status_msg': <str:human-readable>,
        }
     
        If Trusted Devices is enabled, async is not true, and status is
        'allow', another item is returned:
     
        * trusted_device_token: <str: device token for use with preauth>
     */
    public func auth(factor: String,
                     username: String = "",
                     userID: String = "",
                     ipAddress: String = "",
                     asynchronous: Bool = false,
                     type: String = "",
                     displayUsername: String = "",
                     pushInfo: String = "",
                     device: String = "",
                     passcode: String = "",
                     completion: AnyObject -> ()) {
        var params = [
            "factor": factor,
            "async": String(Int(asynchronous))
        ]
        if username != "" {
            params["username"] = username
        }
        if userID != "" {
            params["user_id"] = userID
        }
        if ipAddress != "" {
            params["ipaddr"] = ipAddress
        }
        if type != "" {
            params["type"] = type
        }
        if displayUsername != "" {
            params["display_username"] = displayUsername
        }
        if pushInfo != "" {
            params["pushinfo"] = pushInfo
        }
        if device != "" {
            params["device"] = device
        }
        if passcode != "" {
            params["passcode"] = passcode
        }
        self.duoJSONAPICall("POST",
                            path: "/auth/v2/auth",
                            params: params,
                            completion: { response in
                                completion(response)
            }
        )
    }

    /*
        Longpoll for the status of an asynchronous authentication call.

        Returns a dict with four items:

        * waiting: True if the authentication attempt is still in progress
        and the caller can continue to poll, else False.

        * success: True if the authentication request has completed and
        was a success, else False.

        * status: String constant identifying the request's state.

        * status_msg: Human-readable string describing the request state.

        If Trusted Devices is enabled, another item is returned when success
        is True:

        * trusted_device_token: String token to bypass second-factor
          authentication for this user during an admin-defined period.
     */
    public func authStatus(txid: String, completion: AnyObject -> ()) {
        let params = [
            "txid": txid,
        ]
        self.duoJSONAPICall("GET",
                            path: "/auth/v2/auth_status",
                            params: params,
                            completion: { response in
                                completion(response)
            }
        )
    }
}