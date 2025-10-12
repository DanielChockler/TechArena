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
        this.value = value
        this.next = next
    }
}

class KeyValue {
    private let bucketCount = 1000003
    private let lockStripeSize = 128

    private var bucketArray: Array<Option<Entry>>
    private var keyArray: ArrayList<String> = ArrayList<String>()
    private let locks: ArrayList<ReentrantMutex>
    private let keyArrayLock: ReentrantMutex = ReentrantMutex()

    public init() {
        this.bucketArray = Array<Option<Entry>>(bucketCount, item: None)
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
        while (let Some(entry) <- current) {
            if (entry.key == k) {
                entry.value = v
                keyExisted = true
                break
            }
            current = entry.next
        }

        if (!keyExisted) {
            let newEntry = Entry(k, v, this.bucketArray[index])
            this.bucketArray[index] = Some(newEntry)
            this.keyArrayLock.lock()
            this.keyArray.append(k)
            this.keyArrayLock.unlock()
        }
        
        this.locks[lockIndex].unlock()
    }

    public func get(k: String): Option<Int64> {
        let index = this.hashTheKey(k)
        let lockIndex = index % lockStripeSize
        var result: Option<Int64> = None

        this.locks[lockIndex].lock()
        var current = this.bucketArray[index]
        while (let Some(entry) <- current) {
            if (entry.key == k) {
                result = Some(entry.value)
                break
            }
            current = entry.next
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
        var finalIndex = hash % bucketCount
        if (finalIndex < 0) {
            finalIndex = finalIndex + bucketCount
        }
        return finalIndex
    }
    
    public func getKeys(): Array<String> { 
        return Array<String>(this.keyArray) 
    }

    public func to_base64(v: Int64): String {
        let b64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        if (v == 0) { return "A" }
        var result = ""
        var temp = v
        var is_N = false
        if (temp < 0) { is_N = true; temp = -temp; }
        while (temp > 0) {
            let remainder = temp % 64
            result = Rune(b64Chars[remainder]).toString() + result 
            temp = temp / 64
        }
        if (is_N) { result = "-" + result; }
        return result
    }

    public func serialize() : String {
        let parts = ArrayList<String>()
        for (key in this.keyArray) {
           if (let Some(value) <- this.get(key)) {
                parts.append(";")
                parts.append(key)
                parts.append(":")
                parts.append(this.to_base64(value))
           }
        }
        return String.join(Array<String>(parts), delimiter: "")
    }

    static public func deserialize(s: String): KeyValue {
        let newKV = KeyValue()
        if (s.isEmpty()) { return newKV }
        
        let chunks = Matcher(Regex(";"), s).split()
        
        for (chunk in chunks) {
            if (chunk.isEmpty()) { continue }

            let parts = Matcher(Regex(":"), chunk).split()
            if (parts.size != 2) { continue }

            let key = parts[0]
            var valueStr = parts[1]

            let b64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            var result: Int64 = 0
            var is_N = false

            if (valueStr.size > 0 && Rune(valueStr[0]) == r'-') {
                is_N = true
                valueStr = valueStr[1..]
            }

            for (c in valueStr) {
                var digit: Int64 = 0; var j: Int64 = 0;
                while (j < 64) {
                    if (b64Chars[j] == c) { digit = j; break; }
                    j = j + 1
                }
                result = result * 64 + digit
            }

            if (is_N) { result = -result; }
            newKV.put(key, result)
        } 
        return newKV
    }
}
