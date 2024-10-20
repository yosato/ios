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


func get_url_request(urlStr:String, requestType:String)->URLRequest?{
    guard let url = URL(string:urlStr)
    else {
        print("Invalid URL")
        return nil
    }
    
    var request=URLRequest(url:url)
    request.setValue("application/json",forHTTPHeaderField: "Content-Type")
    request.httpMethod = requestType
    
    return request
}

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

func get_remainder<U:Hashable>(_ subArray:[U],superArray:[U])->[U]{
    superArray.filter{el in !subArray.contains(el)}
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

func combos_withRemainder<T:Hashable>(elements: Array<T>, k: Int) -> [([T],[T])] {
    return combos(elements: ArraySlice(elements), k: k).filter{$0.isDistinct()}.map{combo in (combo,get_remainder(combo,superArray:elements))}
}
func combos<T:Hashable>(elements: Array<T>, k: Int) -> [[T]] {
    return combos(elements: ArraySlice(elements), k: k).filter{$0.isDistinct()}
}

extension Collection {
    func pick_random_n_elements(n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
}

func duplicate_in_partition<U:Hashable>(_ partition:[[U]])->Bool{
    var seen=Set<U>()
    var duplicateP=false
    for part in partition{
        for el in part{
            if(seen.contains(el)){
                print("duplicate found, \(el)")
                duplicateP=true
            }else{seen.insert(el)}
        }
    }
    return duplicateP
}


func get_randomEl_n_times<U:Hashable>(_ aSet:Set<U>, _ anInt:Int)->(Set<U>,Set<U>){
    assert(aSet.count>=anInt)
    var newSet=Set<U>()
    var reducedSet=aSet
    for _ in (0..<anInt){
        let pickedEl=reducedSet.randomElement()
        reducedSet.remove(pickedEl!)
        newSet.insert(pickedEl!)
    }
    assert(newSet.count==anInt)
    assert(reducedSet.count==aSet.count-anInt)
    return (newSet,reducedSet)
}

func generate_partition_withIntegers_fromSizedSets<U:Hashable>(ints:[Int], sizedSets:[Int:Set<Set<U>>])->Set<Set<U>>?{
    assert(Set(sizedSets.keys).isSuperset(of: Set(ints)))
    let intsProducts=Dictionary(uniqueKeysWithValues: get_el_indices(ints).map{(el,indices) in (el,el*indices.count)})
    for int in Set(ints){
        assert(intsProducts[int]!<=sizedSets[int]!.count)
    }
    var modSizedSets=sizedSets
    var partition:Set<Set<U>>=Set()
    let intsLastInd=ints.count-1
    for (cntr,int) in ints.enumerated(){
        if(modSizedSets[int]!.isEmpty){
            return nil}
        let pickedPart=modSizedSets[int]!.randomElement()!
        partition.insert(pickedPart)
        assert(all_disjoint(Array(partition)))
        if(cntr != intsLastInd){
            modSizedSets[int]!.remove(pickedPart)
            for intKey in sizedSets.keys{
                modSizedSets[intKey]=sizedSets[intKey]!.filter{set in no_overlap_withAnySet(set, partition)}
            }
        }
    }
    assert(partition.map{part in part.count}.sorted()==ints.sorted())
    assert(partition.filter{part in part.isEmpty}.isEmpty)
    assert(!partition.isEmpty)
    return partition
}

func no_overlap_withAnySet<U:Hashable>(_ aSet:Set<U>, _ setOfSets:Set<Set<U>>)->Bool{
    for tgtSet in setOfSets{
        if(!aSet.intersection(tgtSet).isEmpty){
            return false
        }
    }
    return true
}

func generate_random_partition_withIntegers<U:Hashable>(_ aSet:Set<U>, ints:[Int])->Set<Set<U>>{
    let intSum=ints.reduce(0,+)
    assert(aSet.count>=intSum)
    let willBeRemainder=aSet.count==intSum
    var partition=Set<Set<U>>()
    var reducedSet=aSet
    var repeatCntr=0
    for (cntr,int) in ints.enumerated(){
        var newSet:Set<U>;var newReducedSet:Set<U>
        if(cntr==ints.count && !willBeRemainder){
            partition.insert(reducedSet)
            return partition
        }
            repeatCntr+=1
            if(repeatCntr != 0 && repeatCntr%5==0){print("repeating \(repeatCntr)")}
            let (candSet,candReducedSet)=get_randomEl_n_times(reducedSet,int)
            newSet=candSet;newReducedSet=candReducedSet
        reducedSet=newReducedSet
        partition.insert(newSet)
    }
    return partition
}

func set2SizedSets<U:Hashable>(_ aSet:Set<U>, ints:[Int])->[Int:Set<Set<U>>]{
    var sizedSets=[Int:Set<Set<U>>]()
    for int in ints{
        let combosInA=combos(elements:Array(aSet),k:int)
        let combosInS=Set(combosInA.map{arr in Set(arr)})
        sizedSets[int]=combosInS
    }
    return sizedSets
}

func generate_distinct_paritions_withIntegers_withRemainderHoldout_withSizedSets<U:Hashable>(_ aSet:Set<U>, ints:[Int],  sizedSets:[Int:Set<Set<U>>], sparcityThresh:Int=3)->[(Set<Set<U>>,Set<U>)]{
    var partitionsWithRemainder=[(Set<Set<U>>,Set<U>)]()
    let remainderCount=aSet.count-ints.reduce(0,+)
    let remainderCombos=combos(elements:Array(aSet), k:remainderCount)
    let remainderComboCount=remainderCombos.count
    let totalCount=remainderCount+sum(ints)
    var upperBound:Int {
        let aDefault=count_intpartitions(ints)/100/(remainderCount==0 ? 2 : remainderCount)
        if(aDefault<100 && remainderCount<2){return aDefault}else{
            if(remainderCount==0){
                if(totalCount<=14){return 100}else if(totalCount<=16){return 80}else{return 40}
            }else{
                return max(3, 150/remainderComboCount)
            }
        }
    }
    print("we iterate \(remainderComboCount) times")
    for (cntr,remainder) in remainderCombos.enumerated(){
        print("iteration \(cntr+1) of \(remainderComboCount)")
        let reducedSet=aSet.filter{el in !remainder.contains(el)}
        assert(reducedSet.count+remainder.count==aSet.count);assert(reducedSet.intersection(Set(remainder)).isEmpty)
        var partitions=generate_distinct_partitions_withIntegers_fromSizedSets(reducedSet, ints: ints, upperBound:upperBound, sizedSets:sizedSets)
        for partition in partitions{
            assert(Set(partition.flatMap{$0}).intersection(Set(remainder)).isEmpty)
            assert(!partition.isEmpty)
        }
        let partitionsCount=partitions.count
        if(partitionsCount<sparcityThresh){
            print("only \(partitionsCount) partitions found for \(ints) with \(remainder.count) remainder")
            partitions+=generate_distinct_partitions_withIntegers(reducedSet, ints: ints, upperBound:sparcityThresh-partitionsCount)
        }
        print("\(partitions.count) partitions generated")
        assert(partitions.filter{partition in partition.isEmpty}.isEmpty)
        let partitionsWithRemainderPerIter=partitions.map{partition in (partition, Set(remainder))}
        partitionsWithRemainder+=partitionsWithRemainderPerIter
        
    }
//    for (partition,rem) in partitionsWithRemainder{
//        assert(Set(partition.flatMap{$0}).intersection(rem).isEmpty)
//        assert(!partition.isEmpty)
//    }
    return partitionsWithRemainder
}

func generate_distinct_partitions_withIntegers_fromSizedSets<U:Hashable>(_ orgSet:Set<U>, ints:[Int], upperBound:Int=1000, sizedSets:[Int:Set<Set<U>>]=[:])->[Set<Set<U>>]{
    for uniqInt in Set(ints){
        assert(sizedSets.keys.contains(uniqInt))
    }
    var filteredSizedSets=[Int:Set<Set<U>>]()
    for (size,sets) in sizedSets{
        filteredSizedSets[size]=sets.filter{set in set.intersection(orgSet).count==set.count}
    }
    var remainingElCount=ints.reduce(0,+)
    var partitions=[Set<Set<U>>]()
    let expectedPartitionCount=count_intpartitions(ints,sizedSetCounts: sizedSets.mapValues{sets in sets.count})
    var cntr=0
    //    let unit=upperBound/5
    //    var unitCntr=0
    let upperBound:Int=upperBound
    print("generating maximally \(upperBound)")
    var hitNil:Bool=false
    repeat{
        cntr+=1
        if(cntr%500==0){print("\(cntr)")}
        var newPartition:Set<Set<U>>=Set()
        repeat{if let possibleNewPartition=generate_partition_withIntegers_fromSizedSets(ints: ints, sizedSets: filteredSizedSets){
            newPartition=possibleNewPartition
            }else{hitNil=true}
        }while(!hitNil && partitions.contains(newPartition))
        if(!newPartition.isEmpty){partitions.append(newPartition)}
    }while(!hitNil && partitions.count<upperBound)
    
    return partitions
}

func generate_distinct_partitions_withIntegers<U:Hashable>(_ aSet:Set<U>, ints:[Int], upperBound:Int=20000)->[Set<Set<U>>]{
    
    var partitions=[Set<Set<U>>]()
    let expectedPartitionCount=count_intpartitions(ints)
//    var upperBound:Int=Int(Double(expectedPartitionCount)*rate)
//    if(upperBound>20000){upperBound=20000}
    print("generating \(upperBound), \(Double(upperBound)/Double(expectedPartitionCount)*100.0)%")
    var cntr=0
    let unit=upperBound/5
    var unitCntr=0
    while(partitions.count<upperBound){
        if(cntr != 0 && unit>1000 && cntr%unit==0){unitCntr+=20; print("\(unitCntr)%")}
        var newPartition=Set<Set<U>>()
        repeat{newPartition=generate_random_partition_withIntegers(aSet, ints: ints)
            }while(partitions.contains(newPartition))
        partitions.append(newPartition)
        cntr+=1
    }
    return partitions
}


func randomly_generate_disjoint_combos<T:Hashable>(elements:Array<T>, k:Int, proportionUpTo:Double)->[([T],[T])]{
    var combosGenerated=[([T],[T])]()
    var setsDone=Set<Set<T>>()
    let upperBound=combo_count(n:elements.count,k:k)
    let comboCountUpTo=Int(Double(upperBound)*proportionUpTo)
    let n_els=elements.pick_random_n_elements(n:k)
    while(combosGenerated.count < comboCountUpTo){
        if(!setsDone.contains(Set(n_els))){
            let shuffledCombos=combos(elements:n_els, k:k).shuffled()
            for combo in shuffledCombos[..<Int(shuffledCombos.count/2)]{
                combosGenerated.append((combo,get_remainder(combo, superArray: elements)))
            }
        }
    }
    return combosGenerated
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

func isDisjoint<T:Hashable>(_ array1:any Collection<T>,_ array2:any Collection<T>)-> Bool{
    return Set(array1).intersection(Set(array2)).isEmpty
}

func all_disjoint<T:Hashable>(_ arrayOfArrays:[any Collection<T>])->Bool{
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

func count_intpartitions(_ ints:[Int], remainder:Int=0, sizedSetCounts:[Int:Int]=[:])->Int{
    if(!sizedSetCounts.isEmpty){
        assert(Set(ints)==Set(sizedSetCounts.keys))
    }
    
    let repetitions=get_repetition_counts(ints)
    var dupCount:Int=1
    for (_, count) in repetitions{
        if count>=2{
            dupCount*=factorial(count)
        }
    }
    var n=sum(ints)+remainder
    var count=1
    for int in ints[0..<ints.count]{
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

func get_el_indices<U:Hashable>(_ anArray:[U])->[U:[Int]]{
    var elIndices=[U:[Int]]()
    for (cntr,el) in anArray.enumerated(){
        elIndices[el,default:[]].append(cntr)
    }
    return elIndices
}

func order_consecutive_first<U:Comparable & Hashable>(_ anArray:[U])-> [U]{
    let elIndices=get_el_indices(anArray)
    let elCounts=elIndices.map{(el,indices) in (el,indices.count)}.sorted{$0.0 > $1.0}
    var sortedArray=[U]()
    for (el,count) in elCounts{
        sortedArray+=Array(repeating:el, count:count)
    }
    return sortedArray
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

// there could be a remainder left afterwards, i.e. there can be more orgList els than the sum of ints
func get_partitions_withIntegers<T:Hashable>(_ orgSet:Set<T>, _ ints:[Int], sizedSetsToExclude:[Int:Set<Set<T>>]=[:], doPotentiallyRandomPrune:Bool=false, debug:Bool=false)-> [(Set<Set<T>>,Set<T>)]{

    var partitionsWithRemainder:[(Set<Set<T>>,Set<T>)]=[(Set(),orgSet)]//to be returned

    let doPrune=(!sizedSetsToExclude.isEmpty || doPotentiallyRandomPrune)
    assert(sum(ints)<=orgSet.count)
    assert(!orgSet.isEmpty)
    assert(!ints.isEmpty)
    
    if(ints.count==1){
        return combos_withRemainder(elements: Array(orgSet), k: ints[0]).map{(combo,remainder) in (Set([Set(combo)]),Set(remainder))}
    }
    
    let remainderCountAtTheEnd=orgSet.count - sum(ints)
    // orders ints prioritising equi-numbers, like 4,4,4,3,3,5,2 (generally descending)
    let ints=order_consecutive_first(ints)
    
    let intLen=ints.count
    let lastInd=intLen-1
    let expectedDefaultFinalCount=count_intpartitions(ints, remainder:remainderCountAtTheEnd)
    
    
    var prevInt:Int = -1
    var doneInts:[Int]=[]
    
    for (cntr,currentInt) in ints.enumerated(){
        let isLastItem=(cntr==lastInd)
        let startTime=Date()
        if(debug){print("partition index \(cntr)"+(isLastItem ? " (final)" : "")+" in \(ints) to be done...")}
        let nextIsLast:Bool?=(isLastItem ? nil : cntr+1==lastInd)
        let sameAsPreviousInt=(currentInt==prevInt)
        let nextIntWillBeSame:Bool?=(nextIsLast==nil || nextIsLast! ? nil : currentInt==ints[cntr+1])
        let lastSkip = remainderCountAtTheEnd==0 && (nextIsLast ?? false) && !(nextIntWillBeSame ?? true)
//        let willHaveRemainderNext=true
        //nil there isn't a next thing
        let prevPartCnt=partitionsWithRemainder.count
                
        //we skip the last int comb gen if there's no remainder for efficiency
        
        //        if(lastSkip)else{
        partitionsWithRemainder=extend_partitions(partitionsWithRemainder, currentInt, sizedSetsToExclude:sizedSetsToExclude, sameAsPreviousInt:sameAsPreviousInt, debug:debug)
        let timeElapsedPerIter=Date().timeIntervalSince(startTime)
        doneInts.append(currentInt)
        assert(doneInts.sorted()==partitionsWithRemainder[0].0.map{part in part.count}.sorted())
        assert(all_identical(partitionsWithRemainder.map{(partition,_rem) in partition.map{part in part.count}.sorted()}))
        if(debug){print("partitions "+(isLastItem ? "finally " : "now ")+"number \(partitionsWithRemainder.count) after \(cntr) extensions, \(String(format:"%.2f", timeElapsedPerIter)) taken for this iteration")}
        
        let remainderVariety=partitionsWithRemainder.map{(_part,rem) in Set(rem) }.reduce(Set()){$0.union($1)}
        //assert(remainderVariety.count==orgList.count)
        if(lastSkip){if(debug){print("skipping last int extension")}
            if(!doPrune){assert(expectedDefaultFinalCount==partitionsWithRemainder.count)}
            return partitionsWithRemainder.map{(part,rem) in (part.union([rem]), [])} }
        
        if(!isLastItem){assert(partitionsWithRemainder.count>=prevPartCnt)}
        prevInt=currentInt
    }
        
    return partitionsWithRemainder
    
    
    func extend_partitions<U:Hashable>(_ orgPartitionsWithRemainder:[(Set<Set<U>>,Set<U>)], _ anInt:Int, sizedSetsToExclude:[Int:Set<Set<U>>], sameAsPreviousInt:Bool, debug:Bool=false)-> [(Set<Set<U>>,Set<U>)]{

        var newPartitionsWithRemainder=[(Set<Set<U>>,Set<U>)]()
        
        let partitionCount=partitionsWithRemainder.count
//        let partCountTotal=partitionsWithRemainder[0].0.map{part in part.count}.reduce(0,+)
//        let remainingEls=baseElements.count-partCountTotal
        let remainderCount=(partitionsWithRemainder.isEmpty ? 0 : partitionsWithRemainder[0].1.count)
        let complexityScale=partitionCount*remainderCount
        let thresh=1000
        let proportionUpTo:Double
        
        for (cntr,(orgPartition,remainingElements)) in orgPartitionsWithRemainder.enumerated(){
            if (cntr != 0 && cntr%1000==0){if(debug){print("\(cntr) done, partitions counting \(partitionsWithRemainder.count)")}}
            let comboCount=combo_count(n:anInt+remainingElements.count,k:anInt)
            for (comboCntr,(comb,remainder)) in combos_withRemainder(elements:Array(remainingElements),k:anInt).enumerated(){
                if(!sizedSetsToExclude.isEmpty && sizedSetsToExclude[anInt]!.contains(Set(comb))){continue}
                
                let partitionsSoFar=newPartitionsWithRemainder.map{(partition,rem) in partition}
                var candPartition=orgPartition; let candPartitionCountBefore=candPartition.count; candPartition.insert(Set(comb))
                
                if(sameAsPreviousInt){
                    if(partitionsSoFar.contains(candPartition)){
                        continue}
                }
                candPartition.insert(Set(comb));assert(candPartitionCountBefore+1==candPartition.count)

                let candPartitionWithRem=(candPartition, Set(get_remainder(comb, superArray: remainder)))
                newPartitionsWithRemainder.append(candPartitionWithRem)
                        
            }
            
        }
            return newPartitionsWithRemainder
        }
        
    }


func all_identical<T:Equatable>(_ anArray:[T])->Bool{
    if(anArray.count<=1){return true}
    let firstEl=anArray[0]
    return anArray[1...].allSatisfy{firstEl==$0}
}
