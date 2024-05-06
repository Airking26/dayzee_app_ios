//
//  TimenoteManager.swift
//  Timenote
//
//  Created by Aziz Essid on 04/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import Combine
import os.log
import RealmSwift
import Unrealm

class TimenoteManager {
    
    static let shared   : TimenoteManager   = TimenoteManager()
    
    // The number of timenote returned by any webservice to increment current offset
    static let offsetIncrement  : Int           = 12
    
    private(set) var timenoteUpcomingPublisher      = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenotePastPublisher          = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenoteRecentPublisher        = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenoteSearchPublisher        = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenoteParticipantPublisher   = CurrentValueSubject<[UserResponseDto], Never>([])
    private(set) var timenoteCommentsPublisher      = CurrentValueSubject<[TimenoteCommentDto], Never>([])
    private(set) var timenoteNearbyPublisher        = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenotesCalendarPublisher     = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenoteFutureUserPublisher    = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenotePastUserPublisher      = CurrentValueSubject<[TimenoteDataDto], Never>([])
    private(set) var timenoteAlarmsPublisher        = CurrentValueSubject<[AlarmDto], Never>([])
    private(set) var timenoteNearbyOptionPublisher  = CurrentValueSubject<FilterNearbyDto?, Never>(nil)
    private(set) var timenoteLastDuplicate          = CurrentValueSubject<TimenoteDataDto?, Never>(nil)
    private(set) var timenoteDeepLink               = CurrentValueSubject<String?, Never>(nil)
    private(set) var filterProfilePublicher         = CurrentValueSubject<FilterProfileDto?, Never>(nil)
    private(set) var updateTimenoteHomePublicher    = CurrentValueSubject<Bool, Never>(false)
    private(set) var newTimenotePublisher           = CurrentValueSubject<TimenoteDataDto?, Never>(nil)
    
    public          var     futurUserId         : String        = ""
    public          var     pastUserId          : String        = ""
    private         var     searchedTag         : String        = ""
    private(set)    var     firstUpdateFilter   : Bool          = true
    
    init() {
        GoogleLocationManager.shared.getLocationWithUpdate { (place, adresse, errors) in
            guard let _ = place else { return }
            GoogleLocationManager.shared.getUserTimenoteLocation { (userLocation) in
                guard let userLocation = userLocation else { return }
                TimenoteManager.shared.timenoteNearbyOptionPublisher.send(FilterNearbyDto(location: userLocation , maxDistance: NearbyViewController.MaxDistance, categories: [], date: Date().iso8601withFractionalSeconds, price: TimenotePriceDto(value: 0, currency: ""), type: FilterOptionDto.all))
                self.firstUpdateFilter = false
            }
        }
        self.getUserPastTimenote(userId: UserManager.shared.userInformation?.id)
        self.getUserFuturTimenote(userId: UserManager.shared.userInformation?.id)
    }
    
    public func reset() {
        self.futurUserId = ""
        self.pastUserId = ""
        self.searchedTag = ""
        self.firstUpdateFilter = true
    }
    
    public func clearPublishersData() {
        self.timenoteUpcomingPublisher.value = []
        self.filterProfilePublicher.value = nil
        self.timenoteNearbyOptionPublisher.value = nil
        self.timenoteAlarmsPublisher.value = []
        self.timenotePastUserPublisher.value = []
        self.timenoteFutureUserPublisher.value = []
        self.timenotesCalendarPublisher.value = []
        self.timenoteNearbyPublisher.value = []
        self.timenoteCommentsPublisher.value = []
        self.timenoteParticipantPublisher.value = []
        self.timenoteSearchPublisher.value = []
        self.timenoteRecentPublisher.value = []
        self.timenotePastPublisher.value = []
        GoogleLocationManager.shared.getLocationWithUpdate { (place, adresse, errors) in
            guard let _ = place else { return }
            GoogleLocationManager.shared.getUserTimenoteLocation { (userLocation) in
                guard let userLocation = userLocation else { return }
                TimenoteManager.shared.timenoteNearbyOptionPublisher.send(FilterNearbyDto(location: userLocation , maxDistance: NearbyViewController.MaxDistance, categories: [], date: Date().iso8601withFractionalSeconds, price: TimenotePriceDto(value: 0, currency: ""), type: FilterOptionDto.all))
                self.firstUpdateFilter = false
            }
        }
    }
    
