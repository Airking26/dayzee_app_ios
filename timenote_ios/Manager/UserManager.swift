//
//  UserManager.swift
//  Timenote
//
//  Created by Aziz Essid on 6/9/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import Combine
import os.log
import Firebase
import GoogleSignIn

class UserManager {
    
    static let UserFCMTokenKey      : String        = "UserManager_FCMToken"
    static let UserLoggedTokenKey   : String        = "UserManager_UserLoggedTokenKey"
    static let UserRefreshTokenKey  : String        = "UserManager_UserRefresgTokenKey"
    static let UserVisibilityKey    : String        = "UserManager_UserVisibilityKey"
    static let UserInformationKey   : String        = "UserManager_UserInformationKey"
    static let shared               : UserManager   = UserManager()
    
    // MARK: User variable
    
    // Persisted var to userLocalDefault storage with key UserInformation
    @Persisted(key: UserManager.UserInformationKey)
    private(set) var userInformation    : UserResponseDto?
    // Persisted var to userLocalDefault storage with key UserLoggedTokenKey
    @Persisted(key: UserManager.UserLoggedTokenKey)
    public       var token              : String?
    @Persisted(key: UserManager.UserRefreshTokenKey)
    private(set) var refresh            : String?
    @Persisted(key: UserManager.UserVisibilityKey)
    public       var visibility         : String?
    public var isLogged                 : Bool { get {
        return self.token != nil && !self.token!.isEmpty
    }}
    ///Describe when Google Calendar synchronization is enabled
    public var isSynchronizationEnabled: Bool {
        get {
            if let _ = GIDSignIn.sharedInstance.currentUser {
                return true
            }
            return false
        }
    }

    private(set) var userFollowingListPublisher     = CurrentValueSubject<[UserResponseDto], Never>([])
    private(set) var userFollowersListPublisher     = CurrentValueSubject<[UserResponseDto], Never>([])
    private(set) var userRequestedListPublisher     = CurrentValueSubject<[UserResponseDto], Never>([])
    private(set) var userPendingListPublisher       = CurrentValueSubject<[UserResponseDto], Never>([])
    private(set) var userInformationPublisher       = CurrentValueSubject<UserResponseDto?, Never>(nil)
    private(set) var userGroupsPublisher            = CurrentValueSubject<[UserGroupDto], Never>([])
    private(set) var userPreferencePublisher        =
        CurrentValueSubject<[PreferenceDto], Never>([])
    private(set) var topPublisher                   = CurrentValueSubject<[TopDto], Never>([])
    private(set) var userDeepLink                   = CurrentValueSubject<String?, Never>(nil)
    private(set) var newFollowAsked                 = CurrentValueSubject<String?, Never>(nil)
    private(set) var hiddenUsersListPublisher                = CurrentValueSubject<[UserResponseDto], Never>([])
    private(set) var hiddenEventsListPublisher                = CurrentValueSubject<[TimenoteDataDto], Never>([])

    private         var nameFollwing           : String?
    private         var nameFollowers          : String?
    public          var isUserWithNoAccount    : Bool = false
    public          var isUserSignup           : Bool = false

    // MARK: Override
    
    public func start() {
        // WILL CALL INIT 
    }
    
    init() {
        guard let token = token else { return }
        self.userInformationPublisher.send(self.userInformation)
        WebService.shared.initAuthenticatedSession(with: "Bearer \(token)", refresh: self.refresh)
        DispatchQueue.global().async { [weak self] in
            self?.getUserInfo()
        }
    }
        
    // MARK: User Signin
    
    public func signin(emailOrUsername: String, password: String, completion: @escaping(_ token: String?) -> Void) {
        if emailOrUsername.validateEmail() {
            WebService.shared.signinEmail(emailSignupDto: EmailSigninRequestDto(email: emailOrUsername, password: password)) { result in
                self.handleUserAuthentication(result: result, completion: completion)
            }
        } else {
            WebService.shared.signinUsername(usernameSignupDto: UsernameSigninRequestDto(userName: emailOrUsername, password: password)) { (result) in
                self.handleUserAuthentication(result: result, completion: completion)
            }
        }

    }
    
    private func handleUserAuthentication(result: Result<SignResponeDto, WebServiceError>, completion: @escaping(_ token: String?) -> Void) {
        switch result {
        case .failure(let failure):
            AlertManager.shared.showErrorWithTilteAndDesciption(title: failure.rawValue.localized, desciption: "")
            completion(nil)
        case .success(let signResponseDto):
            self.userInformation = signResponseDto.user
            self.userInformationPublisher.send(signResponseDto.user)
            self.token = signResponseDto.accessToken
            self.refresh = signResponseDto.refreshToken
            completion(signResponseDto.accessToken)
        }
    }
    
