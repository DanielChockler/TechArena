import std.console.*
import std.collection.*

class KeyValue {
    public var bucketArray: Array<(Option<String>, Option<Int64>)> = Array<(Option<String>, Option<Int64>)>()

    public init(){
        this.bucketArray = Array<(Option<String>, Option<Int64>)>(1000000, item: (None, None)) 
    }

    public func put(k: String, v: Int64): Unit {
        let index: Int64 = hashTheKey(k)


        bucketArray[index] = (k, v)

    }

    public func get(k: String): Option<Int64>{
        return bucketArray[hashTheKey(k)][1]
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

    let kV = KeyValue()
    

    

    let index: Int64 = kV.hashTheKey("helloBabes")
    println(index)

    kV.put("helloBabes", 67)

    println("Control")
    print(kV.bucketArray[index][0])
    println(kV.bucketArray[index][1])

    println("Test Get")
    print(kV.get("helloBabes"))

    
}