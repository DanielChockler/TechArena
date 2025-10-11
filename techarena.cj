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
        
        for (i in keyArray){
           if (let Some(value) <- get(i)){
            serializedStr = serializedStr + "$" + i + "£" + to_base64(value) 
           }
        }

        return serializedStr

    }

    static public func deserialise(s: String): KeyValue{
       
        let self: KeyValue = KeyValue()
        
        let pattern1 = Regex("\\$.*?")

        var tuples: Array<String>  = Matcher(pattern1, s).split()
        
        for (k in tuples ){

            if (k.size != 0){
                let pattern2 = Regex("£.*?")



                var values= Matcher(pattern2, k).split()

                let b64Chars: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
                var result: Int64 = 0
                var start_index: Int64 = 0
                var is_N = false 

                if (Rune((values[1])[0]) == r'-'){
                    is_N = true
                    start_index = 1
                }

                var i = start_index

                while(i< (values[1]).size){
                    var c = (values[1])[i]
                    var digit: Int64 = 0
                    var found: Bool = false

                    var j: Int64 = 0
                    while(j < 64){
                        if (b64Chars[j]== c){
                            digit = j
                            found = true
                            break
                        }
                        j = j +1
                    }
   


                    result = result * 64 + digit
                    i = i + 1
                }

                if (is_N){
                    result = - result
                }



                self.put(values[0], result)

            }
        } 

        return self
        

        
        
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

    kV.put("helloBabes", 673)
    kV.put("test", 232312312312)
    kV.put("laksjdflk", 2343212323123)
    kV.put("djsjhdlfklkasdf", -1231231234)
    kV.put("fjkhdsf", -12)

    println("Control")
    print(kV.bucketArray[index][0])
    println(kV.bucketArray[index][1])

    println("Test Get")
    print(kV.get("helloBabes"))

    println(kV.getKeys())

    let ser: String = kV.serialize()
    println(ser)
    
    let nV: KeyValue = KeyValue.deserialise(ser)

    println(nV.getKeys())
    println(nV.get("helloBabes"))

    //nV = KeyValue.deserialise(ser)

   // nV.getKeys()
}