    public func getUserInfo() {
        WebService.shared.getMe { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving user info %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
            case .success(let userResponse):
                self.userInformation = userResponse
                self.userInformationPublisher.send(userResponse)
            }
        }
    }
    
    private func clearPublishersData() {
        self.userInformationPublisher.value = nil
        self.topPublisher.value = []
        self.userGroupsPublisher.value = []
        self.userFollowingListPublisher.value = []
        self.userFollowersListPublisher.value = []
        self.userPendingListPublisher.value = []
        self.userRequestedListPublisher.value = []
    }
        
    public func handleRestoreUserPassword(at scene: UIWindowScene,
                                          accessToken: String? = nil,
                                          isForgotPassword: Bool = true) {
        self.handleRestoreUserPassword(at: scene.windows.first?.rootViewController,
                                       accessToken: accessToken,
                                       isForgotPassword: isForgotPassword)
    }
    
    public func handleRestoreUserPassword(at controller: UIViewController?,
                                          accessToken: String? = nil,
                                          isForgotPassword: Bool = false) {
        WebService.shared.initAuthenticatedSession(with: "Bearer \(accessToken ?? "")")
        
        let passwordRestoreStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        let passwordRestoreVC = passwordRestoreStoryboard.instantiateViewController(identifier: "PasswordRestoreViewController") as? PasswordRestoreViewController
        passwordRestoreVC?.isForgotPassword = isForgotPassword
        passwordRestoreVC?.modalPresentationStyle = .fullScreen
        guard let popupView = passwordRestoreVC else { return }
        controller?.present(popupView, animated: true, completion: nil)
    }
    
    public func logOut() {
        Messaging.messaging().deleteData(completion: { (erorr) in
            
        })
        GIDSignIn.sharedInstance.signOut()
        WebService.shared.logoutUser()
        TimenoteManager.shared.reset()
        TimenoteManager.shared.clearPublishersData()
        self.clearPublishersData()
        self.userInformation = nil
        self.token = nil
        self.refresh = nil
        self.nameFollwing = nil
        self.nameFollowers = nil
    }
    
    public func forgotPassword(email: String?, completion : @escaping(Bool) -> Void) {
        guard let email = email else { return }
        WebService.shared.forgotPassword(email: email) { (result) in
            switch result {
            case .failure(let failure):
                AlertManager.shared.showErrorWithTilteAndDesciption(title: failure.rawValue, desciption: "")
                completion(false)
            case .success(let success):
                if success { AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Votre demande de réinitialisation de mot de passe à été effectué, veuillez vérifier votre boite e-mail" : "Your password reset request has been sent, please check your e-mail boxs", desciption: "", isBlue: true) }
                else { AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Votre email est incorrect" : "Your email is not correct", desciption: "") }
                completion(success)
            }
        }
    }
    
    public func changePassword(oldPassword: String?,
                               newPassword: String?,
                               completion: @escaping(Bool) -> Void) {
        guard let userName = self.userInformation?.userName,
              let oldPassword = oldPassword,
              let newPassword = newPassword
        else { return completion(false) }
        WebService.shared.changeUserPassword(userName: userName,
                                             oldPassword: oldPassword,
                                             newPassword: newPassword) { (result) in
            switch result {
            case .failure(let failure):
                AlertManager.shared.showErrorWithTilteAndDesciption(title: failure.rawValue, desciption: "")
                completion(false)
            case .success(_):
                completion(true)
            }
        }
    }
    
    public func changePassword(password: String?,
                               completion: @escaping(Bool) -> Void) {
            guard let password = password else { return completion(false) }
            WebService.shared.changeUserPassword(password: password) { (result) in
                switch result {
                case .failure(_):
                    completion(false)
                case .success(_):
                    completion(true)
                }
            }
        }
    
    public func checkUsername(userName: String?, completion: @escaping(Bool) -> Void) {
        guard let userName = userName else { return completion(false) }
        WebService.shared.checkUsernameAvailability(username: userName) { (result) in
            switch result {
            case .failure(let failure):
                AlertManager.shared.showErrorWithTilteAndDesciption(title: failure.rawValue, desciption: "")
                completion(false)
            case .success(let success):
                completion(success)
            }
        }
    }
    
    // MARK: User Singup
    
    public func signup(email : String, userName: String, password: String, completion: @escaping (_ token: String?) -> Void) {
        var deviceLanguage = Locale.current.languageCode ?? "en"
        deviceLanguage != "fr" ? (deviceLanguage = "en") : ()
        WebService.shared.signup(signupDto: SignupRequestDto(email: email, userName: userName, password: password, language: deviceLanguage)) { (result) in
            switch result {
            case .failure(let failure):
                AlertManager.shared.showErrorWithTilteAndDesciption(title: failure.rawValue, desciption: "")
                completion(nil)
            case .success(let signResponseDto):
                self.userInformation = signResponseDto.user
                self.userInformationPublisher.send(signResponseDto.user)
                self.token = signResponseDto.accessToken
                self.refresh = signResponseDto.refreshToken
                completion(signResponseDto.accessToken)
            }
        }
    }
    
    // MARK: User Search
    
    public func searchUserByName(name: String, offset: Int, completion: @escaping(_ users: [UserResponseDto]?) -> Void) {
        guard !name.isEmpty else { return completion([]) }
        WebService.shared.getUserByName(name: name, offset: offset == 0 ? 0 : offset / 12) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving users by name %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let users):
                completion(users)
                break;
            }
        }
    }
    
    // MARK: Preference
    
    public func getUserPrefs() {
        WebService.shared.getUserPreference { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving user preferences %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let preferences):
                self.userPreferencePublisher.value = preferences
                break;
            }
        }
    }
    
    public func updateUserPrefs(newPrefs: [PreferenceDto]) {
        WebService.shared.updateUserPreference(newPrefs: newPrefs) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving user preferences %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let preferences):
                let prefs = preferences.map({PreferenceDto.init(category: $0.category, rating: $0.rating)})
                self.userPreferencePublisher.value = prefs
                self.getTops()
                break;
            }
        }
    }
    
    // MARK: Top
    
    public func getTops() {
        
        WebService.shared.getUserPreference { result in
            switch result {
            case .success(let preferences):
                for preference in preferences {
                    if preference.rating > 0.0 {
                        DispatchQueue.main.async { [weak self] in
                            WebService.shared.getUsersByCategorie(categorie: preference.category, offset: 0) { result in
                                switch result {
                                case .success(let users):
                                    guard let users = users, !users.isEmpty else {
                                        if let currentTops = self?.topPublisher.value {
                                            var newTop = currentTops
                                            newTop.removeAll(where: { $0.category == preference.category })
                                            self?.topPublisher.send(newTop)
                                        }
                                        return
                                    }
                                    let top = TopDto(category: preference.category, users: users)
                                    guard let currentTops = self?.topPublisher.value, !currentTops.isEmpty else {
                                        self?.topPublisher.send([top])
                                        return
                                    }
                                    var newTop = currentTops
                                    let currentTop = newTop.first(where: { $0.category == top.category })
                                    if !(currentTop == top) {
                                    }
                                    newTop.removeAll(where: { $0.category == top.category && !($0 == top) })
                                    newTop.append(top)
                                    self?.topPublisher.send(newTop)
                                case .failure(let error):
                                    os_log("Error while retriving users by categorie %{PRIVTE}@", log : OSLog.userManager, type : .error, error.rawValue)
                                    break;
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                os_log("Error while retriving user preferences %{PRIVTE}@", log : OSLog.userManager, type : .error, error.rawValue)
                break
            }
        }
    }
    
    
    // MARK: Follow
    
    public func askFollowUser(userId: String?, completion: @escaping(_ success: Bool) -> Void) {
        guard let userId = userId else { return }
        WebService.shared.askFollowuser(userId: userId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while following user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(let success):
                self.getUserInfo()
                completion(success)
                break;
            }
        }
    }
    
    public func followUser(userId: String?, completion: @escaping(_ user: UserResponseDto?) -> Void) {
        guard let userId = userId else { return }
        WebService.shared.followUser(userId: userId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while following user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                completion(nil)
                break;
            case .success(let user):
                self.getUserInfo()
                completion(user)
                break;
            }
        }
    }
    
    public func unfollowUser(userId: String?, completion: @escaping(_ user: Bool) -> Void) {
        guard let userId = userId else { return }
        WebService.shared.unfollowUser(userId: userId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while unfollowing user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(_):
                var followers = self.userFollowingListPublisher.value
                followers.removeAll(where: {$0.id == userId})
                self.userFollowingListPublisher.value = followers
                self.getUserInfo()
                completion(true)
                break;
            }
        }
    }
    
    public func removeFollower(userId: String?, completion: @escaping(_ user: Bool) -> Void) {
        guard let userId = userId else { return }
        WebService.shared.removeFollower(userId: userId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while unfollowing user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(_):
                var followers = self.userFollowersListPublisher.value
                followers.removeAll(where: {$0.id == userId})
                self.userFollowersListPublisher.value = followers
                self.getUserInfo()
                completion(true)
                break;
            }
        }
    }
    
    public func isWaitApproval(userId: String?, completion: @escaping(Bool) -> Void) {
        guard let userID = userId else { return }
        WebService.shared.checkWaitingApproval(userID: userID) { result in
            completion(result)
        }
    }
    
    // MARK: GET USERS
    
    public func getUser(userId: String?, completion: @escaping(UserResponseDto?) -> Void) {
        guard let userId = userId else { return }
        WebService.shared.getUser(userId: userId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while unfollowing user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                completion(nil)
                break;
            case .success(let user):
                completion(user)
                break;
            }
        }
    }
    
    public func updateUserInfo(userData: UserUpdateDto) {
        WebService.shared.updateUserData(userData: userData) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while updating user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let userInfo):
                self.userInformationPublisher.send(userInfo)
                self.userInformation = userInfo
                break;
            }
        }
    }
    
    // MARK: HIDDEN
    
    public func getHiddenUsers() {
        WebService.shared.getHiddenUsers(offset: 0) { result in
            switch result {
            case .success(let users):
                self.hiddenUsersListPublisher.send(users)
            case .failure(let error):
                os_log("Error while getting hidden users list %{PRIVTE}@", log : OSLog.userManager, type : .error, error.rawValue)
            }
        }
    }
    
    public func getHiddenEvents() {
        WebService.shared.getHiddenEvents(offset: 0) { result in
            switch result {
            case .success(let events):
                self.hiddenEventsListPublisher.send(events)
            case .failure(let error):
                os_log("Error while getting hidden events list %{PRIVTE}@", log : OSLog.userManager, type : .error, error.rawValue)
            }
        }
    }
    
    public func deleteHiddenUser(id: String, completion: @escaping (Bool) -> Void) {
        WebService.shared.deleteHiddenUser(id: id) { result in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while deleting hidden user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(_):
                completion(true)
                break;
            }
        }
    }
    
    public func deleteHiddenEvent(id: String, completion: @escaping (Bool) -> Void) {
        WebService.shared.deleteHiddenEvent(id: id) { result in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while deleting hidden event %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(_):
                completion(true)
                break;
            }
        }
    }
    
    // MARK: GROUPS
    
    public func getUserGroup() {
        WebService.shared.getGroups { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while updating user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let groups):
                self.userGroupsPublisher.send(groups)
                break;
            }
        }
    }
    
    public func updateGroup(groupId: String, group: CreateGroupDto) {
        WebService.shared.modifyGroup(groupId: groupId, group: group) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while updating user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(_):
                self.getUserGroup()
                break;
            }
        }
    }
        
    public func deleteGroup(groupId: String) {
        WebService.shared.deleteGroup(groupId: groupId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while updating user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(_):
                self.getUserGroup()
                break;
            }
        }
    }
    
    public func createGroup(group: CreateGroupDto) {
        WebService.shared.postNewGroup(group: group) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while creating group %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(_):
                self.getUserGroup()
                break;
            }
        }
    }
    
    public func getFollowersByName(name: String?, userId: String?) {
        let offset = name == self.nameFollowers ? self.userFollowersListPublisher.value.count / 12 : 0
        self.nameFollowers = name ?? ""
        if let name = name, !name.isEmpty {
            WebService.shared.getFollowersByName(offset: offset, name: name) { (result) in
                switch result {
                case .failure(let errorDescription):
                    os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                    break;
                case .success(var users):
                    if offset != 0 {
                        users.removeAll(where: {self.userFollowersListPublisher.value.contains($0)})
                        guard !users.isEmpty else { return }
                        var newUsers = self.userFollowersListPublisher.value;
                        newUsers.append(contentsOf: users)
                        users = newUsers
                    }
                    self.userFollowersListPublisher.send(users)
                    break;
                }
            }
        } else if let userId = userId {
            WebService.shared.getFollowers(userId: userId, offset: offset) { (result) in
                switch result {
                case .failure(let errorDescription):
                    os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                    break;
                case .success(var users):
                    if offset != 0 {
                        users.removeAll(where: {self.userFollowersListPublisher.value.contains($0)})
                        guard !users.isEmpty else { return }
                        var newUsers = self.userFollowersListPublisher.value;
                        newUsers.append(contentsOf: users)
                        users = newUsers
                    }
                    self.userFollowersListPublisher.send(users)
                    break;
                }
            }
        }
    }
    
    public func getFollowingByName(name: String?, userId: String?) {
        let offset = name == self.nameFollwing ? self.userFollowingListPublisher.value.count / 12 : 0
        self.nameFollwing = name ?? ""
        if let name = name, !name.isEmpty {
            WebService.shared.getFollowingByName(offset: offset, name: name) { (result) in
                switch result {
                case .failure(let errorDescription):
                    os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                    break;
                case .success(var users):
                    if offset != 0 {
                        users.removeAll(where: {self.userFollowingListPublisher.value.contains($0)})
                        guard !users.isEmpty else { return }
                        var newUsers = self.userFollowingListPublisher.value;
                        newUsers.append(contentsOf: users)
                        users = newUsers
                    }
                    self.userFollowingListPublisher.send(users)
                    break;
                }
            }
        } else if let userId = userId {
            WebService.shared.getFollowing(userId: userId, offset: offset) { (result) in
                switch result {
                case .failure(let errorDescription):
                    os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                    break;
                case .success(var users):
                    if offset != 0 {
                        users.removeAll(where: {self.userFollowingListPublisher.value.contains($0)})
                        guard !users.isEmpty else { return }
                        var newUsers = self.userFollowingListPublisher.value;
                        newUsers.append(contentsOf: users)
                        users = newUsers
                    }
                    self.userFollowingListPublisher.send(users)
                    break;
                }
            }
        }
    }
    
    public func shareTimenoteWithUsers(timenoteId: String?, users: [String]) {
        guard let timenoteId = timenoteId, !users.isEmpty else { return }
        WebService.shared.shareTimenote(shareDto: ShareTimenoteDto(timenote: timenoteId, users: users)) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while sharing user timenote %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(_):
                break;
            }
        }
    }
    
    public func updateUserPrivacyAccount(isPrivate: Bool) {
        guard let userInformation = UserManager.shared.userInformation else { return }
        let userDto = UserUpdateDto(givenName: userInformation.givenName, familyName: userInformation.familyName, picture: userInformation.picture, location: userInformation.location, birthday: userInformation.birthday, description: userInformation.descript, gender: userInformation.genderEnum, status: isPrivate ? .PRIVATE : .PUBLIC, dateFormat: userInformation.dateFormat, socialMedias: userInformation.socialMedias)
        self.updateUserInfo(userData: userDto)
    }
    
    public func updateDateFormatAccount(isDate: Bool) {
        guard let userInformation = UserManager.shared.userInformation else { return }
        let userDto = UserUpdateDto(givenName: userInformation.givenName, familyName: userInformation.familyName, picture: userInformation.picture, location: userInformation.location, birthday: userInformation.birthday, description: userInformation.descript, gender: userInformation.genderEnum, status: userInformation.status, dateFormat: isDate ? .SECOND : .FIRST, socialMedias: userInformation.socialMedias)
        self.updateUserInfo(userData: userDto)
    }
    
    public func getPending(refresh : Bool) {
        let offset = refresh ? 0 : self.userPendingListPublisher.value.count / 12
        WebService.shared.getPending(offset: offset) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var users):
                if offset != 0 {
                    users.removeAll(where: {self.userPendingListPublisher.value.contains($0)})
                    guard !users.isEmpty else { return }
                    var newUsers = self.userPendingListPublisher.value;
                    newUsers.append(contentsOf: users)
                    users = newUsers
                }
                self.userPendingListPublisher.send(users)
                break;
            }
        }
    }
    
    public func getRequested(refresh : Bool) {
        let offset = refresh ? 0 : self.userRequestedListPublisher.value.count / 12
        WebService.shared.getRequested(offset: offset) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var users):
                if offset != 0 {
                    users.removeAll(where: {self.userRequestedListPublisher.value.contains($0)})
                    guard !users.isEmpty else { return }
                    var newUsers = self.userRequestedListPublisher.value;
                    newUsers.append(contentsOf: users)
                    users = newUsers
                }
                self.userRequestedListPublisher.send(users)
                break;
            }
        }
    }
    
    public func acceptFollow(userId: String?) {
        guard let userId = userId else { return }
        WebService.shared.acceptFollowRequested(userId: userId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let user):
                var newUsers = self.userPendingListPublisher.value;
                newUsers.removeAll(where: {$0.id == user.id})
                self.userPendingListPublisher.send(newUsers)
                break;
            }
        }
    }
    
    public func declineFollow(userId: String?) {
        guard let userId = userId else { return }
        WebService.shared.declineFollowRequested(userId: userId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user following %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let user):
                var newUsers = self.userPendingListPublisher.value;
                newUsers.removeAll(where: {$0.id == user.id})
                self.userPendingListPublisher.send(newUsers)
                break;
            }
        }
    }
    
}
