import TealiumSwift

public class VisitorDelegate: VisitorServiceDelegate {
    public func didUpdate(visitorProfile: TealiumVisitorProfile) {
        var payload = convert(visitorProfile)
        payload[TealiumFlutterConstants.Events.emitterName.rawValue] =  TealiumFlutterConstants.Events.visitorService.rawValue
        SwiftTealiumPlugin.invokeOnMain("callListener", arguments: payload)
    }
    
    private func convert(_ visitorProfile: TealiumVisitorProfile) -> [String: Any] {
        typealias Visitor = TealiumFlutterConstants.Visitor
        
        // Sets cannot be serialized to JSON, so convert to array first
        let arraySetOfStrings = visitorProfile.setsOfStrings.map({ (stringSet) -> [String: [String]] in
            var newValue = [String: [String]]()
            stringSet.forEach {
                newValue[$0.key] = Array($0.value)
            }
            return newValue
        })
        
        let currentVisitArraySetOfStrings = visitorProfile.currentVisit?.setsOfStrings.map({ (stringSet) -> [String: [String]] in
            var newValue = [String: [String]]()
            stringSet.forEach {
                newValue[$0.key] = Array($0.value)
            }
            return newValue
        })

        let visit: [String: Any?] = [
            Visitor.dates: visitorProfile.currentVisit?.dates,
            Visitor.booleans: visitorProfile.currentVisit?.booleans,
            Visitor.arraysOfBooleans: visitorProfile.currentVisit?.arraysOfBooleans,
            Visitor.numbers: visitorProfile.currentVisit?.numbers,
            Visitor.arraysOfNumbers: visitorProfile.currentVisit?.arraysOfNumbers,
            Visitor.tallies: visitorProfile.currentVisit?.tallies,
            Visitor.strings: visitorProfile.currentVisit?.strings,
            Visitor.arraysOfStrings: visitorProfile.currentVisit?.arraysOfStrings,
            Visitor.setsOfStrings: currentVisitArraySetOfStrings
        ]
        let visitor: [String: Any?] = [
            Visitor.audiences: visitorProfile.audiences,
            Visitor.badges: visitorProfile.badges,
            Visitor.dates: visitorProfile.dates,
            Visitor.booleans: visitorProfile.booleans,
            Visitor.arraysOfBooleans: visitorProfile.arraysOfBooleans,
            Visitor.numbers: visitorProfile.numbers,
            Visitor.arraysOfNumbers: visitorProfile.arraysOfNumbers,
            Visitor.tallies: visitorProfile.tallies,
            Visitor.strings: visitorProfile.strings,
            Visitor.arraysOfStrings: visitorProfile.arraysOfStrings,
            // Sets cannot be serialized to JSON, so convert to array first
            Visitor.setsOfStrings: arraySetOfStrings,
            Visitor.currentVisit: visit.compactMapValues { $0 }
        ]
        return visitor.compactMapValues({$0})
    }
    
}
