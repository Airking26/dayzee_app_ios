//
//  WebServices.swift
//  Timenote
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//


import Foundation
import Alamofire
import GoogleSignIn
import GoogleAPIClientForREST
import GTMAppAuth
import Unrealm
import RealmSwift
import Branch

enum WebServiceError: String, Error {
    case serverError
    case invalidUsername
    case invalideGoogleArguments
    case usernameOrPasswordInvalid
    case emailOrPasswordInvalid
    case emailAlreadyUsed
    case usernameAlreadyUsed
}

enum Result<Success, Failure : Error> {
    case success(Success)
    case failure(Failure)
}

class WebService {

    struct Consts {
        
        // MARK: WebService Configuration
        
        static let LogDebug                                 = true
        
        static let DefaultRequestTimeout :  TimeInterval    = 60.0
        
        static let AuthorizationHeader                      = "Authorization"
        static let RefreshHeader                            = "Refresh"
        static let ContentTypeHeader                        = "Content-Type"
        static let AcceptHeader                             = "Accept"
        static let JsonContentType                          = "application/json"
        
        // MARK: User agreement links
        
        static let TermOfUseURL = "http://timenote-env.eba-2htqeacb.us-east-1.elasticbeanstalk.com/terms_of_use"
        static let PrivacyPolicyURL = "http://timenote-env.eba-2htqeacb.us-east-1.elasticbeanstalk.com/privacy_policy"
        
        // MARK: Google Search Engine URL

        static let RootGoogleSearchAPIURL                   = "https://www.googleapis.com/customsearch/v1"
        static let RootGoogleSearchAPIScheme                = "https"
        static let RootGoogleSearchAPIHost                  = "www.googleapis.com"
        static let RootGoogleSearchAPIPath                  = "/customsearch/v1"

        // MARK: Data Base URL

        static let RootWSURL                                = URL(string: "http://timenote-env.eba-2htqeacb.us-east-1.elasticbeanstalk.com/")!
        

        static let SignInWSURL                              = RootWSURL.appendingPathComponent("auth/signIn")
        static let LogoutWSURL                              = RootWSURL.appendingPathComponent("auth/logout")
        static let ForgotPasswordWSURL                      = RootWSURL.appendingPathComponent("auth/resetPassword")
        static let RefreshWSURL                             = RootWSURL.appendingPathComponent("auth/refresh")
        static let SignInAdminWSURL                         = SignInWSURL.appendingPathComponent("admin")
        static let SignInEmailWSURL                         = RootWSURL.appendingPathComponent("auth/signIn/email")
        static let SignInUsernameWSURL                      = RootWSURL.appendingPathComponent("auth/signIn/userName")
        static let SignUpWSURL                              = RootWSURL.appendingPathComponent("auth/signUp")
        static let CheckEmailWSURL                          = RootWSURL.appendingPathComponent("auth/availability/email")
        static let CheckUsernameWSURL                       = RootWSURL.appendingPathComponent("auth/availability/username")
        
        static let UserWSURL                                = RootWSURL.appendingPathComponent("users")
        static let UserProfilWSURL                          = RootWSURL.appendingPathComponent("users/me")
        static let TokenDeviceWSURL                         = RootWSURL.appendingPathComponent("users/me/fcm")
        static let UserModifyPassowrdWSURL                  = RootWSURL.appendingPathComponent("auth/modifyPassword")
        static let UserChangePassowrdWSURL                  = RootWSURL.appendingPathComponent("users/changePassword")


        static let CategorieWSURL                           = RootWSURL.appendingPathComponent("category")
        static let AllCategorieWSURL                        = RootWSURL.appendingPathComponent("category/all")
        
        static let PreferencesWSURL                         = RootWSURL.appendingPathComponent("preference/me")
        
        static let SearchCategorieUserWSURL                 = RootWSURL.appendingPathComponent("search/category/top/users")
        static let SearchUsersByNameWSURL                   = RootWSURL.appendingPathComponent("search/users")
        static let SearchTopsByNameWSURL                    = RootWSURL.appendingPathComponent("search/tops")

        static let TimenoteFeedWSURL                        = RootWSURL.appendingPathComponent("timenote/feed")
        static let TimenoteFeedUpcomingWSURL                = TimenoteFeedWSURL.appendingPathComponent("upcoming")
        static let TimenoteFeedPasWSURL                     = TimenoteFeedWSURL.appendingPathComponent("past")
        
        static let FollowWSURL                              = RootWSURL.appendingPathComponent("follow/me")
        static let FollowPendingWSURL                       = FollowWSURL.appendingPathComponent("pending")
        static let FollowRequestedWURL                      = FollowWSURL.appendingPathComponent("requested")
        static let FollowsWSURL                             = FollowWSURL.appendingPathComponent("following")
        static let FollowAskWSURL                           = FollowWSURL.appendingPathComponent("ask")
        static let FollowAcceptWSURL                        = FollowWSURL.appendingPathComponent("accept")
        static let FollowDeclineWSURL                       = FollowWSURL.appendingPathComponent("decline")
        
        static let FollowFollowingWSURL                     = RootWSURL.appendingPathComponent("follow/search/following")
        static let FollowFollowersWSURL                     = RootWSURL.appendingPathComponent("follow/search/followers")
        static let FollowUserWSURL                          = RootWSURL.appendingPathComponent("follow")

        static let TimenoteRecentWSURL                      = RootWSURL.appendingPathComponent("timenote/recent")
        static let TimenoteParticipantWSURL                 = RootWSURL.appendingPathComponent("timenote")
        static let TimenoteSearchWSURL                      = RootWSURL.appendingPathComponent("search/timenotes")
        static let TimenoteShareWSURL                       = RootWSURL.appendingPathComponent("timenote/shareWith")

        static let TimenoteLikeWSURL                        = RootWSURL.appendingPathComponent("timenote/like")
        static let TimenoteDislikeWSURL                     = RootWSURL.appendingPathComponent("timenote/dislike")
        static let TimenoteJoinWSURL                        = RootWSURL.appendingPathComponent("timenote/join")
        static let TimenoteLeaveWSURL                       = RootWSURL.appendingPathComponent("timenote/leave")
        static let TimenoteJoinPrivateWSURL                 = RootWSURL.appendingPathComponent("timenote/joinPrivate")

        static let NearnyWSURL                              = RootWSURL.appendingPathComponent("nearby")

        static let TimenoteCommentsWSURL                    = RootWSURL.appendingPathComponent("comment")
        static let TimenoteCommentsCreateWSURL              = RootWSURL.appendingPathComponent("comment/create")
        static let TimenoteCommentsLikeWSURL                = RootWSURL.appendingPathComponent("comment/like")
        static let TimenoteCommentsDislikeWSURL             = RootWSURL.appendingPathComponent("comment/dislike")
        static let TimenoteCommentsDeleteWSURL              = RootWSURL.appendingPathComponent("comment/delete")
        static let TimenoteCommentsUpdateWSURL              = RootWSURL.appendingPathComponent("comment/update")

        static let TimenoteAlarmWSURL                       = RootWSURL.appendingPathComponent("alarm")

