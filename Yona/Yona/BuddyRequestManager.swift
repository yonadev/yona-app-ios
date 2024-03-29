//
//  BuddyRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class BuddyRequestManager {
    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance
    static let sharedInstance = BuddyRequestManager()
    var buddy: Buddies?
    var buddies: [Buddies] = []
    fileprivate init() {}

    
    fileprivate func genericBuddyRequest(_ httpMethod: httpMethods, buddyBody: BodyDataDictionary?, buddy: Buddies?, onCompletion: @escaping APIBuddiesResponse) {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed){ (success, serverMessage, serverCode, user) in
            switch httpMethod {
            case .get:
                if let buddieLink = user?.buddiesLink {
                    ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, message, serverCode, activities, error) in
                        if success {
                            self.APIService.callRequestWithAPIServiceResponse(nil, path: buddieLink, httpMethod: httpMethod) { (success, json, error) in
                                if success {
                                    self.buddies.removeAll()
                                    if let json = json {
                                        if let embedded = json[postBuddyBodyKeys.embedded.rawValue],
                                            let yonaBuddies = embedded[postBuddyBodyKeys.yonaBuddies.rawValue] as? NSArray{
                                            //iterate messages
                                            for buddy in yonaBuddies {
                                                if let buddy = buddy as? BodyDataDictionary {
                                                    if let allActivities = activities {
                                                        self.buddy = Buddies.init(buddyData: buddy, allActivity: allActivities)
                                                    } else {
                                                        self.buddy = Buddies.init(buddyData: buddy, allActivity: [])
                                                    }
                                                    
                                                    if let buddy = self.buddy {
                                                        if buddy.UserRequestmobileNumber.count > 0 {
                                                            self.buddies.append(buddy)
                                                        }
                                                    }
                                                }
                                            }
                                            onCompletion(success, serverMessage, serverCode, nil, self.buddies)
                                        } else { //we just get a buddy response back
                                            self.buddy = Buddies.init(buddyData: json, allActivity: activities!)
                                            onCompletion(success, serverMessage, serverCode, self.buddy, nil)
                                        }
                                    } else {
                                        onCompletion(success, serverMessage, serverCode, nil, nil) //failed json response
                                    }
                                } else {
                                    onCompletion(success, serverMessage, serverCode, nil, nil)
                                }
                            }
                        }
                    }
                        
                } else {
                    onCompletion(false, YonaConstants.YonaErrorTypes.GetBuddyLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetBuddyLinkFail), nil, nil)
                }
                break
            case .post:
                if let buddieLink = user?.buddiesLink {
                    self.APIService.callRequestWithAPIServiceResponse(buddyBody, path: buddieLink, httpMethod: httpMethod) { (success, json, error) in
                        if success {
                            if let json = json {
                                self.buddy = Buddies.init(buddyData: json, allActivity: [])
                                onCompletion(success, serverMessage, serverCode, self.buddy, nil) //failed to get user
                            } else {
                                onCompletion(success, serverMessage, serverCode, nil, nil) //failed json response
                            }
                        } else {
                            if let json = json {
                                guard let message = json["message"] else { return }
                                onCompletion(success, message as? ServerMessage, serverCode, nil, nil)
                            } else {
                                onCompletion(success, serverMessage, serverCode, nil, nil)
                            }
                        }
                    }
                } else {
                    onCompletion(false, YonaConstants.YonaErrorTypes.GetBuddyLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetBuddyLinkFail), nil, nil)
                }
                break
            case .put:

                break
            case .delete:
                if let editBuddyLink = buddy?.editLink {
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: editBuddyLink, httpMethod: httpMethod) { (success, json, error) in
                        onCompletion(success, serverMessage, serverCode, nil, nil)
                    }
                } else {
                    onCompletion(false, YonaConstants.YonaErrorTypes.GetBuddyLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetBuddyLinkFail), nil, nil)
                }
                break
            }
        }
    }
    
    func requestNewbuddy(_ buddyBody: BodyDataDictionary, onCompletion: @escaping APIBuddiesResponse) {
        self.genericBuddyRequest(httpMethods.post, buddyBody: buddyBody, buddy: nil, onCompletion: onCompletion)
    }
    
    func getAllbuddies(_ onCompletion: @escaping APIBuddiesResponse) {
        self.genericBuddyRequest(httpMethods.get, buddyBody: nil, buddy: nil, onCompletion: onCompletion)
    }
    
    func deleteBuddy(_ buddy: Buddies?, onCompletion: @escaping APIBuddiesResponse) {
        self.genericBuddyRequest(httpMethods.delete, buddyBody: nil, buddy: buddy, onCompletion: onCompletion)
    }
    
    
    func getBuddy(_ buddiesLink: String?, onCompletion: @escaping APIBuddiesResponse) {
        if let buddieLink = buddiesLink {
            ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, message, serverCode, activities, error) in
                if success {
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: buddieLink, httpMethod: httpMethods.get) { (success, json, error ) in
                        if success {
                            self.buddies.removeAll()
                            if let json = json {
                                //we just get a buddy response back
                                self.buddy = Buddies.init(buddyData: json, allActivity: activities!)
                                onCompletion(success,error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.buddy, nil)
                            } else {
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil) //failed json response
                            }
                        } else {
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil)
                        }
                    }
                }
            }
            
        } else {
            onCompletion(false, YonaConstants.YonaErrorTypes.GetBuddyLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetBuddyLinkFail), nil, nil)
        }
    }

}
