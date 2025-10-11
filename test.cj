package techarena

import std.regex.*
import std.collection.*
import std.sync.*

private class Entry {
    let key: String
    var value: Int64
    var next: Option<Entry>
    public init(key: String, value: Int64, next: Option<Entry>) {
        this.key = key
         item: None)
        this.locks = ArrayList<ReentrantMutex>()
        for (i in 0 .. lockStripeSize - 1) {
            this.locks.append(ReentrantMutex())
        }
    }

    public func put(k: String, v: Int64): Unit {
        let index = this.hashTheKey(k)
        let lockIndex = index % lockStripeSize
        var keyExisted = false
        
        this.locks[lockIndex].lock()
        
        var current = this.bucketArray[index]
        var shouldContinue = true
        while (shouldContinue) {
            if (let Some(entry) <- current) {
                if (entry.key == k) {
                    entry.value = v
                    keyExisted = true
                    break
                }
                current = entry.next
            } else {
                shouldContinue = false
            }
        }

        if (!keyExisted) {
            let newEntry = Entry(k, v, this.bucketArray[index])
            this.bucketArray[index] = Some(newEntry)
            this.keyArray.append(k)
        }
        
        this.locks[lockIndex].unlock()
    }

    public func get(k: String): Option<Int64> {
        let index = this.hashTheKey(k)
        let lockIndex = index % lockStripeSize
        var result: Option<Int64> = None

        this.locks[lockIndex].lock()

        var current = this.bucketArray[index]
        var shouldContinue = true
        while (shouldContinue) {
            if (let Some(entry) <- current) {
                if (entry.key == k) {
                    result = Some(entry.value)
                    break
                }
                current = entry.next
            } else {
                shouldContinue = false
            }
        }

        this.locks[lockIndex].unlock()
        return result
    }

    public func hashTheKey(k: String): Int64 {
        let n: Int64 = 1000000007
        let p: Int64 = 67
        var hash: Int64 = 0
        var power: Int64 = 1
        for (c in k) {
            let code: Int64 = Int64(c)
            hash = (hash + code * power) % n
            power = (power * p) % n
        }
        return hash % bucketCount
    }
    
    public func getKeys(): Array<String> { 
        return Array<String>(this.keyArray) 
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
        for (i in this.keyArray){
           if (let Some(value) <- this.get(i)){
            serializedStr = serializedStr + "$" + i + "£" + this.to_base64(value) 
           }
        }
        return serializedStr
    }

    static public func deserialise(s: String): KeyValue{
        let newKV: KeyValue = KeyValue()
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
                    var j: Int64 = 0
                    while(j < 64){
                        if (b64Chars[j]== c){
                            digit = j
                            break
                        }
                        j = j + 1
                    }
                    result = result * 64 + digit
                    i = i + 1
                }

                if (is_N){
                    result = -result
                }
                newKV.put(values[0], result)
            }
        } 
        return newKV
    }
}
