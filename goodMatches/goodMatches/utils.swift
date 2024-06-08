//
//  utils.swift
//  goodMatches
//
//  Created by Yo Sato on 29/02/2024.
//

import Foundation
import SwiftUI
import Iterators
import Network


//@Observable
final class NetworkMonitor: ObservableObject {
    @Published var isConnected = false
    @Published var reachable = false
    
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: workerQueue)
    }
    
    func checkConnection(urlString:String) {
    if let url = URL(string: urlString) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        URLSession(configuration: .default)
          .dataTask(with: request) { (_, response, error) -> Void in
            guard error == nil else {
              print("Error:", error ?? "")
              return
            }

            guard (response as? HTTPURLResponse)?
              .statusCode == 200 else {
                print("down")

                return
            }

              self.reachable=true
            
          }
          .resume()
      }
    }

}


func verifyUrl (urlString: String) -> Bool {
    if let url = URL(string: urlString) {
        var result: Bool!
        
        let semaphore = DispatchSemaphore(value: 0)  //1. create a counting semaphore
        
        let session = URLSession.shared
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            result = true  //or false in case
            semaphore.signal()  //3. count it up
        }).resume()
        
        semaphore.wait()  //2. wait for finished counting
        
        return result
    }
    
    return false
}
    
func sum<T:Numeric>(_ aList:[T])-> T{
    aList.reduce(0){$0+$1}
}

func stddev(nums:[Double],mean:Double)-> Double{
    let n=Double(nums.count)
    return sqrt(nums.map{pow($0-mean,2)/n}.reduce(0){$0+$1})
}

func combos<T:Hashable>(elements: ArraySlice<T>, k: Int) -> [[T]] {
    if k == 0 {
        return [[]]
    }

    guard let first = elements.first else {
        return []
    }
    
    let head = [first]
    let subcombos = combos(elements: elements, k: k - 1)
    var ret = subcombos.map { head + $0 }
    let cand=combos(elements: elements.dropFirst(), k: k)
    if(cand.isDistinct()){
        ret += cand
    }
    return ret
}
func combos<T:Hashable>(elements: Array<T>, k: Int) -> [[T]] {
    return combos(elements: ArraySlice(elements), k: k).filter{$0.isDistinct()}
}

func no_duplicate_p<T:Hashable>(_ anArray:Array<T>)-> Bool{
    anArray.count==Set(anArray).count
}

func duplicate_exists_inList<T:Equatable>(_ myList:[T], elementCheck:Bool=false)->Bool{
    for (idx,el) in myList.enumerated(){
        var others=myList[0..<idx]+myList[idx+1..<myList.count]
        
        if others.contains(el){
            return true
        }
    }
    return false
}

func product<U>(_ lhs: [U], _ rhs: [U]) -> [[U]] {
    lhs.flatMap { left in
        rhs.map { right in
            [left, right]
        }
    }
}

func product<U>(_ lhs: [[U]], _ rhs: [U]) -> [[U]] {
    lhs.flatMap { left in
        rhs.map { right in
            left+[right]
        }
    }
}

func product1<U>(_ lhs: [U], _ rhs: [U]) -> [[U]] {
    lhs.flatMap { left in
        rhs.map { right in
            [left]+[right]
        }
    }
}

func product2<U>(_ lhs:[[U]], _ rhs:[[U]])->[[U]]{
    var myProduct=[[U]]()
    for lel in lhs{
        for rel in rhs{
            myProduct.append(lel+rel)
        }
    }
    return myProduct
}

func generalised_product<U>(_ setOfSets:[[U]])-> [[U]]{
    var current=[[U]]()
    var previous=[[U]]()
    
    for (cntr,aSet) in setOfSets.enumerated(){
        current=aSet.map{[$0]}
        if cntr != 0{
            current=product2(previous,current)
        }
        previous=current
    }
//    let myProduct=rest.reduce(initial){product1($0,$1)}
    
    assert(current.count==setOfSets.map{$0.count}.reduce(1){$0*$1})

    return current
}

func intDict2weightDict<T:Hashable>(_ intDict:[T:Int])-> [T:Double]{
    let intSum=intDict.values.reduce(0,+)
    return intDict.mapValues{ value in Double(value)/Double(intSum) }
}


extension Sequence where Element: Hashable {

