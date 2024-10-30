//
//  peopleAndOrgs.swift
//  goodMatches
//
//  Created by Yo Sato on 25/10/2024.
//

import Foundation

enum Gender:String,Codable{
    case male="male"
    case female="female"
}

struct Club:Codable,Identifiable,Hashable{
    let name:String
    let organiserUIDs:[String]
    var players:[PlayerInClub]=[]
    var country:String?=nil
    var region:String?=nil
    var alias:String?=nil
    var uid:String?=nil
    var id:String {name+organiserUIDs[0]}
}

protocol RegisteredMember{
    var displayName:String {get}
    var email:String {get}
    var gender:Gender? {get}
    var playerOf:[String] {get set}
}


struct Member:RegisteredMember,Identifiable,Hashable,Equatable,Codable{
    enum CodingKeys:String,CodingKey{
        case displayName
        case email
    }
    static func == (lhs: Member, rhs: Member) -> Bool {
        lhs.id==rhs.id
    }
    
    let displayName:String
    let email:String
    let gender:Gender?=nil
    var uid:String?=nil
    var id:String {displayName+"--"+email}
    var playerOf:[String]=[]
    var organiserOf:[String]=[]
    //var clubIDsJoined:[String]=[]
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }
    
}


class PlayerInClub: Codable, Equatable, Hashable, Identifiable
{
    static func == (lhs: PlayerInClub, rhs: PlayerInClub) -> Bool {
        lhs.id==rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.id)
    }

    enum CodingKeys:String,CodingKey{
        case asMember
//        case name
        case score
//        case gender
        case clubUID
        //case id

    }
    let asMember:Member
//    var name: String
    var score: Double
//    var gender: String
//    var club:Club
    var clubUID:String

    // to be retired
    var name:String {self.asMember.displayName}
    
    var nameLen:Int {asMember.displayName.split(separator:" ").count}
    var nameAbbr:String {asMember.displayName.split(separator:" ")[0].lowercased()+(nameLen>1 ? asMember.displayName.split(separator:" ")[1].capitalized : "")}
//    var clubAbbr:String {club.name.split(separator: " ").map{word in word.prefix(1)}.joined(separator:"")}
    var id:String {nameAbbr+"_"+clubUID}
    var preferencesIntraMS:[(PlayerInClub,MatchSetOnCourt)->Bool]=[]
    var preferencesInterMS:[(PlayerInClub,MatchSetOnCourt,MatchSetOnCourt)->Bool]=[]

    init(asMember:Member,score:Double,clubUID:String){
        self.asMember=asMember; self.score=score; self.clubUID=clubUID
    }
    
    func update_score(_ increment: Double){
        self.score+=increment
    }
}