    public func getUpcoming(refresh: Bool) {
        let offset = refresh ? 0 : Int((Double(self.timenoteUpcomingPublisher.value.count) / 12.0).rounded(.up))
        WebService.shared.getTimenoteFeedFuture(offset: offset) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving upcoming feed %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if !refresh {
                    timenotes.removeAll(where: {self.timenoteUpcomingPublisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = self.timenoteUpcomingPublisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                self.timenoteUpcomingPublisher.send(timenotes)
                break;
            }
        }
    }
    
    public func getPast(refresh: Bool) {
        let offset = refresh ? 0 : Int((Double(self.timenotePastPublisher.value.count) / 12.0).rounded(.up))
        WebService.shared.getTimenoteFeedPast(offset: offset) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving upcoming feed %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if !refresh {
                    timenotes.removeAll(where: {self.timenotePastPublisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = self.timenotePastPublisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                self.timenotePastPublisher.send(timenotes)
                break;
            }
        }
    }
    
    public func getRecent(refresh: Bool) {
        let offset = refresh ? 0 : self.timenoteRecentPublisher.value.count / 12
        WebService.shared.getTimenoteRecent(offset: offset) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving upcoming feed %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if !refresh {
                    timenotes.removeAll(where: {self.timenoteRecentPublisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = self.timenoteRecentPublisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                self.timenoteRecentPublisher.send(timenotes)
                break;
            }
        }
    }

    public func getByTag(tag: String) {
        guard !tag.isEmpty else { return }
        let offset = tag == self.searchedTag ? self.timenoteSearchPublisher.value.count / 12 : 0
        self.searchedTag = tag
        WebService.shared.getTimenoteSearch(offset: offset, tag: tag) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving upcoming feed %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if offset != 0 {
                    timenotes.removeAll(where: {self.timenoteSearchPublisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = self.timenoteSearchPublisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                self.timenoteSearchPublisher.send(timenotes)
                break;
            }
        }
    }
    
    public func getDateTimenotes(userId: String?, date: Date?) {
        guard let date = date, let userId = userId else { return }
        WebService.shared.getTimenoteByDate(userId: userId, dateDto: CalendarDateDto(from: date.startOfMonth.iso8601withFractionalSeconds, to: date.endOfMonth.iso8601withFractionalSeconds)) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while unfollowing user %{PRIVTE}@", log : OSLog.userManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let timenotes):
                self.timenotesCalendarPublisher.send(timenotes)
                break;
            }
        }
    }
    
    public func likeTimenote(timenoteId: String?, completion: @escaping(_ liked: Bool) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.likeTimenote(timenoteId: timenoteId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while liking timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(_):
                completion(true)
            }
        }
    }
    
    public func dislikeTimenote(timenoteId: String?, completion: @escaping(_ liked: Bool) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.dislikeTimenote(timenoteId: timenoteId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while dislike timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(_):
                completion(true)
            }
        }
    }
    
