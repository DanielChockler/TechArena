import std.console.*
import std.regex.*
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
    private func to_base64(v: Int64): String {
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
        
        for (i in keyArray){
           if (let Some(value) <- get(i)){
            serializedStr = serializedStr + "$" + i + "£" + to_base64(value) 
           }
        }

        return serializedStr

    }

    static public func deserialise(s: String): Unit{
        
        let kv = KeyValue()
        let pattern1 = Regex("\\$.*?")

        var tuples: Array<String>  = Matcher(pattern1, s).split()
        
        for (k in tuples){
            var result: Int64 = 0
            var is_negative = false
            var start_index: Int64 = 0
            if (k.size != 0){
            let pattern2 = Regex("£.*?")



            var value= Matcher(pattern2, k).split()
            println(value[1])
            var base64_str = value[1]
            // Check for negative prefix
            if (base64_str.size > 0 && base64_str[0] == 45) { // 'N' ASCII
                is_negative = true
                start_index = 1
            }
            
            // Single loop - no nested loops
            var i = start_index
            while (i < base64_str.size) {
                var ch_code = base64_str[i]
                var digit: UInt8 = 0
                
                // Direct character code mapping - no inner loop
                if (ch_code >= 65 && ch_code <= 90) {        // A-Z: 65-90 → 0-25
                    digit = ch_code - 65
                } else if (ch_code >= 97 && ch_code <= 122) { // a-z: 97-122 → 26-51
                    digit = ch_code - 71                     // 26 + (ch_code - 97) = ch_code - 71
                } else if (ch_code >= 48 && ch_code <= 57) {  // 0-9: 48-57 → 52-61
                    digit = ch_code + 4                      // 52 + (ch_code - 48) = ch_code + 4
                } else if (ch_code == 43) {                   // + → 62
                    digit = 62
                } else if (ch_code == 47) {                   // / → 63
                    digit = 63
                } 
                
                result = result * 64 + Int64(digit)
                i = i + 1
            }
            
            if (is_negative) {
                result = -result
            }
            println(result)
                } 
    
    
        }
    


        
        
        
}


    private func hashTheKey(k: String): Int64{
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
    

    


    kV.put("helloBabes", 673)
    kV.put("test", 232312312312)
    kV.put("laksjdflk", 2343212323123)
    kV.put("djsjhdlfklkasdf", -1231231234)
    kV.put("fjkhdsf", -12)


    println("Test Get")
    print(kV.get("helloBabes"))

    println(kV.getKeys())

    let ser: String = kV.serialize()
    println(ser)
    
    let nV: KeyValue = KeyValue.deserialise(ser)

    println(nV.getKeys())
    println(nV.get("helloBabes"))
    println(nV.get("fjkhdsf"))

    //nV = KeyValue.deserialise(ser)

   // nV.getKeys()
}