        static let TimenoteSignalementWSURL                 = RootWSURL.appendingPathComponent("signalment/timenote")

        static let ProfilWSURL                              = RootWSURL.appendingPathComponent("profile")
        static let UserGroupWSURL                           = ProfilWSURL.appendingPathComponent("group")
        static let UserGroupsWSURL                          = ProfilWSURL.appendingPathComponent("groups")
        static let ProfilTimenoteFilteredWSURL              = ProfilWSURL.appendingPathComponent("timenotes/filtered")
        
        static let CertifyWSURL                             = ProfilWSURL.appendingPathComponent("certify")
        
        static let NotificationWSURL                        = RootWSURL.appendingPathComponent("notification")
        
        static let HideTimenoteAndUserWSURL                 = RootWSURL.appendingPathComponent("hidded-timenote-user")
        /// Used to load hidden users list.
        static let HiddenUsersWSURL = HideTimenoteAndUserWSURL.appendingPathComponent("hidden-users")
        /// Used to load hidden events list.
        static let HiddenEventsWSURL = HideTimenoteAndUserWSURL.appendingPathComponent("hidden-events")
        /// Used to deleting hidden user.
        static let HiddenUserWSURL = HideTimenoteAndUserWSURL.appendingPathComponent("hidden-user")
        /// Used to deleting hidden event.
        static let HiddenEventWSURL = HideTimenoteAndUserWSURL.appendingPathComponent("hidden-event")
        

        private init() {}
    }
    
    private init() {
        defaultURLSessionConfiguration                              = .default
        defaultURLSessionConfiguration.timeoutIntervalForRequest    = Consts.DefaultRequestTimeout
        defaultURLSessionConfiguration.httpAdditionalHeaders        = [Consts.AcceptHeader: Consts.JsonContentType, Consts.ContentTypeHeader: Consts.JsonContentType]
        decoder.dateDecodingStrategy                                = .iso8601
        encoder.dateEncodingStrategy                                = .iso8601
        standardSession                                             = URLSession(configuration: defaultURLSessionConfiguration, delegate: nil, delegateQueue: .main)
        // Init the session without authorization header
        authenticatedSession                                        = URLSession(configuration: defaultURLSessionConfiguration, delegate: nil, delegateQueue: .main)
        // Google Session
        googleSession                                               = URLSession(configuration: defaultURLSessionConfiguration, delegate: nil, delegateQueue: .main)
    }
    
    static let shared = WebService()
    
    lazy var realm: Realm = {
        self.checkRealmSchema()
        return try! Realm()
    }()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let defaultURLSessionConfiguration  : URLSessionConfiguration
    private let googleSession                   : URLSession
    private let standardSession                 : URLSession
    private var authenticatedSession            : URLSession
    
    /**
     Indicates count of loaded events from Google calendar.
     
     Used for showing alert when new events loaded.
     */
    private var loadedGoogleEventsCount = 0
    
    /// Creates calendar service with current authentication
    private var calendarService: GTLRCalendarService? = {
        let service = GTLRCalendarService()
        service.shouldFetchNextPages = true
        service.isRetryEnabled = true
        return service
    }()
    
    private var defaults = UserDefaults.standard
    private let realmSchemaKey = "RealmMigrationSchema"

    var apnsToken: String = ""
    
    // MARK: Realm version controll
    
    private func checkRealmSchema() {
        defaults.register(defaults: [realmSchemaKey : 1])
        let currentSchemaVersion = defaults.integer(forKey: realmSchemaKey)
        do {
            let _ = try Realm()
        } catch {
            defaults.setValue(currentSchemaVersion + 1, forKey: realmSchemaKey)
            self.migrateRealmSchema()
        }
    }
    