    public func joinTimenote(timenoteId: String?, completion: @escaping(_ liked: Bool) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.joinTimenote(timenoteId: timenoteId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while dislike timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(let timenote):
                self.updateTimenoteFromPublisher(timenote: timenote)
                if let profilFilters = self.filterProfilePublicher.value {
                    self.getFilteredTimenote(filterData: profilFilters)
                } else {
                    self.getUserFuturTimenote(userId: UserManager.shared.userInformation?.id)
                    self.getUserPastTimenote(userId: UserManager.shared.userInformation?.id)
                }
                completion(true)
            }
        }
    }
    
    public func joinPrivateTimenote(timenoteId: String?, completion: @escaping(_ liked: Bool) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.joinPrivateTimenote(timenoteId: timenoteId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while dislike timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(let timenote):
                self.updateTimenoteFromPublisher(timenote: timenote)
                completion(true)
            }
        }
    }
    
    public func leaveTimenote(timenoteId: String?, completion: @escaping(_ liked: Bool) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.leaveTimenote(timenoteId: timenoteId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while dislike timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(let timenote):
                self.updateTimenoteFromPublisher(timenote: timenote)
                completion(true)
            }
        }
    }
    
    public func hideTimenote(timenoteId: String?) {
        guard let timenoteId = timenoteId,
              let createdBy = UserManager.shared.userInformation?.id
        else { return }
        let timenoteInfo = HideTimenoteDto(createdBy: createdBy, timenote: timenoteId, user: nil)
        WebService.shared.hideTimenote(timenoteInfo: timenoteInfo) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                print("Failed to hide event")
            }
        }
    }
    
    public func hideAllTimenotesFromUser(userId: String?) {
        guard let userId = userId,
              let createdBy = UserManager.shared.userInformation?.id
        else { return }
        let timenoteInfo = HideTimenoteDto(createdBy: createdBy, timenote: nil, user: userId)
        WebService.shared.hideAllTimenotesFromUser(timenoteInfo: timenoteInfo) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                print("Failed to hide events")
            }
        }
    }
    
    public func handleDeepLink(timenoteID id: String, at scene: UIWindowScene) {
        WebService.shared.getTimenoteById(timenoteId: id) { result in
            switch result {
            case .success(let timenote):
                //Open popup with timenote
                let timenoteDetailStoryboard = UIStoryboard(name: "TimenoteDetail", bundle: nil)
                let timenoteDetailVC = timenoteDetailStoryboard.instantiateViewController(identifier: "TimenoteDetailViewController") as? TimenoteDetailViewController
                timenoteDetailVC?.timenote = timenote
                timenoteDetailVC?.modalPresentationStyle = .popover
                
                guard let popupView = timenoteDetailVC else { return }
                
                scene.windows.first?.rootViewController?.present(popupView, animated: true, completion: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    public func getTimenote(timenoteId: String?, completion: @escaping(TimenoteDataDto?) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.getTimenoteById(timenoteId: timenoteId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retriving timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(nil)
                break;
            case .success(let timenote):
                completion(timenote)
            }
        }
    }
    
    public func updateTimenote(timenoteId: String?, timenoteData: CreateTimenoteDto, completion: @escaping(TimenoteDataDto?) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.updateTimenote(timenoteId: timenoteId, timenoteDTO: timenoteData) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while updating timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Une erreure est survenue, veuillez verifier les champs" : "An error has occured please verify your fields", desciption: "")
                completion(nil)
                break;
            case .success(let timenote):
                self.updateTimenoteFromPublisher(timenote: timenote)
                completion(timenote)
            }
        }
    }
    
    private func updateTimenoteFromPublisher(timenote: TimenoteDataDto) {
        var timenotes : [TimenoteDataDto] = []
        timenotes = self.timenoteUpcomingPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenoteUpcomingPublisher.value = timenotes
        
        timenotes = self.timenotePastPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenotePastPublisher.value = timenotes
        
        timenotes = self.timenoteRecentPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenoteRecentPublisher.value = timenotes
        
        timenotes = self.timenoteSearchPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenoteSearchPublisher.value = timenotes
        
        timenotes = self.timenotesCalendarPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenotesCalendarPublisher.value = timenotes
        
        timenotes = self.timenoteNearbyPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenoteNearbyPublisher.value = timenotes
        
        timenotes = self.timenoteFutureUserPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenoteFutureUserPublisher.value = timenotes
        
        timenotes = self.timenotePastUserPublisher.value
        if let index = timenotes.firstIndex(where: {$0.id == timenote.id}) {
            timenotes[index] = timenote
        }
        self.timenotePastUserPublisher.value = timenotes
    }
    
    public func getPaticipant(timenoteId: String?, offset: Int) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.getTimenoteParticipant(timenoteId: timenoteId, offset: offset == 0 ? 0 : offset / 12) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while dislike timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var users):
                if offset != 0 {
                    users.removeAll(where: {self.timenoteParticipantPublisher.value.contains($0)})
                    guard !users.isEmpty else { return }
                    var newUsers = self.timenoteParticipantPublisher.value;
                    newUsers.append(contentsOf: users)
                    users = newUsers
                }
                self.timenoteParticipantPublisher.send(users)
                break;
            }
        }
    }
    
    public func getComments(timenoteId: String?, offset: Int) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.getTimenoteComments(timenoteId: timenoteId, offset: offset == 0 ? 0 : offset / 12) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while dislike timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var comments):
                if offset != 0 {
                    comments.removeAll(where: {self.timenoteCommentsPublisher.value.contains($0)})
                    guard !comments.isEmpty else { return }
                    var newUsers = self.timenoteCommentsPublisher.value;
                    newUsers.append(contentsOf: comments)
                    comments = newUsers
                }
                self.timenoteCommentsPublisher.send(comments)
            }
        }
    }
    
    public func deleteComment(commentId: String?) {
        guard let commentId = commentId else { return }
        WebService.shared.deleteTimenoteComment(commentId: commentId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while deleting timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let comment):
                var comments = self.timenoteCommentsPublisher.value
                comments.removeAll(where: {$0.id == comment.id})
                self.timenoteCommentsPublisher.value = comments
                break;
            }
        }
    }
    
    public func commentTimenote(timenoteId: String?, description: String?, hastags: String?, image: String?, taggedUserNames: [String]) {
        guard let timenoteId = timenoteId else { return }
//        guard let description = description else { return }
        guard let hastags = hastags else { return }
//        guard !hastags.isEmpty || !description.isEmpty else { return }
        WebService.shared.createTimenoteComment(timenoteComment: TimenoteCreateDto(createdBy: UserManager.shared.userInformation!.id, timenote: timenoteId, description: description, hashtags: [hastags], tagged: taggedUserNames, picture: image)) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while commenting timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let comment):
                var comments = self.timenoteCommentsPublisher.value
                comments.insert(comment, at: 0)
                self.timenoteCommentsPublisher.value = comments
                break;
            }
        }
    }
    
    
    
    public func addTimenote(timenote: CreateTimenoteDto, completion: @escaping(TimenoteDataDto?) -> Void) {
        WebService.shared.createTimenote(timenoteDTO: timenote) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while creating timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Une erreure est survenue, veuillez verifier les champs" : "An error has occured please verify your fields", desciption: "")
                completion(nil)
                break;
            case .success(let timenote):
                self.getFilteredTimenote(filterData: self.filterProfilePublicher.value ?? FilterProfileDto(upcoming: true, alarm: false, created: false, joined: false, sharedWith: false), refresh: true)
                completion(timenote)
                break;
            }
        }
    }
    
    public func deleteTimenote(timenoteId: String?, completion: @escaping(Bool) -> Void) {
        guard let timenoteId = timenoteId else { return }
        WebService.shared.deleteTimenote(timenoteId: timenoteId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while creating timenote %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(let timenote):
                self.deleteTimenoteFromPublisher(timenoteId: timenote.id)
                completion(true)
                break;
            }
        }
    }
    
    private func deleteTimenoteFromPublisher(timenoteId: String) {
        var timenotes : [TimenoteDataDto] = []
        timenotes = self.timenoteUpcomingPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenoteUpcomingPublisher.value = timenotes
        
        timenotes = self.timenotePastPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenotePastPublisher.value = timenotes
        
        timenotes = self.timenoteRecentPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenoteRecentPublisher.value = timenotes
        
        timenotes = self.timenoteSearchPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenoteSearchPublisher.value = timenotes
        
        timenotes = self.timenoteNearbyPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenoteNearbyPublisher.value = timenotes
        
        timenotes = self.timenotesCalendarPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenotesCalendarPublisher.value = timenotes
        
        timenotes = self.timenoteFutureUserPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenoteFutureUserPublisher.value = timenotes
        
        timenotes = self.timenotePastUserPublisher.value
        timenotes.removeAll(where: {$0.id == timenoteId})
        self.timenotePastUserPublisher.value = timenotes
    }
    
    public func getNearbyTimenotes(refresh : Bool = false) {
        guard let filterOption = self.timenoteNearbyOptionPublisher.value else { return }
        let offset = refresh ? 0 : self.timenoteNearbyPublisher.value.count / 12
        WebService.shared.getTimenoteZone(offset: offset, filter: filterOption) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving timenote zone %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if offset != 0 {
                    timenotes.removeAll(where: {self.timenoteNearbyPublisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = self.timenoteNearbyPublisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                self.timenoteNearbyPublisher.send(timenotes)
                break;
            }
        }
    }
    
    public func getUserFuturTimenote(userId: String?, showAlert: Bool? = nil) {
        guard let userId = userId else { return }
        let refresh = self.futurUserId != userId || self.filterProfilePublicher.value != nil
        let offset = refresh ? 0 : self.timenoteFutureUserPublisher.value.count / 12
        self.filterProfilePublicher.send(nil)
        WebService.shared.getUserFuturTimenote(userId: userId, offset: offset, showAlert: showAlert) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user timenote futur %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if offset != 0 {
                    timenotes.removeAll(where: {self.timenoteFutureUserPublisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = self.timenoteFutureUserPublisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                self.futurUserId = userId
                self.timenoteFutureUserPublisher.send(timenotes)
                break;
            }
        }
    }
    
    public func getUserPastTimenote(userId: String?, showAlert: Bool? = nil) {
        guard let userId = userId else { return }
        let refresh = self.pastUserId != userId || self.filterProfilePublicher.value != nil
        let offset = refresh ? 0 : self.timenotePastUserPublisher.value.count / 12
        self.filterProfilePublicher.send(nil)
        WebService.shared.getUserPastTimenote(userId: userId, offset: offset, showAlert: showAlert) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user timenote past %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if offset != 0 {
                    timenotes.removeAll(where: {self.timenotePastUserPublisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = self.timenotePastUserPublisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                self.pastUserId = userId
                self.timenotePastUserPublisher.send(timenotes)
                break;
            }
        }
    }
    
    public func getFilteredTimenote(filterData: FilterProfileDto, refresh : Bool = false) {
        guard filterData.hasNoFilter else {
            if filterData.upcoming {
                self.getUserFuturTimenote(userId: UserManager.shared.userInformation?.id)
            } else {
                self.getUserPastTimenote(userId: UserManager.shared.userInformation?.id)
            }
            return
        }
        let publisher = filterData.upcoming ? self.timenoteFutureUserPublisher : self.timenotePastUserPublisher
        let offset = refresh || self.filterProfilePublicher.value == filterData ? publisher.value.count / 12 : 0
        self.filterProfilePublicher.send(filterData)
        WebService.shared.getUserFilteredTimenote(filterDataDto: filterData, offset: offset) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user timenote filtered %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(var timenotes):
                if offset != 0 {
                    timenotes.removeAll(where: {publisher.value.contains($0)})
                    guard !timenotes.isEmpty else { return }
                    var newTimenotes = publisher.value;
                    newTimenotes.append(contentsOf: timenotes)
                    timenotes = newTimenotes
                }
                if filterData.upcoming {
                    self.futurUserId = UserManager.shared.userInformation?.id ?? ""
                } else {
                    self.pastUserId = UserManager.shared.userInformation?.id ?? ""
                }
                publisher.send(timenotes)
                break;
            }
        }
    }
    
    
    // MARK: Alarm
    
    public func createAlarm(timenodId: String?, userId: String?, date: Date?, completion: @escaping(Bool) -> Void) {
        guard var date = date, date > Date() else {
            completion(false)
            return AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Vous ne pouvez pas ajouter une alarme sur un Dayzee passé" : "You can't add a reminder on a past Dayzee", desciption: "")
        }
        guard let timenodId = timenodId, let userId = userId else {
            completion(false)
            return
        }
        date = date.byLessMinutes(minutes: 10)
        WebService.shared.createAlarm(alarm: CreateAlarmDto(createdBy: userId, timenote: timenodId, date: date.iso8601withFractionalSeconds)) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while adding user timenote alarms %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                completion(false)
                break;
            case .success(let alarm):
                var newAlarms = self.timenoteAlarmsPublisher.value;
                newAlarms.append(alarm)
                AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Vous avez ajouté une nouvelle alarme, elle se déclenchera 10 minutes avant le début du Dayzee" : "You have added a new reminder, it will launch 10 minutes before the Dayzee starts", desciption: "", isBlue: true)
                self.timenoteAlarmsPublisher.send(newAlarms)
                completion(true)
                break;
            }
        }
    }
    
    public func getAlarm() {
        WebService.shared.getAlarm { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while retreiving user timenote alarms %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let alarms):
                self.timenoteAlarmsPublisher.send(alarms)
                break;
            }
        }
    }
    
    public func hasAlarm(timenoteId: String?) -> Bool {
        guard let timenoteId = timenoteId else { return false }
        return self.timenoteAlarmsPublisher.value.first(where: {$0.timenote == timenoteId}) != nil
    }
    
    public func deleteAlarm(timenoteId: String?) {
        guard let timenoteId = timenoteId else { return }
        guard let alarmId = self.timenoteAlarmsPublisher.value.first(where: {$0.timenote == timenoteId})?.id else { return }
        WebService.shared.deleteAlarm(alarmId: alarmId) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while adding user timenote alarms %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(let alarm):
                var newAlarms = self.timenoteAlarmsPublisher.value;
                newAlarms.removeAll(where: {$0.id == alarm.id})
                self.timenoteAlarmsPublisher.send(newAlarms)
                break;
            }
        }
    }
    
    // MARK: Signalement
    
    public func signalTimenote(timenodId: String?, userId: String?, description: String?) {
        guard let timenodId = timenodId, let userId = userId, let description = description else { return }
        WebService.shared.signalTimenote(signalementDto: CreateSignalementDto(createdBy: userId, timenote: timenodId, description: description)) { (result) in
            switch result {
            case .failure(let errorDescription):
                os_log("Error while adding user timenote alarms %{PRIVTE}@", log : OSLog.timenoteManager, type : .error, errorDescription.rawValue)
                break;
            case .success(_):
                AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Votre signalement à bien été pris en compte." : "Your report has successfully been sent", desciption: "", isBlue: true)
                break;
            }
        }
    }
}
