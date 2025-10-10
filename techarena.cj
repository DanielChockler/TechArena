import std.console.*
import std.collection.*

class KeyValue {
    public var bucketArray: Array<(Option<String>, Option<Int64>)> = Array<(Option<String>, Option<Int64>)>()

    public init(){
        this.bucketArray = Array<(Option<String>, Option<Int64>)>(1000000, item: (None, None)) 
    }

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
    println(KeyValue().bucketArray.size)
    println(KeyValue().hashTheKey("zzzzzzzzzzxzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"))
}