    /// Returns true if no element is equal to any other element.
    func isDistinct() -> Bool {
        var set = Set<Element>()
        for e in self {
            if set.insert(e).inserted == false { return false }
        }
        return true
    }
}

func isDisjoint<T:Hashable>(_ array1:[T],_ array2:[T])-> Bool{
    return Set(array1).intersection(Set(array2)).isEmpty
}

func all_disjoint<T:Hashable>(_ arrayOfArrays:[[T]])->Bool{
    if arrayOfArrays.count<=1{return true}
    var prevArray=arrayOfArrays[0]
    for anArray in arrayOfArrays[1...]{
        if !isDisjoint(anArray,prevArray){
            return false
        }
        prevArray=anArray
    }
    return true
}

func mean_interval(_ ints:[Int])-> Double{
    var diffSum=0
    var prevInt=ints[0]
    for int in ints[1...]{
        diffSum+=int-prevInt
        prevInt=int
    }
    return Double(diffSum)/Double(ints.count-1)
}

enum MatchError:Error{
    case DuplicateError
}

func get_zipped_sequences_fromDictWithListVals<T,U>(aDict: [T:[U]])-> [U]{
    var zippedSeqs=[U]()
    let maxlen=aDict.values.map{$0.count}.max()!
    
    for n in 0..<maxlen{
        for matchSets in aDict.values{
            if n>=matchSets.count{continue}
            zippedSeqs.append(matchSets[n])
        }
    }
    return zippedSeqs
}

func get_repetition_counts<T:Hashable>(_ anArray:[T])->[T:Int]{
    var dictToReturn=[T:Int]()
    for el in anArray{
        if dictToReturn.keys.contains(el){
            dictToReturn[el]!+=1
        }else{dictToReturn[el]=1}
    }
    return dictToReturn
}

func count_intpartitions(_ ints:[Int])->Int{
    let repetitions=get_repetition_counts(ints)
    var dupCount:Int=1
    for (_, count) in repetitions{
        if count>=2{
            dupCount*=factorial(count)
        }
    }
    var n=sum(ints)
    var count=1
    for int in ints[0..<ints.count-1]{
        count*=combo_count(n:n,k:int)
        n-=int
    }
    return count/dupCount
}

func combo_count(n:Int,k:Int)->Int{
    assert(n>=k)
    return factorial(n)/(factorial(k)*factorial(n-k))
}

func factorial(_ n:Int)->Int{
    return factorial_tail(n,1)
}

func factorial_tail(_ n:Int, _ tail:Int=1)->Int{
    if n<=1{
        return tail
    }
    return factorial_tail(n-1,n*tail)
}

func order_variant_partition_exists<T:Equatable>(_ partitions:[[[T]]])->Bool{
    var seenParts=[[[T]]]()
    var filteredPartitions=[[[T]]]()
    for part in partitions{
        if !seenParts.filter({aPart in order_variants_partition(aPart,part)}).isEmpty{
            return true
        }else{seenParts.append(part)}
    }
    return false
}

func count_order_variant_partitions<T:Equatable>(_ partitions:[[[T]]])->Int{
    var seenParts=[[[T]]]()
    var count:Int=0
    for part in partitions{
        if !seenParts.filter({aPart in order_variants_partition(aPart,part)}).isEmpty{
            count+=1
        }else{seenParts.append(part)}
    }
    return count
}

func filter_order_variant_partitions<T:Equatable>(_ partitions:[[[T]]])->[[[T]]]{
    var seenParts=[[[T]]]()
    var filteredPartitions=[[[T]]]()
    for part in partitions{
        if !seenParts.filter({aPart in order_variants_partition(aPart,part)}).isEmpty{
            continue
        }else{seenParts.append(part)}
        filteredPartitions.append(part)
    }
    return filteredPartitions
}

func order_variants_partition<T:Equatable>(_ parts1:[[T]], _ parts2:[[T]])->Bool{
    if parts1.count != parts2.count{
        return false
    }
    let parts1counts=parts1.map{$0.count}.sorted{$0>$1}
    let parts2counts=parts2.map{$0.count}.sorted{$0>$1}
    if parts1counts != parts2counts{
        return false
    }
    for part1 in parts1{
        if !parts2.contains(part1){
            return false
        }
    }
    return true
}


