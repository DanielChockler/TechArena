import std.console.*
import std.collection.*

class KeyValue {
    public var bucketArray: Array<(Option<String>, Option<Int64>)> = Array<(Option<String>, Option<Int64>)>()
    private var keyArray: ArrayList<String> = ArrayList<String>()

    public init(){
        this.bucketArray = Array<(Option<String>, Option<Int64>)>(1000000, item: (None, None)) 
    }

    public func put(k: String, v: Int64): Unit {
        let index: Int64 = hashTheKey(k)

        this.keyArray.append(k)
        bucketArray[index] = (k, v)

    }

    public func get(k: String): Option<Int64>{
        return bucketArray[hashTheKey(k)][1]
    }

    public func getKeys(): Array<String> {
        return Array<String>(keyArray)
    }
    public func to_base64(v: Int64): String {
        let b64Chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        var result: String = ""
        var temp: Int64 = v
        var is_N: Bool = false

        if (temp == 0){
            return "A"
        } else if (temp < 0) {
            is_N = true
            temp = -temp
        }
        while (temp > 0){
            var remainder: Int64 = temp % 64
            result = Rune(b64Chars[remainder]).toString() + result 
            temp = temp / 64
        }

        if (is_N){
            result = "-" + result
        }

        return result

    }

    public func serialize() : String{
        var serializedStr: String = ""
        return serializedStr

        

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

    println(kV.getKeys())

    println(kV.to_base64(98732498734))
    println(kV.to_base64(-982734982734))

    
}