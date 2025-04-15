struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount: Int
    var currency: String
    let conversions = [
        "USD-GBP": 0.5,
        "GBP-USD": 2.0,
        "USD-EUR": 1.5,
        "EUR-USD": 0.67,
        "USD-CAN": 1.25,
        "CAN-USD": 0.8,
        "USD-USD": 1.0
        ]
        
    
    init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
    
    func convert(_ newCurrency: String) -> Money {
        if newCurrency != self.currency {
            let rateToUSD = self.conversions[self.currency + "-USD"]!
            let toUSD = Double(self.amount) * rateToUSD
            let rateToNew = self.conversions["USD-" + newCurrency]!
            let converted = (toUSD * rateToNew).rounded()
            return Money(amount: Int(converted), currency: newCurrency)
        }
        return self
    }
    
    func add(_ other: Money) -> Money {
        if other.currency == self.currency {
            return Money(amount: other.amount + self.amount, currency: self.currency)
        } else {
            let currToUSD = self.convert("USD")
            let otherToUSD = other.convert("USD")
            let addedMoney = Money(amount: currToUSD.amount + otherToUSD.amount, currency: "USD")
            return addedMoney.convert(other.currency)
        }
    }
    
    func subtract(_ other: Money) -> Money{
        if other.currency == self.currency {
            return Money(amount: self.amount + other.amount, currency: self.currency)
        } else {
            let selfToUSD = self.convert("USD")
            let otherToUSD = other.convert("USD")
            let subtractedMoney = Money(amount: selfToUSD.amount - otherToUSD.amount, currency: "USD")
            return subtractedMoney.convert(other.currency)
        }
    }
}

////////////////////////////////////
// Job
//
public class Job {
    var title: String
    var type: JobType
    
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ hoursWorked: Int) -> Int {
        switch self.type {
        case .Hourly(let hourlyRate):
            let totalIncome = Double(hoursWorked) * hourlyRate
            return Int(totalIncome)
        case .Salary(let salary):
            return Int(salary)
        }
    }
    
    func raise(byAmount: Int) {
        switch self.type {
        case .Hourly(let hourlyRate):
            self.type = Job.JobType.Hourly(hourlyRate + Double(byAmount))
        case .Salary(let salary):
            self.type = Job.JobType.Salary(salary + UInt(byAmount))
        }
    }
    
    func raise(byAmount: Double) {
        self.raise(byAmount: Int(byAmount))
    }
    
    func raise(byPercent: Double) {
        switch self.type {
        case .Hourly(let hourlyRate):
            let newRate = hourlyRate + (hourlyRate * byPercent)
            self.type = Job.JobType.Hourly(newRate)
        case .Salary(let salary):
            let newSalary = salary + UInt((Double(salary) * byPercent))
            self.type = Job.JobType.Salary(newSalary)
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    var firstName: String
    var lastName: String
    var age: Int
    private var _job: Job?
    private var _spouse: Person?
    
    // can't get a job unless over 18
    var job: Job? {
        get {
            return _job
        }
        set {
            if self.age < 18 {
                _job = nil
            } else {
                _job = newValue
            }
        }
    }
    
    // can't get married unless over 18
    var spouse: Person? {
        get {
            return _spouse
        }
        set {
            if self.age < 18 {
                _spouse = nil
            } else {
                _spouse = newValue
            }
        }
    }
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        job = nil
        spouse = nil
    }
    
    func toString() -> String {
        var spouseStr = "nil"
        var jobStr = "nil"
        
        if let spouse = self.spouse {
            spouseStr = spouse.firstName
        }
        
        if let job = self.job {
            jobStr = job.title
        }
        
        return "[Person: firstName:\(self.firstName) lastName:\(self.lastName) age:\(self.age) job:\(jobStr) spouse:\(spouseStr)]"
    }
    
}

////////////////////////////////////
// Family
//
public class Family {
    var members: [Person]
    
    init(spouse1: Person, spouse2: Person) {
        if spouse1.spouse != nil || spouse2.spouse != nil {
            self.members = []
            print("One or more of the members of this family-to-be are already married!")
        } else {
            spouse1.spouse = spouse2
            spouse2.spouse = spouse1
            self.members = [spouse1, spouse2]
        }
    }
    
    func haveChild(_ newMember: Person) -> Bool {
        if members[0].age > 21 || members[1].age > 21 {
            members.append(newMember)
            return true
        }
        return false
    }
    
    func householdIncome() -> Int {
        var incomeSum = 0
        for member in self.members {
            if let memberJob = member.job {
                incomeSum += memberJob.calculateIncome(2000)
            }
        }
        return incomeSum
    }
}