    private func migrateRealmSchema() {
        ///Updated manually when the structure of the stored data changes
        let currentConfigNumber: UInt64 = UInt64(defaults.integer(forKey: realmSchemaKey))
        
        let config = Realm.Configuration(
            schemaVersion: currentConfigNumber,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < currentConfigNumber) {}
            })
        Realm.Configuration.defaultConfiguration = config
    }
    
    /* GOOGLE SEARCH ENGINE */
    
    // MARK: Google Engine
    
    public func getGoogleImages(by text: String, paginationIndex : Int, completion: @escaping(Result<GoogleAPISearchResponse, WebServiceError>) -> Void) {
        var googleSearchApiURL          = URLComponents()
        
        googleSearchApiURL.scheme       = WebService.Consts.RootGoogleSearchAPIScheme
        googleSearchApiURL.host         = WebService.Consts.RootGoogleSearchAPIHost
        googleSearchApiURL.path         = WebService.Consts.RootGoogleSearchAPIPath
        googleSearchApiURL.queryItems   = GoogleAPISearchParameter(start: paginationIndex, q: text).toQueryItems()
        
        let url = try! googleSearchApiURL.asURL()
        
        self.getDataTask(url, isGoogleApi: true) { (results: GoogleAPISearchResponse?, response) in
            guard let results = results else { return completion(.failure(.invalideGoogleArguments)) }
            completion(.success(results))
        }
    }
    
    /* TIMENOTE API WS */
    
    // MARK: Authentication
    
    public func signinUsername(usernameSignupDto: UsernameSigninRequestDto, completion: @escaping(Result<SignResponeDto, WebServiceError>) -> Void) {
        let body = try! encoder.encode(usernameSignupDto)
        self.postDataTask(WebService.Consts.SignInUsernameWSURL, body: body) { (result: SignResponeDto?, response) in
            guard let result = result else { return completion(.failure(.usernameOrPasswordInvalid)) }
            self.initAuthenticatedSession(with: "Bearer \(result.accessToken)", refresh: result.refreshToken)
            self.updateUserFCMToken()
            completion(.success(result))
        }
    }
    
    public func refreshToken(completion: @escaping(Bool, WebServiceResponse) -> Void) {
        var urlRequest = URLRequest(url: WebService.Consts.RefreshWSURL)
        urlRequest.httpMethod = "GET"
        urlRequest.httpBody = nil
        self.process(urlRequest: urlRequest, requiresAuthentication: true, canRetryOnUnauthorized: false) { (accessToken: AccessTokenDto?, response) in
            guard let accessToken = accessToken else { return completion(false, response) }
            UserManager.shared.token = accessToken.accessToken
            self.initAuthenticatedSession(with: "Bearer \(accessToken.accessToken)")
            completion(true, response)
        }
    }
    
    public func signinEmail(emailSignupDto: EmailSigninRequestDto, completion: @escaping(Result<SignResponeDto, WebServiceError>) -> Void) {
        let body = try! encoder.encode(emailSignupDto)
        self.postDataTask(WebService.Consts.SignInEmailWSURL, body: body) { (result: SignResponeDto?, response) in
            guard let result = result else { return completion(.failure(.emailOrPasswordInvalid)) }
            self.initAuthenticatedSession(with: "Bearer \(result.accessToken)", refresh: result.refreshToken)
            self.updateUserFCMToken()
            completion(.success(result))
        }
    }
    
    public func signup(signupDto: SignupRequestDto, completion: @escaping(Result<SignResponeDto, WebServiceError>) -> Void) {
        let body = try! encoder.encode(signupDto)
        self.postDataTask(WebService.Consts.SignUpWSURL, body: body) { (result: SignResponeDto?, response) in
            guard let result = result else { return completion(.failure(.emailAlreadyUsed)) }
            self.initAuthenticatedSession(with: "Bearer \(result.accessToken)", refresh: result.refreshToken)
            self.updateUserFCMToken()
            completion(.success(result))
        }
    }
    
    public func checkEmailAvailability(email : String, completion: @escaping(Result<Bool, WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.CheckEmailWSURL.appendingPathComponent(email)) { (result: Bool?, response) in
            guard let result = result else { return completion(.failure(.emailAlreadyUsed))}
            completion(result ? .success(true) : .failure(.emailAlreadyUsed))
        }
    }
    
    public func checkUsernameAvailability(username : String, completion: @escaping(Result<Bool, WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.CheckUsernameWSURL.appendingPathComponent(username)) { (result: AvailableDto?, response) in
            guard response.statusCode == 200 else { return completion(.failure(.usernameAlreadyUsed))}
            completion(.success(result?.isAvailable ?? false))
        }
    }
    
    public func forgotPassword(email: String, completion: @escaping(Result<Bool, WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.ForgotPasswordWSURL.appendingPathComponent(email)) { (success: Bool?, response) in
            completion(.success(response.statusCode == 200))
        }
    }
    
    public func changeUserPassword(userName: String,
                                   oldPassword: String,
                                   newPassword: String,
                                   completion: @escaping(Result<UserResponseDto?, WebServiceError>) -> Void) {
        let url = WebService.Consts.UserModifyPassowrdWSURL.appendingPathComponent(userName).appendingPathComponent(oldPassword).appendingPathComponent(newPassword)
        self.patchDataTask(url, body: nil, requiresAuthentication: true) { (user: UserResponseDto?, response) in
            guard let user = user else { return completion(.failure(.serverError))}
            completion(.success(user))
        }
    }
    
    public func changeUserPassword(password: String, completion: @escaping(Result<UserResponseDto?, WebServiceError>) -> Void) {
        self.patchDataTask(WebService.Consts.UserChangePassowrdWSURL.appendingPathComponent(password), body: nil, requiresAuthentication: true) { (user: UserResponseDto?, response) in
            guard let user = user else { return completion(.failure(.serverError))}
            completion(.success(user))
        }
    }
    
    public func logoutUser() {
        self.postDataTask(WebService.Consts.LogoutWSURL, body: nil, requiresAuthentication: true) { (user: UserResponseDto?, response) in
        }
        self.initAuthenticatedSession(with: "", refresh: nil)
    }
    
    // MARK: User
    
    public func getMe(completion: @escaping(Result<UserResponseDto, WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.UserProfilWSURL, requiresAuthentication: true) { (user: UserResponseDto?, response) in
            guard let user = user else { return completion(.failure(.serverError))}
            completion(.success(user))
        }
    }
    
    public func certifyUser(with id: String) {
        let url = WebService.Consts.CertifyWSURL.appendingPathComponent(id)
        self.putDataTask(url, body: nil, requiresAuthentication: true, isGoogleApi: false) { (userResponse: UserResponseDto?, response) in
            print("Certify response - \(response.localizedDescription)")
        }
    }
    
    public func updateUserData(userData: UserUpdateDto, completion: @escaping(Result<UserResponseDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(userData)
        self.patchDataTask(WebService.Consts.UserProfilWSURL, body: body, requiresAuthentication: true) { (userResponse: UserResponseDto?, response) in
            guard let userResponse = userResponse else { return completion(.failure(.serverError))}
            completion(.success(userResponse))
        }
    }
    
    public func getHiddenUsers(offset: Int, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.HiddenUsersWSURL.appendingPathComponent("\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func getHiddenEvents(offset: Int, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.HiddenEventsWSURL.appendingPathComponent("\(offset)"), requiresAuthentication: true) { (events: [TimenoteDataDto]?, response) in
            guard let events = events else { return completion(.failure(.serverError))}
            completion(.success(events))
        }
    }
    
    public func deleteHiddenUser(id: String, completion: @escaping(Result<UserResponseDto?, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.HiddenUserWSURL.appendingPathComponent(id), body: nil, requiresAuthentication: true) { (user: UserResponseDto?, response) in
            guard response.statusCode == 200 else { return completion(.failure(.serverError))}
            completion(.success(user))
        }
    }
    
    public func deleteHiddenEvent(id: String, completion: @escaping(Result<TimenoteDataDto?, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.HiddenEventWSURL.appendingPathComponent(id), body: nil, requiresAuthentication: true) { (event: TimenoteDataDto?, response) in
            guard response.statusCode == 200 else { return completion(.failure(.serverError))}
            completion(.success(event))
        }
    }
        
    public func updateUserFCMToken() {
        guard let token = UserDefaults.standard.value(forKey: UserManager.UserFCMTokenKey) as? String else { return }
        let body = try! self.encoder.encode(FCMTokenDto(token: token))
        self.putDataTask(WebService.Consts.TokenDeviceWSURL, body: body, requiresAuthentication: true) { (result: UserResponseDto?, response) in
            // Nothing to do here after FCM UPDATE
        }
    }
    
    public func postNewGroup(group: CreateGroupDto, completion: @escaping(Result<UserGroupDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(group)
        self.postDataTask(WebService.Consts.UserGroupWSURL, body: body, requiresAuthentication: true) { (group: UserGroupDto?, response) in
            guard let group = group else { return completion(.failure(.serverError))}
            completion(.success(group))
        }
    }
    
    public func deleteGroup(groupId: String, completion: @escaping(Result<UserGroupDto, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.UserGroupWSURL.appendingPathComponent(groupId), body: nil, requiresAuthentication: true) { (group: UserGroupDto?, response) in
            guard let group = group else { return completion(.failure(.serverError))}
            completion(.success(group))
        }
    }
    
    public func modifyGroup(groupId: String, group: CreateGroupDto, completion: @escaping(Result<UserGroupDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(group)
        self.patchDataTask(WebService.Consts.UserGroupWSURL.appendingPathComponent(groupId), body: body, requiresAuthentication: true) { (group: UserGroupDto?, response) in
            guard let group = group else { return completion(.failure(.serverError))}
            completion(.success(group))
        }
    }
    
    public func getGroups(completion: @escaping(Result<[UserGroupDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.UserGroupsWSURL, requiresAuthentication: true) { (groups: [UserGroupDto]?, response) in
            guard let groups = groups else { return completion(.failure(.serverError))}
            completion(.success(groups))
        }
    }
    
    public func getFollowingByName(offset: Int, name: String, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.FollowFollowingWSURL.appendingPathComponent("\(name)/\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func getFollowersByName(offset: Int, name: String, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.FollowFollowersWSURL.appendingPathComponent("\(name)/\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func getFollowing(userId: String, offset: Int, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.FollowUserWSURL.appendingPathComponent("\(userId)/following/\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func getFollowers(userId: String, offset: Int, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.FollowUserWSURL.appendingPathComponent("\(userId)/followers/\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func getPending(offset: Int, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.FollowPendingWSURL.appendingPathComponent("\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func getRequested(offset: Int, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.FollowRequestedWURL.appendingPathComponent("\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func acceptFollowRequested(userId: String, completion: @escaping(Result<UserResponseDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.FollowAcceptWSURL.appendingPathComponent("\(userId)"), body: nil, requiresAuthentication: true) { (users: UserResponseDto?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    public func declineFollowRequested(userId: String, completion: @escaping(Result<UserResponseDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.FollowDeclineWSURL.appendingPathComponent("\(userId)"), body: nil, requiresAuthentication: true) { (users: UserResponseDto?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    // MARK: Search
    
    public func getUserByName(name: String, offset: Int, completion: @escaping(Result<[UserResponseDto]?, WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.SearchUsersByNameWSURL.appendingPathComponent("\(name)/\(offset)"), requiresAuthentication: true) { (result: [UserResponseDto]?, response) in
            guard let result = result else { return completion(.failure(.serverError))}
            completion(.success(result))
        }
    }
    
    public func getSearchTop(completion: @escaping(Result<[TopDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.SearchTopsByNameWSURL, requiresAuthentication: true) { (tops: [TopDto]?, response) in
            guard let tops = tops else { return completion(.failure(.serverError))}
            completion(.success(tops))
        }
    }
    
    // MARK: Categories
    
    public func getCategories(completion: @escaping(Result<[CategorieDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.AllCategorieWSURL) { (categories: [CategorieDto]?, response) in
            guard let categories = categories else { return completion(.failure(.serverError))}
            completion(.success(categories))
        }
    }
    
    public func getUsersByCategorie(categorie: CategorieDto, offset: Int, completion: @escaping(Result<[UserResponseDto]?, WebServiceError>) -> Void) {
        let body = try! encoder.encode(categorie)
        self.postDataTask(WebService.Consts.SearchCategorieUserWSURL, body: body, requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError))}
            completion(.success(users))
        }
    }
    
    // MARK: Follow
    
    public func askFollowuser(userId: String, completion: @escaping(Result<Bool, WebServiceError>) -> Void) {
        self.postDataTask(WebService.Consts.FollowAskWSURL.appendingPathComponent(userId), body: nil, requiresAuthentication: true) { (noData: Bool?, response) in
            return completion(.success(response.statusCode == 201))
        }
    }
    
    public func followUser(userId: String, completion: @escaping(Result<UserResponseDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.FollowWSURL.appendingPathComponent(userId), body: nil, requiresAuthentication: true) { (user: UserResponseDto?, response) in
            guard let user = user else { return completion(.failure(.serverError))}
            completion(.success(user))
        }
    }
    
    public func unfollowUser(userId: String, completion: @escaping(Result<Bool, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.FollowWSURL.appendingPathComponent(userId), body: nil, requiresAuthentication: true) { (noData: Bool?, response) in
            guard response.statusCode == 200 else { return completion(.failure(.serverError))}
            completion(.success(true))
        }
    }
    
    public func removeFollower(userId: String, completion: @escaping(Result<Bool, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.FollowWSURL.appendingPathComponent("remove/\(userId)"), body: nil, requiresAuthentication: true) { (noData: Bool?, response) in
            guard response.statusCode == 200 else { return completion(.failure(.serverError))}
            completion(.success(true))
        }
    }
    
    public func getUser(userId: String, completion: @escaping(Result<UserResponseDto, WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.UserWSURL.appendingPathComponent(userId), requiresAuthentication: true) { (user: UserResponseDto?, response) in
            guard let user = user else { return completion(.failure(.serverError))}
            completion(.success(user))
        }
    }
    
    public func checkWaitingApproval(userID: String, completion: @escaping (Bool) -> Void) {
        let request = WebService.Consts.FollowUserWSURL.appendingPathComponent("\(userID)/check-waiting-approval")
        self.getDataTask(request, requiresAuthentication: true, isGoogleApi: false) { (result: Bool?, _)in
            completion(result ?? false)
        }
    }
    
    // MARK: Branch
    
    public func setupBranchLink(timenote: TimenoteDataDto, completion: @escaping (String) -> Void) {

        let branchObject = BranchUniversalObject(canonicalIdentifier: timenote.id)
        branchObject.title = timenote.startingDate?.getShortDare() ?? ""
        branchObject.contentDescription = "\(timenote.title) \(timenote.startingDate?.getShortDare() ?? "")"
        branchObject.imageUrl = timenote.pictures.first
        branchObject.publiclyIndex = true
        branchObject.locallyIndex = true
        branchObject.contentMetadata.contentSchema = .mediaImage

        var link = timenote.url ?? "https://dayzee.app.link"
        if let _ = timenote.url {
            link = normalizeUrl(urlString: link)
        }

        let properties = BranchLinkProperties()
        properties.channel = "ios_app"
        properties.addControlParam("?bnc_validate=true", withValue: link)
        properties.addControlParam("$desktop_url", withValue: "https://apps.apple.com/gb/app/timenote-social-calendar-youtube-planner/id968738944?l")
        properties.addControlParam("$ios_url", withValue: link)
        properties.addControlParam("$android_url", withValue: link)
        properties.addControlParam("timenote_id", withValue: timenote.id)
        properties.addControlParam("$uri_redirect_mode", withValue: "2")

        branchObject.getShortUrl(with: properties) { url, error in
            if let error = error {
                print("Error - \(error)")
            }
            guard let url = url else { return }
            completion(url)
        }
    }
    
    public func normalizeUrl(urlString: String) -> String {
        var result = urlString
        if !result.starts(with: "http") {
            if result.starts(with: "www") {
                result = "https://\(result)"
            } else {
                result = "https://www.\(result)"
            }
        }
        return result
    }

    // MARK: Preference User
    
    public func getUserPreference(completion: @escaping(Result<[PreferenceDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.PreferencesWSURL, requiresAuthentication: true) { (preference: [PreferenceDto]?, response) in
            guard let preference = preference else { return completion(.failure(.serverError))}
            completion(.success(preference))
        }
    }
    
    public func updateUserPreference(newPrefs: [PreferenceDto], completion: @escaping(Result<[PreferencePatchDto], WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(PreferenceUpdateDto(preferences: newPrefs))
        self.patchDataTask(WebService.Consts.PreferencesWSURL, body: body, requiresAuthentication: true) { (preference: [PreferencePatchDto]?, response) in
            guard let preference = preference else { return completion(.failure(.serverError))}
            completion(.success(preference))
        }
    }
    
    // MARK: Timenote Saving
    
    private func saveTimenoteToDatabase(timenotes: [TimenoteDataDto], of type: TimenoteFeedType) {
        if realm.object(ofType: TimenotesLocalData.self, forPrimaryKey: type.rawValue) != nil {
            return
        }
        let savingData = TimenotesLocalData(id: type.rawValue, timenotes: timenotes)

        try! realm.write {
            realm.add(savingData, update: .all)
        }
    }
    
    private func getLocalTimenotes(of type: TimenoteFeedType, completion: @escaping (TimenotesLocalData?) -> Void) {
        let timenotes = realm.object(ofType: TimenotesLocalData.self, forPrimaryKey: type.rawValue)
        completion(timenotes)
    }
    
    public func removeLocalSaves(for type: TimenoteFeedType) {
        getLocalTimenotes(of: type) { [weak self] timenotes in
            guard let timenotes = timenotes else { return }
            try! self?.realm.write {
                self?.realm.delete(timenotes)
            }
        }
    }
    
    // MARK: Timenotes Feed
    
    public func getTimenoteFeedPast(offset: Int, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        DispatchQueue.main.async {
            self.getLocalTimenotes(of: .feedPast) { timenotesLocal in
                if let timenotes = timenotesLocal?.timenotes {
                    completion(.success(timenotes))
                }
            }
        }
        self.getDataTask(WebService.Consts.TimenoteFeedPasWSURL.appendingPathComponent("\(offset)"), requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard let timenotes = timenotes else { return completion(.failure(.serverError))}
            completion(.success(timenotes))
            if offset == 0 {
                self.removeLocalSaves(for: .feedPast)
            }
            DispatchQueue.main.async { [weak self] in
                self?.saveTimenoteToDatabase(timenotes: timenotes, of: .feedPast)
            }
        }
    }

    public func getTimenoteFeedFuture(offset: Int, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        DispatchQueue.main.async {
            self.getLocalTimenotes(of: .feedFuture) { timenotesLocal in
                if let timenotes = timenotesLocal?.timenotes {
                    completion(.success(timenotes))
                }
            }
        }
        self.getDataTask(WebService.Consts.TimenoteFeedUpcomingWSURL.appendingPathComponent("\(offset)"), requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard let timenotes = timenotes else { return completion(.failure(.serverError))}
            completion(.success(timenotes))
            if offset == 0 {
                self.removeLocalSaves(for: .feedFuture)
            }
            DispatchQueue.main.async { [weak self] in
                self?.saveTimenoteToDatabase(timenotes: timenotes, of: .feedFuture)
            }
        }
    }
    
    public func getTimenoteRecent(offset: Int, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        DispatchQueue.main.async {
            self.getLocalTimenotes(of: .recent) { timenotesLocal in
                if let timenotes = timenotesLocal?.timenotes {
                    completion(.success(timenotes))
                }
            }
        }
        self.getDataTask(WebService.Consts.TimenoteRecentWSURL.appendingPathComponent("\(offset)"), requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard let timenotes = timenotes else { return completion(.failure(.serverError))}
            completion(.success(timenotes))
            if offset == 0 {
                self.removeLocalSaves(for: .recent)
            }
            DispatchQueue.main.async { [weak self] in
                self?.saveTimenoteToDatabase(timenotes: timenotes, of: .recent)
            }
        }
    }
    
    public func getTimenoteSearch(offset: Int, tag: String, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.TimenoteSearchWSURL.appendingPathComponent("\(tag)/\(offset)"), requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard let timenotes = timenotes else { return completion(.failure(.serverError))}
            completion(.success(timenotes))
        }
    }
    
    public func getTimenoteZone(offset: Int, filter: FilterNearbyDto, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        DispatchQueue.main.async {
            self.getLocalTimenotes(of: .zone) { timenotesLocal in
                if let timenotes = timenotesLocal?.timenotes {
                    completion(.success(timenotes))
                }
            }
        }
        var nearbyOption = filter
        nearbyOption.userID = UserManager.shared.userInformation?.id
        let body = try! self.encoder.encode(nearbyOption)
        self.postDataTask(WebService.Consts.NearnyWSURL.appendingPathComponent("\(offset)"), body: body) { (timenotes: [TimenoteDataDto]?, response) in
            guard let timenotes = timenotes else { return completion(.failure(.serverError))}
            completion(.success(timenotes))
            if offset == 0 {
                self.removeLocalSaves(for: .zone)
            }
            DispatchQueue.main.async { [weak self] in
                self?.saveTimenoteToDatabase(timenotes: timenotes, of: .zone)
            }
        }
    }
    
    public func getUserFuturTimenote(userId: String, offset: Int, showAlert: Bool? = nil, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        let isCurrentUser = userId == UserManager.shared.userInformation?.id
        if isCurrentUser {
            DispatchQueue.main.async {
                self.getLocalTimenotes(of: .userFutur) { timenotesLocal in
                    if let timenotes = timenotesLocal?.timenotes {
                        completion(.success(timenotes))
                    }
                }
            }
        }
        self.getDataTask(WebService.Consts.ProfilWSURL.appendingPathComponent("\(userId)/upcoming/\(offset)"), requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard var timenotes = timenotes else { return completion(.failure(.serverError))}

            if UserManager.shared.isSynchronizationEnabled && isCurrentUser {
                self.loadFutureTimenotesFromGoogle(offset: offset, showAlert: showAlert) { events in
                    events.forEach {
                        timenotes.append($0)
                    }
                    completion(.success(timenotes))
                    if offset == 0 {
                        self.removeLocalSaves(for: .userFutur)
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.saveTimenoteToDatabase(timenotes: timenotes, of: .userFutur)
                    }
                }
                return
            }
            completion(.success(timenotes))
            if offset == 0 && isCurrentUser {
                self.removeLocalSaves(for: .userFutur)
            }
            if isCurrentUser {
                DispatchQueue.main.async { [weak self] in
                    self?.saveTimenoteToDatabase(timenotes: timenotes, of: .userFutur)
                }
            }
        }
    }
    
    
    public func getUserPastTimenote(userId: String, offset: Int, showAlert: Bool? = nil, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        let isCurrentUser = userId == UserManager.shared.userInformation?.id
        if isCurrentUser {
            DispatchQueue.main.async {
                self.getLocalTimenotes(of: .userPast) { timenotesLocal in
                    if let timenotes = timenotesLocal?.timenotes {
                        completion(.success(timenotes))
                    }
                }
            }
        }
        self.getDataTask(WebService.Consts.ProfilWSURL.appendingPathComponent("\(userId)/past/\(offset)"), requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard var timenotes = timenotes else { return completion(.failure(.serverError))}
            
            if UserManager.shared.isSynchronizationEnabled && isCurrentUser {
                self.loadPastTimenotesFromGoogle(offset: offset, showAlert: showAlert) { events in
                    events.forEach {
                        timenotes.append($0)
                    }
                    completion(.success(timenotes))
                    if offset == 0 {
                        self.removeLocalSaves(for: .userPast)
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.saveTimenoteToDatabase(timenotes: timenotes, of: .userPast)
                    }
                }
            }
            completion(.success(timenotes))
            if offset == 0 && isCurrentUser {
                self.removeLocalSaves(for: .userPast)
            }
            if isCurrentUser {
                DispatchQueue.main.async { [weak self] in
                    self?.saveTimenoteToDatabase(timenotes: timenotes, of: .userPast)
                }
            }
        }
    }
    
    public func getUserFilteredTimenote(filterDataDto: FilterProfileDto, offset: Int, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(filterDataDto)
        self.postDataTask(WebService.Consts.ProfilTimenoteFilteredWSURL.appendingPathComponent("\(offset)"), body: body, requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard let timenotes = timenotes else { return completion(.failure(.serverError))}
            completion(.success(timenotes))
        }
    }
    
    public func getTimenoteById(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.TimenoteParticipantWSURL.appendingPathComponent(timenoteId), requiresAuthentication: true) { (timenote: TimenoteDataDto?, response) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    // MARK: Timenotes from Google Calendar
    
    private func loadFutureTimenotesFromGoogle(offset: Int, showAlert: Bool? = nil, completion: @escaping ([TimenoteDataDto]) -> Void) {
        var results: [TimenoteDataDto] = []
        loadTimenotesFromGoogleCalendar(offset: offset, showAlert: showAlert) { timenotes in
            timenotes.forEach {
                if $0.startingDate ?? Date() >= Date() || $0.endingDate ?? Date() >= Date() {
                    results.append($0)
                }
            }
            completion(results)
        }
    }
    
    private func loadPastTimenotesFromGoogle(offset: Int, showAlert: Bool? = nil, completion: @escaping ([TimenoteDataDto]) -> Void) {
        var results: [TimenoteDataDto] = []
        loadTimenotesFromGoogleCalendar(offset: offset, showAlert: showAlert) { timenotes in
            timenotes.forEach {
                if $0.startingDate ?? Date() < Date() && $0.endingDate ?? Date() < Date() {
                    results.append($0)
                }
            }
            completion(results)
        }
    }
    
    private func loadTimenotesFromGoogleCalendar(offset: Int, showAlert show: Bool? = nil, completion: @escaping ([TimenoteDataDto]) -> Void) {
        var showAlert = show
        fetchCalendarService { [weak self] calendarService in
            guard let calendarService = calendarService else { return }
            self?.fetchGoogleEvents(with: GIDSignIn.sharedInstance.currentUser?.profile?.email ?? "-",
                                    service: calendarService) { items in
                var timenotes: [TimenoteDataDto] = []
                items.forEach {
                    guard let timenote = self?.fetchTimenote(from: $0) else { return }
                    timenote.title != "" ? timenotes.append(timenote) : ()
                }
                if self?.loadedGoogleEventsCount != 0 &&
                    self?.loadedGoogleEventsCount != timenotes.count {
                    showAlert = true
                }
                if items.count != timenotes.count {
                    AlertManager.shared.showGoogleMissedEvents(numberOfImportedEvents: timenotes.count, totalNumberOfEvents: items.count, offset: offset, showAgain: showAlert)
                }
                completion(timenotes)
                self?.loadedGoogleEventsCount = timenotes.count
            }
        }
    }
    
    private func fetchTimenote(from event: GTLRCalendar_Event) -> TimenoteDataDto {
        let startingAt: String = event.start?.dateTime?.stringValue ?? event.start?.date?.stringValue ?? ""
        let endingAt: String = event.end?.dateTime?.stringValue ?? event.end?.date?.stringValue ?? ""
        let timenote = TimenoteDataDto(id: event.identifier ?? "",
                                           createdAt: fetchRightDate(for: event.created?.stringValue),
                                           createdBy: UserManager.shared.userInformation!,
                                           orginzers: nil,
                                           title: event.summary ?? "",
                                           description: event.descriptionProperty?.htmlToText(),
                                           pictures: ["https://timenote-dev-images.s3.eu-west-3.amazonaws.com/timenote/toDL.jpg"],
                                           colorHex: event.colorId,
                                           location: UserLocationDto(longitude: 0, latitude: 0, address: UserAddressDto(address: "", zipCode: "", city: "", country: "")),
                                           stringLocation: event.location,
                                           category: nil,
                                           startingAt: fetchRightDate(for: startingAt),
                                           endingAt: fetchRightDate(for: endingAt),
                                           hashtags: [],
                                           urlTitle: nil,
                                           url: nil,
                                           price: nil,
                                           likedBy: 0,
                                           joinedBy: nil,
                                           comments: 0,
                                           participating: true)
        return timenote
    }
    
    private func fetchRightDate(for stringDate: String?) -> String {
        guard let stringDate = stringDate else { return "" }
        let dateFormatter = DateFormatter()
        var finalDate = Date()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let date = dateFormatter.date(from: stringDate)
        if let date = date {
            finalDate = date
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: stringDate) else { return "" }
            finalDate = date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let result = dateFormatter.string(from: finalDate)
        return result
    }
    
    private func fetchCalendarService(completion: @escaping (GTLRCalendarService?) -> Void) {
        let service = calendarService
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else { return }
        
        currentUser.authentication.do { authentification, error in
            guard error == nil,
                  let authentification = authentification
            else { return }
                        
            let autorizer = authentification.fetcherAuthorizer()
            service?.authorizer = autorizer
            completion(service)
        }
    }
    
    private func fetchGoogleEvents(with calendarID: String,
                     service: GTLRCalendarService,
                     completion: @escaping ([GTLRCalendar_Event]) -> Void) {
        let batch = GTLRBatchQuery()
        
        let eventsQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarID)
        eventsQuery.completionBlock = { callbackTicket, events, callbackError in
            guard let items = (events as? GTLRCalendar_Events)?.items else { return }
            completion(items)
        }
        batch.addQuery(eventsQuery)
        
        service.executeQuery(batch)
    }

    // MARK: Timenotes Interactions
    
    public func likeTimenote(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.TimenoteLikeWSURL.appendingPathComponent(timenoteId), body: nil, requiresAuthentication: true) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }

    public func dislikeTimenote(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.TimenoteDislikeWSURL.appendingPathComponent(timenoteId), body: nil, requiresAuthentication: true) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    public func joinTimenote(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.TimenoteJoinWSURL.appendingPathComponent(timenoteId), body: nil, requiresAuthentication: true) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    public func leaveTimenote(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.TimenoteLeaveWSURL.appendingPathComponent(timenoteId), body: nil, requiresAuthentication: true) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    public func hideTimenote(timenoteInfo: HideTimenoteDto, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        let request = WebService.Consts.HideTimenoteAndUserWSURL
        let body = try! self.encoder.encode(timenoteInfo)
        self.postDataTask(request, body: body, requiresAuthentication: true, isGoogleApi: false) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError)) }
            completion(.success(timenote))
        }
    }
    
    public func hideAllTimenotesFromUser(timenoteInfo: HideTimenoteDto, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        let request = WebService.Consts.HideTimenoteAndUserWSURL
        let body = try! self.encoder.encode(timenoteInfo)
        self.postDataTask(request, body: body, requiresAuthentication: true, isGoogleApi: false) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError)) }
            completion(.success(timenote))
        }
    }
    
    public func joinPrivateTimenote(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.TimenoteJoinPrivateWSURL.appendingPathComponent(timenoteId), body: nil, requiresAuthentication: true) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    public func getTimenoteParticipant(timenoteId: String, offset: Int, completion: @escaping(Result<[UserResponseDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.TimenoteParticipantWSURL.appendingPathComponent("\(timenoteId)/users/\(offset)"), requiresAuthentication: true) { (users: [UserResponseDto]?, response) in
            guard let users = users else { return completion(.failure(.serverError)) }
            completion(.success(users))
        }
    }
    
    public func deleteTimenote(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.TimenoteParticipantWSURL.appendingPathComponent(timenoteId), body: nil, requiresAuthentication: true) { (timenote: TimenoteDataDto?, reponse) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    public func shareTimenote(shareDto: ShareTimenoteDto, completion: @escaping(Result<Bool, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(shareDto)
        self.postDataTask(WebService.Consts.TimenoteShareWSURL, body: body, requiresAuthentication: true) { (noData: Bool?, response) in
            guard response.statusCode == 201 else { return completion(.success(false))}
            return completion(.success(true))
        }
    }
    
    // MARK: SIGNALEMENT
    
    public func signalTimenote(signalementDto: CreateSignalementDto, completion: @escaping(Result<SignalementDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(signalementDto)
        self.postDataTask(WebService.Consts.TimenoteSignalementWSURL, body: body, requiresAuthentication: true) { (signalement: SignalementDto?, response) in
            guard let signalement = signalement else { return completion(.failure(.serverError))}
            completion(.success(signalement))
        }
    }
    
    public func deleteSignalTimenote(timenoteId: String, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.TimenoteSignalementWSURL.appendingPathComponent(timenoteId), body: nil, requiresAuthentication: true) { (timenote: TimenoteDataDto?, response) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    // MARK: Comments
    
    public func getTimenoteComments(timenoteId: String, offset: Int,  completion: @escaping(Result<[TimenoteCommentDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.TimenoteCommentsWSURL.appendingPathComponent("\(timenoteId)/\(offset)"), requiresAuthentication: true, completion: { (comments: [TimenoteCommentDto]?, response) in
            guard let comments = comments else { return completion(.failure(.serverError))}
            completion(.success(comments))
        })
    }
    
    public func createTimenoteComment(timenoteComment: TimenoteCreateDto, completion: @escaping(Result<TimenoteCommentDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(timenoteComment)
        self.postDataTask(WebService.Consts.TimenoteCommentsCreateWSURL, body: body, requiresAuthentication: true) { (timenoteComment: TimenoteCommentDto?, response) in
            guard let timenoteComment = timenoteComment else { return completion(.failure(.serverError))}
            completion(.success(timenoteComment))
        }
    }
    
    public func likeTimenoteComment(commentId: String, completion: @escaping(Result<TimenoteCommentDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.TimenoteCommentsLikeWSURL.appendingPathComponent(commentId), body: nil, requiresAuthentication: true) { (timenoteComment: TimenoteCommentDto?, response) in
            guard let timenoteComment = timenoteComment else { return completion(.failure(.serverError))}
            completion(.success(timenoteComment))
        }
    }
    
    public func dislikeTimenoteComment(commentId: String, completion: @escaping(Result<TimenoteCommentDto, WebServiceError>) -> Void) {
        self.putDataTask(WebService.Consts.TimenoteCommentsDislikeWSURL.appendingPathComponent(commentId), body: nil, requiresAuthentication: true) { (timenoteComment: TimenoteCommentDto?, response) in
            guard let timenoteComment = timenoteComment else { return completion(.failure(.serverError))}
            completion(.success(timenoteComment))
        }
    }
    
    public func updateTimenoteComment(commentId: String, commentData: TimenoteCreateDto, completion: @escaping(Result<TimenoteCommentDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(commentData)
        self.patchDataTask(WebService.Consts.TimenoteCommentsUpdateWSURL, body: body, requiresAuthentication: true) { (timenoteComment: TimenoteCommentDto?, response) in
            guard let timenoteComment = timenoteComment else { return completion(.failure(.serverError))}
            completion(.success(timenoteComment))
        }
    }
    
    public func deleteTimenoteComment(commentId: String, completion: @escaping(Result<TimenoteCommentDto, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.TimenoteCommentsDeleteWSURL.appendingPathComponent(commentId), body: nil) { (timenoteComment: TimenoteCommentDto?, response) in
            guard let timenoteComment = timenoteComment else { return completion(.failure(.serverError))}
            completion(.success(timenoteComment))
        }
    }
    
    // MARK: ALARM
    
    public func createAlarm(alarm: CreateAlarmDto, completion: @escaping(Result<AlarmDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(alarm)
        self.postDataTask(WebService.Consts.TimenoteAlarmWSURL.appendingPathComponent("create"), body: body, requiresAuthentication: true) { (alarm: AlarmDto?, response) in
            guard let alarm = alarm else { return completion(.failure(.serverError))}
            completion(.success(alarm))
        }
    }
    
    public func getAlarm(completion: @escaping(Result<[AlarmDto], WebServiceError>) -> Void) {
        self.getDataTask(WebService.Consts.TimenoteAlarmWSURL.appendingPathComponent("me"), requiresAuthentication: true) { (alarms: [AlarmDto]?, response) in
            guard let alarms = alarms else { return completion(.failure(.serverError))}
            completion(.success(alarms))
        }
    }
    
    public func updateAlarm(alarmDto: CreateAlarmDto, timenoteId: String, completion: @escaping(Result<AlarmDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(alarmDto)
        self.putDataTask(WebService.Consts.TimenoteAlarmWSURL.appendingPathComponent("update/\(timenoteId)"), body: body, requiresAuthentication: true) { (alarm: AlarmDto?, response) in
            guard let alarm = alarm else { return completion(.failure(.serverError))}
            completion(.success(alarm))
        }
    }
    
    public func deleteAlarm(alarmId: String, completion: @escaping(Result<AlarmDto, WebServiceError>) -> Void) {
        self.deleteDataTask(WebService.Consts.TimenoteAlarmWSURL.appendingPathComponent("delete/\(alarmId)"), body: nil, requiresAuthentication: true) { (alarm: AlarmDto?, response) in
            guard let alarm = alarm else { return completion(.failure(.serverError))}
            completion(.success(alarm))
        }
    }
    
    // MARK: Notifications
    
    /// Determine does user have unread notifications.
    /// - Parameter completion: returns `True` when user have unread notifications.
    public func isUnreadNotifications(completion: @escaping (Bool) -> Void ) {
        let request = WebService.Consts.NotificationWSURL.appendingPathComponent("/\(UserManager.shared.userInformation?.id ?? "")/unreadNotif")
        self.getDataTask(request, requiresAuthentication: true) { (result: Bool?, response) in
            guard let result = result else {
                completion(false)
                return
            }
            completion(result)
        }
    }
    
    public func getNotifications(offset: Int, completion: @escaping ([NotificationTimenote]) -> Void) {
        let userID = UserManager.shared.userInformation?.id ?? ""
        let request = WebService.Consts.NotificationWSURL.appendingPathComponent("/\(userID)/notifications/\(offset)")
        self.getDataTask(request, requiresAuthentication: true) { (result: [NotificationTimenote]?, response) in
            guard let notifications = result else { return }
            completion(notifications)
        }
    }
    
    public func removeNotification(with id: String, completion: ((Result<Bool, WebServiceError>) -> Void)? = nil) {
        let request = WebService.Consts.NotificationWSURL.appendingPathComponent("/\(id)")
        self.deleteDataTask(request, body: nil, requiresAuthentication: true) { (noData: Bool?, response) in
            guard let completion = completion else { return }
            guard response.statusCode == 200 else { return completion(.failure(.serverError))}
            completion(.success(true))
        }
    }
    
    //MARK: Timenote
    
    public func createTimenote(timenoteDTO: CreateTimenoteDto, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(timenoteDTO)
        self.postDataTask(WebService.Consts.TimenoteParticipantWSURL, body: body, requiresAuthentication: true) { (timenote: TimenoteDataDto?, response) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    public func updateTimenote(timenoteId: String, timenoteDTO: CreateTimenoteDto, completion: @escaping(Result<TimenoteDataDto, WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(timenoteDTO)
        self.patchDataTask(WebService.Consts.TimenoteParticipantWSURL.appendingPathComponent(timenoteId), body: body, requiresAuthentication: true) { (timenote: TimenoteDataDto?, response) in
            guard let timenote = timenote else { return completion(.failure(.serverError))}
            completion(.success(timenote))
        }
    }
    
    public func getTimenoteByDate(userId: String, dateDto: CalendarDateDto, completion: @escaping(Result<[TimenoteDataDto], WebServiceError>) -> Void) {
        let body = try! self.encoder.encode(dateDto)
        self.postDataTask(WebService.Consts.ProfilWSURL.appendingPathComponent("\(userId)/timenotes/date"), body: body, requiresAuthentication: true) { (timenotes: [TimenoteDataDto]?, response) in
            guard let timenotes = timenotes else { return completion(.failure(.serverError))}
            completion(.success(timenotes))
        }
    }
    
    /* CORE CLASS WS FUNCTIONS */
    // MARK: Core Function
    
    public func initAuthenticatedSession(with authorizationHeader: String, refresh: String? = nil) {
        defaultURLSessionConfiguration.httpAdditionalHeaders?[Consts.AuthorizationHeader] = authorizationHeader
        if let refresh = refresh {
            defaultURLSessionConfiguration.httpAdditionalHeaders?[Consts.RefreshHeader] = refresh
        }
        authenticatedSession = URLSession(configuration: defaultURLSessionConfiguration, delegate: nil, delegateQueue: .main)
    }
    
    private func getDataTask<T: Decodable>(_ URL: URL, requiresAuthentication: Bool = false, isGoogleApi : Bool = false, completion: @escaping (T?, WebServiceResponse) -> Void) {
        dataTask(URL, body: nil, httpMethod: "GET", requiresAuthentication: requiresAuthentication, completion: completion)
    }
    
    private func postDataTask<T: Decodable>(_ URL: URL, body: Data?, requiresAuthentication: Bool = false, isGoogleApi : Bool = false, completion: @escaping (T?, WebServiceResponse) -> Void) {
        dataTask(URL, body: body, httpMethod: "POST", requiresAuthentication: requiresAuthentication, completion: completion)
    }
    
    private func putDataTask<T: Decodable>(_ URL: URL, body: Data?, requiresAuthentication: Bool = false, isGoogleApi : Bool = false, completion: @escaping (T?, WebServiceResponse) -> Void) {
        dataTask(URL, body: body, httpMethod: "PUT", requiresAuthentication: requiresAuthentication, completion: completion)
    }
    
    private func patchDataTask<T: Decodable>(_ URL: URL, body: Data?, requiresAuthentication: Bool = false, isGoogleApi : Bool = false, completion: @escaping (T?, WebServiceResponse) -> Void) {
        dataTask(URL, body: body, httpMethod: "PATCH", requiresAuthentication: requiresAuthentication, completion: completion)
    }
    
    private func deleteDataTask<T: Decodable>(_ URL: URL, body: Data?, requiresAuthentication: Bool = true, isGoogleApi : Bool = false, completion: @escaping (T?, WebServiceResponse) -> Void) {
        dataTask(URL, body: body, httpMethod: "DELETE", requiresAuthentication: requiresAuthentication, completion: completion)
    }
    
    private func dataTask<T: Decodable>(_ URL: URL, body: Data?, httpMethod: String, requiresAuthentication: Bool, isGoogleApi : Bool = false, completion: @escaping (T?, WebServiceResponse) -> Void) {
        var urlRequest = URLRequest(url: URL)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = body
        process(urlRequest: urlRequest, requiresAuthentication: requiresAuthentication, canRetryOnUnauthorized: true, completion: completion)
    }
    
    private func process<T: Decodable>(urlRequest: URLRequest,
                                       requiresAuthentication: Bool,
                                       isGoogleApi : Bool = false,
                                       canRetryOnUnauthorized: Bool,
                                       completion: @escaping (T?, WebServiceResponse) -> Void) {
        if Consts.LogDebug {
//            print("Calling \(urlRequest)")
//            if let body = urlRequest.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
//                print("with body: \(bodyStr)")
//            }
        }
        let session = isGoogleApi ? googleSession : requiresAuthentication ? authenticatedSession : standardSession
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if Consts.LogDebug {
//                let readableData = String(data: data ?? Data(), encoding: .utf8) ?? "no data"
//                print("Data \(readableData) Response \(String(describing: response)) Error \(String(describing: error))")
            }
            let webServiceResponse = WebServiceResponse(rawData: data, response: response, error: error)
            if error == nil && webServiceResponse.isSuccess, let data = data, webServiceResponse.statusCode != 204 {
                do {
                    let typedData = try self.decoder.decode(T.self, from: data)
                    completion(typedData, webServiceResponse)
                    return
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
            if webServiceResponse.statusCode == 401 && requiresAuthentication && canRetryOnUnauthorized {
                // Token has expired, refreshing
                self.refreshToken { (success, authResponse) in
                    switch authResponse.statusCode {
                    case 200:
                        self.process(urlRequest: urlRequest, requiresAuthentication: requiresAuthentication, canRetryOnUnauthorized: false, completion: completion)
                    case 401:
                        // TODO: The login/password is no longer valid, we need to disconnect the user
                        completion(nil, webServiceResponse)
                        break
                    default:
                        completion(nil, webServiceResponse)
                    }
                }
            }
            completion(nil, webServiceResponse)
        }
        task.resume()
    }
}


class WebServiceResponse : Error {
    let rawData: Data?
    let response: URLResponse?
    let error: Error?
    let statusCode: Int?
    
    var isSuccess: Bool {
        if let statusCode = statusCode, case 200...299 = statusCode {
            return true
        }
        return false
    }
    
    init(rawData: Data?, response: URLResponse?, error: Error?) {
        self.rawData = rawData
        self.response = response
        self.error = error
        statusCode = (response as? HTTPURLResponse)?.statusCode
    }
}
