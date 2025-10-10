import std.console.*
import std.collection.*

class KeyValue {
    //private let KeyValue: Array<(Option<String>, Option<Int64>)> = Array<Option<String>, Option<Int64>>(10^6,  item: (None, None)) 


    public func hashTheKey(k: String): Int64{
        let n: Int64 = 1000000007
        let p: Int64 = 67

        var hash: Int64 = 0
        var power: Int64 = 1

        for (c in k){
            let code: Int64 = Int64(c)
            hash = (hash +code * power) % n
            power = (power * p ) % n


        }

        return hash % (1000000)

    }

	
}

main(){
    
    println(KeyValue().hashTheKey("zzzzzzzzzzxzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"))
}